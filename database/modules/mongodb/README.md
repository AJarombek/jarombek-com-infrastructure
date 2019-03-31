### Overview

Module for creating DocumentDB (MongoDB) infrastructure.  Currently just creates a DocumentDB database for 
`jarombek.com` in a given environment.

### Files

| Filename          | Description                                                                                      |
|-------------------|--------------------------------------------------------------------------------------------------|
| `main.tf`         | Main Terraform script for the MongoDB module.  Creates a database in a given environment.        |
| `var.tf`          | Variables to pass into the main Terraform script.                                                |