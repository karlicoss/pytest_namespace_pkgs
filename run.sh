#!/bin/bash
set -u

cd "$(dirname "$0")"


rm -f src/mypackage/__init__.py
# this is how 'normal' python runtime handles namespace packages without __init__.py
PYTHONPATH=src python3 -c 'import mypackage.test_mymodule'
# MY NAME IS mypackage.test_mymodule
# MY NAME IS mypackage.mymodule

function via_src_dir() {
    echo "----------------- pytest src"
                            pytest src
}

function pyargs_package() {
    echo "----------------- PYTHONPATH=src pytest --pyargs mypackage"
                            PYTHONPATH=src pytest --pyargs mypackage
}

function pyargs_module {
    echo "----------------- PYTHONPATH=src pytest --pyargs mypackage.test_mymodule"
                            PYTHONPATH=src pytest --pyargs mypackage.test_mymodule
}


function via_importlib {
    # more of a desperate attempt -- the docs are saying "test modules are non-importable by each other"
    echo "----------------- PYTHONPATH=src pytest --import-mode=importlib --pyargs mypackage.test_mymodule"
                            PYTHONPATH=src pytest --import-mode=importlib --pyargs mypackage.test_mymodule
}


# with __init__.py most of these ways work (the last one is still weird, why does it pick up src?)
touch src/mypackage/__init__.py
echo "with __init__.py"
via_src_dir     # passes
pyargs_package  # passes
pyargs_module   # passes
via_importlib   # fails, "No module named 'src.mypackage'"


# without __init__.py, none of this works
rm -f src/mypackage/__init__.py
echo "without __init__.py"
via_src_dir    # fails, "attempted relative import with no known parent package"
pyargs_package # fails, "module or package not found: mypackage (missing __init__.py?)"
pyargs_module  # fails, "attempted relative import with no known parent package"
via_importlib  # fails, "No module named 'src.mypackage'"


# possibly relevant issues
# - https://github.com/pytest-dev/pytest/issues/5147
# - https://github.com/pytest-dev/pytest/issues/2371
