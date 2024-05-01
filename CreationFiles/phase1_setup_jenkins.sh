#
# ABOUT:
# 

# This document describes Phase1 how to:
# create a creation process and use it to set up a Jenkins service as a Pod in k8s, 
# in NS called devops and connect it to GIT.



##################
# creation flow:
kubectl create namespace devops
kubectl apply -f jenkins_persistent_volume.yaml
kubectl apply -f jenkins_persistent_volume_claim.yaml
kubectl apply -f jenkins_deployment.yaml
kubectl apply -f jenkins_service.yaml

#######################
# Check we're all set:
kubectl get pods -n devops
kubectl get svc -n devops

###########################
# Get the connection info:

# The web address to connect to:
JENKIS_PORT=`kubectl describe svc jenkins -n devops | grep http | grep NodePort | awk '{print $3}' | tr -d '/TCP'`
JENKIS_NODE_IP=`kubectl get nodes -o wide | grep -v INTERNAL-IP | awk '{print $6}'`

echo "Please connect to jenkis UI:"
echo "http://${JENKIS_NODE_IP}:${JENKIS_PORT}"

JENKIS_POD_NAME=`kubectl get pods -n devops | grep -v RESTARTS | awk '{print $1}'`
JENKIS_INITIAL_PWD=`kubectl exec --stdin --tty ${JENKIS_POD_NAME} -n devops -- cat /var/jenkins_home/secrets/initialAdminPassword`
echo "Use this initial password:"
echo "${JENKIS_INITIAL_PWD}"

############################################
# After the jenkis is created I need to ...
############################################

# java -jar jenkins-cli.jar -s http://<jenkins_url>/ create-user admin password123
wget http://${JENKIS_NODE_IP}:${JENKIS_PORT}/jnlpJars/jenkins-cli.jar -P /PlayGround/JenkinsAsPod/JenkisMisc/
chmod +x /PlayGround/JenkinsAsPod/JenkisMisc/jenkins-cli.jar

# Create the initial user. 
# TO DO: NOT WORKING FIX IT. Meanwhile create users manually 
#        Note : I left (in "security" "Logged in users can do anything" change it later.)
#        Consider just using the intial user.

echo 'jenkins.model.Jenkins.instance.securityRealm.createAccount("jenkins_user1", "user123")' | java -jar /PlayGround/JenkinsAsPod/JenkisMisc/jenkins-cli.jar -s "http://${JENKIS_NODE_IP}:${JENKIS_PORT}" -auth admin:${JENKIS_INITIAL_PWD} groovy = –

# -  Install necessary plugins in Jenkins for Git integration.
# https://plugins.jenkins.io/gitlab-plugin/
#kubectl exec --stdin --tty ${JENKIS_POD_NAME} -n devops -- jenkins-plugin-cli --plugins gitlab-plugin:1.8.0 && echo $?

# TEST INSTALL PLUGIN
# java -jar /PlayGround/JenkinsAsPod/JenkisMisc/jenkins-cli.jar -s "http://${JENKIS_NODE_IP}:${JENKIS_PORT}" -auth jenkins_user1:user123 install-plugin gitlab-plugin:1.8.0

# Install GitHub
java -jar /PlayGround/JenkinsAsPod/JenkisMisc/jenkins-cli.jar -s "http://${JENKIS_NODE_IP}:${JENKIS_PORT}" -auth jenkins_user1:user123 install-plugin github:1.38.0

# Install Pipelines plugin
java -jar /PlayGround/JenkinsAsPod/JenkisMisc/jenkins-cli.jar -s "http://${JENKIS_NODE_IP}:${JENKIS_PORT}" -auth jenkins_user1:user123 install-plugin workflow-aggregator:596.v8c21c963d92d

# Install kubernetes plugin (Required for phase2)
java -jar /PlayGround/JenkinsAsPod/JenkisMisc/jenkins-cli.jar -s "http://${JENKIS_NODE_IP}:${JENKIS_PORT}" -auth jenkins_user1:user123 install-plugin kubernetes:4203.v1dd44f5b_1cf9

# Restart Jenkins
kubectl delete pod ${JENKIS_POD_NAME} -n devops
JENKIS_PORT=`kubectl describe svc jenkins -n devops | grep http | grep NodePort | awk '{print $3}' | tr -d '/TCP'`
JENKIS_NODE_IP=`kubectl get nodes -o wide | grep -v INTERNAL-IP | awk '{print $6}'`
JENKIS_POD_NAME=`kubectl get pods -n devops | grep -v RESTARTS | awk '{print $1}'`
echo "Please connect to jenkis UI:"
echo "http://${JENKIS_NODE_IP}:${JENKIS_PORT}"

# For Debugging:
kubectl exec --stdin --tty ${JENKIS_POD_NAME} -n devops -- /bin/bash

