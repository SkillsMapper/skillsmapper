# Notes on project

* Define standard structure for project chapters

* How is logging handled:
  * Log with logback in p3
  * Does using logging library require permission but kubernetes logging structured logs to console not?
* How could secrets be handled better (e.g. use Secret Manager without a library)
* What are the exact costs
* How does the costs really compare to Cloud Run
* "Baking in" APIs
* Where does trace fit in?
* How do I link back to 12 factors
* 'You' not 'we'
* Combine UI / exposing?
* Add scale to projects directly e.g. memory store to p2 and spanner to p3?
* p3 CloudRun wtih spanner is what gets deployed
* Only the cloud run services get deployed to 'prod'

Add
* Direct comparison in table of both solutions
  * Compute
  * Database (hwo would spanner differ?) put that in this chapter?
    * p3 - connect with API
    * p4 - connect with proxy
  * Networking
