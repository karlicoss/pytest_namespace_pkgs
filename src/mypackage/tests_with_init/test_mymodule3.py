print("MY NAME IS", __package__, __name__)
from .. import mymodule

def test_name_3():
    assert __name__ == 'mypackage.tests_with_init.test_mymodule3'
