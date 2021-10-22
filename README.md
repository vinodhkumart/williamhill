# CI/CD to Kubernetes using Jenkins:
-------------------------------------------------------------------
This project is an example of a complete CI/CD pipeline of a simple nginx web application from sources to deployed Kubernetes pods.

**## Jenkins:**
Setup a [Jenkins](https://jenkins.io/) running with
-   [Docker](https://www.docker.com/). Can build and push images
-   [Kubectl](https://kubernetes.io/). Kubernetes CLI that will link Jenkins with the Kubernetes cluster

**### General notes:**
-   The Jenkins pipeline example Jenkinsfile is using calls to external cli tools such as  `docker`,  `kubectl`,  `curl`  and other shell commands. 
- Some of these can be replaced with groovy code and functions or built in pipeline steps, but are implemented like this to demonstrate the simple use of these tools.
-  The  `kubectl`  client is  **not**  configured in this example. It's assumed the Jenkins instance is pre-configured, or run it in your Kubernetes cluster, where it picks up the local pod credentials to access the Kubernetes API.

**## Build the web application:**
You can build the web application directly by running `build.sh`. You can create the Docker image and run it locally by adding kubernetes related commands to install app from the manifest file
```
# See options
$ ./build.sh --help
```
**## SAST scan:**
Since, I have using the Checkmarx from longer time , I added the Checkmarx stage in the pipeline with high rating as 1 , medium as 1 and low as 2.. It it finds the 1 high rating vulnerability , the pipeline will get failed.
