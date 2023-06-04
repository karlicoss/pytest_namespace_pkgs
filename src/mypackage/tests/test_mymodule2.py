print("MY NAME IS", __package__, __name__)
from .. import mymodule

def test_name_2():
    assert __name__ == 'mypackage.tests.test_mymodule2'
