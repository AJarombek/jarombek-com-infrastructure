### Overview

Module which creates HTTPS certificates for `jarombek.com`, `*.jarombek.com` (`www.jarombek.com` and 
`dev.jarombek.com`), and `*.dev.jarombek.com` (`www.dev.jarombek.com`).  Wildcard certificates are used for both the dev 
website and `www` prefixed domains.

### Files

| Filename     | Description                                                                                      |
|--------------|--------------------------------------------------------------------------------------------------|
| `main.tf`    | Generate HTTPS certificates and confirm they are validated.                                      |