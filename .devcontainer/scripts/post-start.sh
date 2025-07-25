#!/bin/bash

echo "post-start start" >>  ~/.status.log 

# this runs in background each time the container starts

# Ensure kubeconfig is set up. 
k3d kubeconfig merge dev --kubeconfig-merge-default | tee -a ~/.status.log 

# DANE: This script looks like it needs to run in a GitHub Codespace, so I'm going to comment it out for now.
# bash .devcontainer/scripts/update-repo-for-workshop.sh | tee -a  ~/.status.log 

# Wit for Argo CD to be ready
kubectl rollout status -n argocd sts/argocd-application-controller | tee -a  ~/.status.log

# Wait for the port to be ready
counter=0
until [[ $(curl -s -o /dev/null -w "%{http_code}" localhost:30272) -eq 307 ]]
do
    echo "Waiting for Argo CD endpoint to be ready..." | tee -a  ~/.status.log
    sleep 3
    counter=$((counter+1))
    if [[ $counter -gt 60 ]]; then
        echo "Port not available for Argo CD CLI" | tee -a  ~/.status.log
        exit 1
    fi
done

# Update Argo CD Admin Password
argopass=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 -d)
argouri="localhost:30272"
argonewpass="password"
argocd login --insecure --username ${argouser:=admin} --password ${argopass} --grpc-web ${argouri} | tee -a  ~/.status.log 
argocd account --insecure update-password --insecure --current-password ${argopass} --new-password ${argonewpass} | tee -a  ~/.status.log 

# Install Argo Rollouts Controller - https://argo-rollouts.readthedocs.io/en/stable/installation/#controller-installation
kubectl create namespace argo-rollouts | tee -a  ~/.status.log 
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml | tee -a  ~/.status.log


# Update Argo CD to use cluster-admin service account for sync operations in the "default" project
kubectl apply -f .devcontainer/manifests/argo-configupdate.yaml | tee -a  ~/.status.log


# NB: I expect this to fail when running locally, so I'm going to see what I get without it.
# Patch URL value. Probably can do this via helm in the "post-create.sh" script. PRs are welcome
# kubectl patch cm/argocd-cm -n argocd --type=json  -p="[{\"op\": \"replace\", \"path\": \"/data/url\", \"value\":\"https://${CODESPACE_NAME}-30272.app.github.dev\"}]" | tee -a  ~/.status.log

# Best effort env load
source ~/.bashrc

echo "post-start complete" >>  ~/.status.log 