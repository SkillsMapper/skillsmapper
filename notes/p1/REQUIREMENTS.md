# Tag Loader

* Cloud Function
* Cloud Tasks
* Query BigQuery (public dataset)
* Write to Cloud Storage
* Run once a week

## Requirements

##### User Story
* As a user, I would like an up-to-date list of skills to choose from so the terms I use are consistent and comparable with my peers.

##### Detailed Requirements
* The list of skills should be comprehensive and unambiguous.
* New technologies emerge frequently but not every day. Limiting updates to weekly is sufficient.
* The solution should be reliable and low-cost.
* The resultant list should be easy to consume by future services.

##### Proposed Solutions
* Google Cloud has a public dataset containing data from StackOverflow. This is available in BigQuery. We can extract the tags used in StackOverflow as an up-to-date list of potential skills.
* Storing the resultant list of skills as a file in Cloud Storage will make it easy to consume by other services.
* Using Cloud Storage also means the list of skills can automatically be versioned.
* We need a small amount of code to extract StackOverflow tags from the BigQuery dataset and to store the resultant list of skills as a file in Cloud Storage. Cloud Functions is an effective way of running code.
* Cloud Tasks can be used to schedule the execution of Cloud Functions. We can use this to create a new list of skills every week and retry if there is a failure.

##### Diagram

##### Implementation
This is an example of needing to run a small amount of code on a regular basis. 

This is where the cloud shines, a simple task that does not need to be executed often.

On-prem, this is likely a script executed by a cron job. You are unlikely to need a dedicated server or VM to do this, but you need a machine you can use.

You would also need shared storage to store the file and network connectivity setup to collect information from StackOverflow. All this could be surprisingly time-consuming, with many steps and possible approvals.

Our solution will show how we can achieve the requirement in a self-service, secure and efficient way. Let's look at the services we will use.

### Cloud Functions

Google Cloud has several options for running code. To start with we will use Cloud Functions as it is the simplest and most cost-effective. This is Google's serverless offering and the nearest 
equivalent to AWS Lambda or Azure Functions. It is great for running the sort of "glue code" we need for this service.

Cloud Functions has two generations. We will concentrate on generation 2 as it is more flexible and has a larger memory limit. Code can be written in Node.js, Python, Go, Java, Ruby, PHP or .Net 
Core. 
[https://cloud.google.
com/functions/docs/concepts/execution-environment#runtimes]. Code is automatically packaged into a 
managed container that is invoked by an event but the container itself is hidden from you. You can use a [maximum of 16 GiB of memory, 4 vCPU cores and execute for a maximum of 60 minutes]
(https://cloud.google.com/functions/quotas).  This is a big improvement on
generation 1 which had a maximum of 8 GiB of memory and 9 minutes of execution time. However, the default of a maximum of 60 seconds, 1 vCPU core and 256MB of memory for be sufficient for this.

In fact Cloud Functions generation 2 is effectively a wrapper around Cloud Run and Cloud Build which we will use in the next
chapter. Cloud Run is a managed container platform that allows you to run containers that are invocable via HTTP requests. Cloud Build is a managed build service that allows you to build containers.

### Cloud Scheduler
Cloud Scheduler is a fully managed enterprise-grade cron job scheduler. In this case we are going to use it to schedule the execution of our Cloud Function.

https://www.youtube.com/watch?v=gle26fT28Bw&t=366s
