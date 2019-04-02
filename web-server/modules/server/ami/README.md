### Overview

Directories containing a Hashicorp Packer image for an AMI.  Each directory corresponds to a single AMI.  First I start 
with a `base` AMI, which contains all the application dependencies.  Second I create an `app` AMI, which adds the 
application on top of the base AMI.  Finally, I add environment specific configuration to the `app` AMI.  There are two 
environment specific AMIs - `dev` and `prod`.  The AMI tree is as follows:

```
> base
-> app
--> dev
-> app
--> prod
```

### Directories

| Directory Name    | Description                                                                 |
|-------------------|-----------------------------------------------------------------------------|
| `base`            | Creates a `base` AMI containing application dependencies.                   |
| `app`             | Creates an `app` AMI containing the web application.                        |
| `dev`             | Creates a `dev` AMI for the *DEV* environment.                              |
| `prod`            | Creates a `prod` AMI for the *PROD* environment.                            |
| `shared`          | Shared files used by multiple AMIs.                                         |