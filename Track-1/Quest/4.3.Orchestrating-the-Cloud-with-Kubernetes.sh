curl -o default.sh https://raw.githubusercontent.com/user9-21/GoogleCloudReady-Facilitator-program/main/files/default.sh
source default.sh

gcloud config set compute/zone us-central1-b
gcloud container clusters create io
gsutil cp -r gs://spls/gsp021/* .
cd orchestrate-with-kubernetes/kubernetes
ls
kubectl create deployment nginx --image=nginx:1.10.0
kubectl get pods
kubectl expose deployment nginx --port 80 --type LoadBalancer
kubectl get services
EXTERNAL_IP=$(kubectl get service | grep nginx | awk '{print $4}')
while [ $EXTERNAL_IP = '<pending>' ];
do sleep 2 && EXTERNAL_IP=$(kubectl get service | grep nginx | awk '{print $4}') && echo $HELLO_SERVER_EXTERNAL_IP ;
done
curl http://$EXTERNAL_IP:80

completed "Task 1"
cat pods/monolith.yaml
kubectl create -f pods/monolith.yaml
kubectl get pods
kubectl describe pods monolith
cd ~/orchestrate-with-kubernetes/kubernetes
kubectl create secret generic tls-certs --from-file tls/
kubectl create configmap nginx-proxy-conf --from-file nginx/proxy.conf
kubectl create -f pods/secure-monolith.yaml
kubectl create -f services/monolith.yaml

completed "Task 2"
gcloud compute firewall-rules create allow-monolith-nodeport --allow=tcp:31000
  
completed "Task 3"
kubectl get pods -l "app=monolith"
kubectl get pods -l "app=monolith,secure=enabled"
kubectl label pods secure-monolith 'secure=enabled'
kubectl get pods secure-monolith --show-labels
kubectl describe services monolith | grep Endpoints

completed "Task 4"
kubectl create -f deployments/auth.yaml
kubectl create -f services/auth.yaml
kubectl create -f deployments/hello.yaml
kubectl create -f services/hello.yaml
kubectl create configmap nginx-frontend-conf --from-file=nginx/frontend.conf
kubectl create -f deployments/frontend.yaml
kubectl create -f services/frontend.yaml
kubectl get services frontend

completed "Task 5"

completed "Lab"

remove_files 
