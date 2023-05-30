print("MY NAME IS", __name__)
from . import mymodule

def test_name():
    assert __name__ == 'mypackage.test_mymodule'
