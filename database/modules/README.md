### Overview

There are two modules for creating a DocumentDB database environment.  The first creates the actual DocumentDB (MongoDB) 
cluster.  The second handles database backups.  These two modules are located in `mongodb` and `s3-backup`, 
respectively.

### Directories

| Directory Name    | Description                                                                 |
|-------------------|-----------------------------------------------------------------------------|
| `mongodb`         | Terraform module for a DocumentDB cluster.                                  |
| `s3-backup`       | Terraform module for an S3 bucket that holds database backups.              |