curl -o default.sh https://raw.githubusercontent.com/user9-21/GoogleCloudReady-Facilitator-program/main/files/default.sh
source default.sh

gcloud config set compute/zone us-central1-a
gsutil -m cp -r gs://spls/gsp053/orchestrate-with-kubernetes .
cd orchestrate-with-kubernetes/kubernetes
gcloud container clusters create bootcamp --num-nodes 5 --scopes "https://www.googleapis.com/auth/projecthosting,storage-rw"
cat deployments/auth.yaml
sed -i "s/auth:2.0.0/auth:1.0.0/g" deployments/auth.yaml
cat deployments/auth.yaml
kubectl create -f deployments/auth.yaml
kubectl get deployments
kubectl get replicasets
sleep 40
kubectl get pods
kubectl create -f services/auth.yaml
kubectl create -f deployments/hello.yaml
kubectl create -f services/hello.yaml
kubectl create secret generic tls-certs --from-file tls/
kubectl create configmap nginx-frontend-conf --from-file=nginx/frontend.conf
kubectl create -f deployments/frontend.yaml
kubectl create -f services/frontend.yaml
sleep 40
kubectl get services frontend
curl -ks https://`kubectl get svc frontend -o=jsonpath="{.status.loadBalancer.ingress[0].ip}"`


completed "Task 1"


kubectl explain deployment.spec.replicas
kubectl scale deployment hello --replicas=5
kubectl get pods | grep hello- | wc -l
kubectl scale deployment hello --replicas=3
kubectl get pods | grep hello- | wc -l

sed -i "s/hello:1.0.0/hello:2.0.0/g" deployments/hello.yaml
cat deployments/hello.yaml
kubectl get replicaset
kubectl rollout history deployment/hello
kubectl rollout pause deployment/hello
kubectl rollout status deployment/hello
kubectl get pods -o jsonpath --template='{range .items[*]}{.metadata.name}{"\t"}{"\t"}{.spec.containers[0].image}{"\n"}{end}'
kubectl rollout resume deployment/hello
kubectl rollout status deployment/hello
kubectl rollout undo deployment/hello
kubectl rollout history deployment/hello
kubectl get pods -o jsonpath --template='{range .items[*]}{.metadata.name}{"\t"}{"\t"}{.spec.containers[0].image}{"\n"}{end}'

cat deployments/hello-canary.yaml
kubectl create -f deployments/hello-canary.yaml
kubectl get deployments

curl -ks https://`kubectl get svc frontend -o=jsonpath="{.status.loadBalancer.ingress[0].ip}"`/version
kubectl apply -f services/hello-blue.yaml
kubectl create -f deployments/hello-green.yaml
curl -ks https://`kubectl get svc frontend -o=jsonpath="{.status.loadBalancer.ingress[0].ip}"`/version
kubectl apply -f services/hello-green.yaml
curl -ks https://`kubectl get svc frontend -o=jsonpath="{.status.loadBalancer.ingress[0].ip}"`/version
kubectl apply -f services/hello-blue.yaml
curl -ks https://`kubectl get svc frontend -o=jsonpath="{.status.loadBalancer.ingress[0].ip}"`/version
completed "Task 2"

completed "Lab"

remove_files 
