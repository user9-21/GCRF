curl -o default.sh https://raw.githubusercontent.com/user9-21/GoogleCloudReady-Facilitator-program/main/files/default.sh
source default.sh

gcloud config set compute/zone us-central1-a
gcloud container clusters create my-cluster

completed "Task 1"

gcloud container clusters get-credentials my-cluster
kubectl create deployment hello-server --image=gcr.io/google-samples/hello-app:1.0

completed "Task 2"

kubectl expose deployment hello-server --type=LoadBalancer --port 8080
kubectl get service

HELLO_SERVER_EXTERNAL_IP=$(kubectl get service | grep hello-server | awk '{print $4}')
while [ $HELLO_SERVER_EXTERNAL_IP = '<pending>' ];
do sleep 2 && HELLO_SERVER_EXTERNAL_IP=$(kubectl get service | grep hello-server | awk '{print $4}') && echo $HELLO_SERVER_EXTERNAL_IP ;
done

completed "Task 3"

gcloud container clusters delete my-cluster

completed "Task 4"

completed "Lab"
warning "Verify Score on Lab Page before Removing files"
remove_files 
