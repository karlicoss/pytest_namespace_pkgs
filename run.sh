#!/bin/bash
set -eu

cd "$(dirname "$0")"


rm -f src/mypackage/__init__.py


### this is how 'normal' python runtime handles namespace packages without __init__.py
PYTHONPATH=src python3 -c 'import mypackage.test_mymodule as M; M.test()'
# should result in
# MY NAME IS mypackage mypackage.test_mymodule
# MY NAME IS mypackage mypackage.mymodule

PYTHONPATH=src python3 -c 'import mypackage.tests.test_mymodule2 as M; M.test()'
# should result in
# MY NAME IS mypackage.tests mypackage.tests.test_mymodule2
# MY NAME IS mypackage mypackage.mymodule
###


function _pytest() {
    _PYTEST='pytest'  # stable version
    # _PYTEST='git+https://github.com/karlicoss/pytest@pyargs-namespace-packages'
    uv run --with="$_PYTEST" -m pytest -rap "$@"
}

function via_src_dir() {
    # we only collect here, because collecting as files is inherently going to mess up package names
    # e.g. it can contain or not contain src. at the start depending on whether we used -m pytest or 'pytest' command
    echo; echo;
    echo "-----------------  pytest --collect-only src"
                            _pytest --collect-only src
}

# this is the one I'm really keen to get working
# TODO also try against installed package, without PYTHONPATH=src?
function pyargs_package() {
    echo; echo;
    echo "----------------- PYTHONPATH=src  pytest --pyargs mypackage"
                            PYTHONPATH=src _pytest --pyargs mypackage
}

function pyargs_subpackage() {
    echo; echo;
    echo "----------------- PYTHONPATH=src  pytest --pyargs mypackage.tests"
                            PYTHONPATH=src _pytest --pyargs mypackage.tests
}

function pyargs_module {
    echo; echo;
    echo "----------------- PYTHONPATH=src  pytest --pyargs mypackage.test_mymodule"
                            PYTHONPATH=src _pytest --pyargs mypackage.test_mymodule
}


function pyargs_module_via_importlib {
    # more of a desperate attempt -- the docs are saying "test modules are non-importable by each other"
    echo; echo;
    echo "----------------- PYTHONPATH=src  pytest --import-mode=importlib --pyargs mypackage.test_mymodule"
                            PYTHONPATH=src _pytest --import-mode=importlib --pyargs mypackage.test_mymodule
}


## NOTE: for these checks, we need consider_namespace_packages = true set, otherwise everything is a bit fucked

## with __init__.py and no conftest customizations, these work:
touch src/mypackage/__init__.py
echo "with __init__.py"
via_src_dir                  # should collect 3 tests
pyargs_module                # should run 1 test
pyargs_module_via_importlib  # should run 1 test
pyargs_package               # should run 3 tests

rm -f src/mypackage/__init__.py
echo "without __init__.py"

## without __init__.py some of these work:
via_src_dir                  # should collect 3 tests
pyargs_module                # should run 1 test . When fails, "attempted relative import with no known parent package"
pyargs_module_via_importlib  # should run 1 test . When fails, "No module named 'src.mypackage'"
##


### now, what doesn't work (unless we apply conftest patch or https://github.com/pytest-dev/pytest/pull/13426)
pyargs_package               # should run 3 tests. When fails, "module or package not found: mypackage (missing __init__.py?)"
pyargs_subpackage            # should run 1 test . When fails, "module or package not found: mypackage.tests (missing __init__.py?)"


# possibly relevant issues
# - https://github.com/pytest-dev/pytest/issues/5147
# - https://github.com/pytest-dev/pytest/issues/2371
# - TODO hopefully this gets merged! https://github.com/pytest-dev/pytest/pull/13426

# this is sort of relevant
# https://docs.pytest.org/en/latest/explanation/pythonpath.html#standalone-test-modules-conftest-py-files
# but still doesn't really explain why is it behaving like this
