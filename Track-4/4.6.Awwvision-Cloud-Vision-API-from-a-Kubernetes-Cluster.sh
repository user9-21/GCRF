curl -o default.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/default.sh
source default.sh

gcloud config set compute/zone us-central1-a
gcloud container clusters create awwvision \
    --num-nodes 2 \
    --scopes cloud-platform

completed "Task 1"
gcloud container clusters get-credentials awwvision
kubectl cluster-info
sudo apt-get update
sudo apt-get install virtualenv -y

virtualenv -p python3 venv
source venv/bin/activate
gsutil -m cp -r gs://spls/gsp066/cloud-vision .
cd cloud-vision/python/awwvision
make all
kubectl get pods
kubectl get deployments -o wide
kubectl get svc awwvision-webapp

completed "Task 2"

echo kubectl get svc awwvision-webapp

completed "Lab"

remove_files