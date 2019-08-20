### Overview

This is the testing suite for `jarombek-com-infrastructure`.  Tests are run in Python using Amazon's boto3 module.  
Each infrastructure grouping has its own test suite.  Each test suite contains many individual tests.  Test suites can 
be run independently or all at once.

To run all test suites at once, execute the following command from this directory:

```
python3 runner.py
```

### Files

| Filename             | Description                                                                                  |
|----------------------|----------------------------------------------------------------------------------------------|
| `suites/`            | Test suites for each infrastructure grouping.                                                |
| `utils/`             | Python functions reused throughout the test suites.                                          |
| `runner.py`          | Python `unittest` runner which runs the test suites.                                         |

### Resources

[1] [unittest Python Documentation](https://docs.python.org/3/library/unittest.html)

[2] [ECS boto3 Documentation](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ecs.html)