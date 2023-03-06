# Notes

## Database connection options

Private IP:

* via socket (internal)
* via Cloud SQL Proxy

Public IP:

* Connect via socket (internal only if not in authorised network)
* Connect via IP (if on authorised network)
* Connect via socket from authorised external network
* Connect via Cloud SQL Proxy (Cloud Run provides a proxy)

Requires Google Libraries:

]
