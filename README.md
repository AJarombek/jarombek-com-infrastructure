# jarombek-com-infrastructure

AWS Infrastructure for the website [jarombek.com](https://jarombek.com).  This is application specific infrastructure, 
existing inside my [Global AWS Infrastructure](https://github.com/AJarombek/global-aws-infrastructure).

### Directories

| Directory Name         | Description                                                                 |
|------------------------|-----------------------------------------------------------------------------|
| `data-storage`         | Infrastructure for the applications persistent data storage.                |
| `jarombek-com`         | Infrastructure for the main web application.                                |
| `jarombek-com-assets`  | Infrastructure for the S3 bucket, which exposes an API for assets.          |
| `jarombek-com-fn`      | Infrastructure for the AWS Lambda functions used by the website.            |