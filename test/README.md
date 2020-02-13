### Overview

This is the testing suite for `jarombek-com-infrastructure`.  Tests are run in Python using Amazon's boto3 module.  
Each infrastructure grouping has its own test suite.  Each test suite contains many individual tests.  Test suites can 
be run independently or all at once.

To run all test suites at once, execute the following command from this directory:

```bash
pip3 install -r requirements.txt
python3 runner.py
```

If an error occurs on Mac OS saying `[SSL: CERTIFICATE_VERIFY_FAILED]`, use the following bash command (change the 
Python version as needed):

```bash
/Applications/Python\ 3.8/Install\ Certificates.command
```

### Files

| Filename             | Description                                                                                  |
|----------------------|----------------------------------------------------------------------------------------------|
| `suites/`            | Test suites for each infrastructure grouping.                                                |
| `utils/`             | Python functions reused throughout the test suites.                                          |
| `requirements.txt`   | Python dependencies used with pip.                                                           |
| `runner.py`          | Python `unittest` runner which runs the test suites.                                         |

### Resources

1) [unittest Python Documentation](https://docs.python.org/3/library/unittest.html)
2) [ECS boto3 Documentation](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ecs.html)
3) [MacOS SSL Certificates Failed](https://stackoverflow.com/a/42334357)