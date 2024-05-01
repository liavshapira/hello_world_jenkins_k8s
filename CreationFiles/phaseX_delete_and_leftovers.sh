#################
# Environment Deletion flow:

# Verify entities in NS before deletion
kubectl get all -n stamns
kubectl get all -n ns4finaltest

# Delete extra ns
kubectl delete namespace ns4finaltest
kubectl delete namespace stamns

kubectl delete -f jenkins_service.yaml
kubectl delete -f jenkins_deployment.yaml
kubectl delete -f jenkins_persistent_volume_claim.yaml
kubectl delete -f jenkins_persistent_volume.yaml
kubectl delete namespace devops


rm -rf /PlayGround/JenkinsAsPod/JenkisMisc/*
rm -rf /PlayGround/JenkinsAsPod/DataFiles/*


####
# A good source for below workflow actions:
# https://www.youtube.com/watch?v=U9Xnn4qi-qg&t=43s
# 
# in Jenkins UI go to test_gitlab_connection --> Dashboar --> new item --> Create freestyle project named: "test_gitlab_connection"
# In "General" add description: "test conn to GitLab"
# In " Source Code Management" select "Git" and past the gitlab URL. E.G:
# https://gitlab.com/jenkis_creation_flow/test_gitlab_project
# (if u exited: Dashboard --> test_gitlab_connection --> Configuration) 
# u will get error message such as "... stderr: remote: HTTP Basic: Access denied... "

# Obtain from GitLab a PAT go to: Group: jenkis_creation_flow --> Project: test_gitlab_project --> Access Tokens 
# (if needed create the PAT from the user level [from avatart --> preferences])


# -  Create GitLab API credentials in Jenkins.

# -  Set up Jenkins pipeline jobs to fetch code from GitLab repositories and trigger builds.


