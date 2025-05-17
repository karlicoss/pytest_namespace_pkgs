print("MY NAME IS", __package__, __name__)
from .. import mymodule

def test() -> None:
    assert __package__ == 'mypackage.tests_with_init'
    assert __name__ == 'mypackage.tests_with_init.test_mymodule3'
