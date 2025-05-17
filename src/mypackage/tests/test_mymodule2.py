print("MY NAME IS", __package__, __name__)
from .. import mymodule

def test() -> None:
    assert __package__ == 'mypackage.tests'
    assert __name__ == 'mypackage.tests.test_mymodule2'
