#
# ABOUT
# 

# This document describes Phase2 how to:
# create a Jenkins pipeline type process that uses the created Jenkins,
# which builds a specific web application in NS, based on .netCore
# and then deploys and uploads it as a website on another NS.


kubectl create namespace stamns

JENKIS_PORT=`kubectl describe svc jenkins -n devops | grep http | grep NodePort | awk '{print $3}' | tr -d '/TCP'`
JENKIS_NODE_IP=`kubectl get nodes -o wide | grep -v INTERNAL-IP | awk '{print $6}'`
JENKIS_POD_NAME=`kubectl get pods -n devops | grep -v RESTARTS | awk '{print $1}'`
echo "Please connect to jenkis UI:"
echo "http://${JENKIS_NODE_IP}:${JENKIS_PORT}"

# Source: https://plugins.jenkins.io/kubernetes/
# TO DO: Change Manual flow to CLI.
# Dashboard -> Manage Jenkins -> Clouds -> "New cloud" (and create a new K8S cloud)


# 
K8S_URL=`kubectl get all | grep "service/kubernetes" | awk '{print $3}'`
# Don't use the "kubectl cluster-info" output (127.0.01). 

# http://<service-name>.<namespace>:service-port>
# http://jenkins.devops:8080
# AND NOT the external ! : K8S_PORT=`kubectl get all | grep "service/kubernetes" | awk '{print $5}' | tr -d "/TCP"`
# explanation on this: https://www.youtube.com/watch?v=GNujTivkM7s

# Inputs:
echo "Kubernetes URL is https://${K8S_URL}:${K8S_PORT}"
# echo "Jenkins URL is http://${JENKIS_NODE_IP}:${JENKIS_PORT}"

# use the "test connection" button to verify connection.

# "Kubernetes Namespace" -> stamns


###########################
# The pipeline script:
// Uses Declarative syntax to run commands inside a container.
pipeline {
    agent {
        kubernetes {
            // Rather than inline YAML, in a multibranch Pipeline you could use: yamlFile 'jenkins-pod.yaml'
            // Or, to avoid YAML:
            // containerTemplate {
            //     name 'shell'
            //     image 'ubuntu'
            //     command 'sleep'
            //     args 'infinity'
            // }
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: shell
    image: ubuntu
    command:
    - sleep
    args:
    - infinity
'''
            // Can also wrap individual steps:
            // container('shell') {
            //     sh 'hostname'
            // }
            defaultContainer 'shell'
        }
    }
    stages {
        stage('Main') {
            steps {
                //sh 'hostname'
                echo "Hello from K8S"
            }
        }
    }
}

# EOF



##############
# Create App #
##############

# Download and install the .NET SDK on my ubuntu PC:
# Source: https://dotnet.microsoft.com/en-us/learn/dotnet/hello-world-tutorial/intro
#         https://learn.microsoft.com/en-us/dotnet/core/install/linux-ubuntu-install?pivots=os-linux-ubuntu-2204&tabs=dotnet8
# Note to myself: I followed the instruction in the 1st web site. Below is not elaborated. 
sudo apt-get update && \
  sudo apt-get install -y dotnet-sdk-8.0

sudo apt-get update && \
  sudo apt-get install -y aspnetcore-runtime-8.0

# VSCODE - already installed
# Install plugin: "C# Dev Kit for Visual Studio Code"

# App name mkdir LiavApp1
mkdir /PlayGround/JenkinsAsPod/LiavApp1
# App path: /PlayGround/JenkinsAsPod/LiavApp1

#######################
# TO DO (In General): #
#######################

# Main actions left to complete this task:

# Create the jenkins file:

# Define Stages: 

# - Checkout: Check out my code from Git (Maybe I'll do everythin inside GitHus?).
# - Build: Build my .NET Core app (use MSBuild or dotnet CLI?)
# - Test: use curl for testing it (just to see the hello world).
# - Package: Package my app. (use Gitlab artifatcs / Nexus / GitHub ?)
# - Deploy: Deploy app to the target environment: K8S pod in NS "staging".
# - Deploy: Deploy website to target environment: K8S pod in NS "websitens".
# - Cleanup: Clean up any temporary files or artifacts.

# Agent Configuration: Specify the agent (either Docker, Kubernetes, or Jenkins agent) where your pipeline will run.


