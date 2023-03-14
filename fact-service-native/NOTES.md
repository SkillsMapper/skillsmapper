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

https://spring-gcp.saturnism.me/

=== Start with Cloud Run

* Fast startup e.g. Go 1s
* Cloud Run with a Dockerfile
* Cloud SQL with a proxy
* Can Cloud run do multi-region

Disadvantages:
* Notice how slow it is to upload and deploy compared to Go.

=== When to switch to GKE Autopilot

* Slow startup e.g. Java - 20s
* When running 24/7 or millions of requests
* Multi-region
* GKE Autopilot
* Cloud SQL without a proxy
* Need to use sidecars

Disadvantages:
* More complex to expose (service + Ingress)

=== Cost

* Autopilot clusters accrue a flat fee of $0.10/hour for each cluster after the free tier

=== When to Switch to GKE Classic

* GKE slow to deploy as pods pending while cluster spins up - minutes to stabilise
