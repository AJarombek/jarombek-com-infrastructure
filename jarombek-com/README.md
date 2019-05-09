### Overview

Infrastructure for the web application and database.  Both are containerized and exist in an ECS cluster.  The 
web application is a Node.js/React app based on the [jarombek-com](https://github.com/AJarombek/jarombek-com) 
repository.  The database in MongoDB with contents equivalent to those in the 
[jarombek-com-database](https://github.com/AJarombek/jarombek-com-database) repository.

### Directories

| Directory Name    | Description                                                                 |
|-------------------|-----------------------------------------------------------------------------|
| `env`             | Code to build website infrastructure for *DEV* and *PROD* environments.     |
| `modules`         | Modules for building the web server and database for `jarombek.com`.        |