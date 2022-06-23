curl -o default.sh https://raw.githubusercontent.com/user9-21/GoogleCloudReady-Facilitator-program/main/files/default.sh
source default.sh

gcloud config set compute/zone us-east1-d
git clone https://github.com/GoogleCloudPlatform/continuous-deployment-on-kubernetes.git
cd continuous-deployment-on-kubernetes
gcloud container clusters create jenkins-cd \
--num-nodes 2 \
--machine-type n1-standard-2 \
--scopes "https://www.googleapis.com/auth/source.read_write,cloud-platform"

completed "Task 1"
gcloud container clusters list
gcloud container clusters get-credentials jenkins-cd
kubectl cluster-info
helm repo add jenkins https://charts.jenkins.io
helm repo update
gsutil cp gs://spls/gsp330/values.yaml jenkins/values.yaml
tput bold; tput setaf 3 ;echo iNSTALLING hELM; tput sgr0;
tput bold; tput setaf 3 ;echo it can take upto 20 minutes. If taking more than 20 mins cancel by pressing CTRL + C and install another helm chart you can try below mentioned code  ; tput sgr0;
while sleep 1;do tput sc;tput cup 0 $(($(tput cols)-11));echo -e "\e[1;97m`date +%r`\e[39m";tput rc;done &
helm install cd jenkins/jenkins -f jenkins/values.yaml --wait
sleep 20

completed "Task 2"
kubectl get pods

kubectl create clusterrolebinding jenkins-deploy --clusterrole=cluster-admin --serviceaccount=default:cd-jenkins
export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/component=jenkins-master" -l "app.kubernetes.io/instance=cd" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward $POD_NAME 8080:8080 >> /dev/null &
tput bold; tput setaf 3 ;echo WEB PREVIEW ON PORT 80; tput sgr0;
#Preview on Port 80
sleep 20
tput bold; tput setaf 3 ;echo Helm installed? If yes procced else run this; tput sgr0;
tput bold; tput setab 2 ;echo '
helm install cdd jenkins/jenkins -f jenkins/values.yaml --wait
kubectl create clusterrolebinding jenkins-deploy --clusterrole=cluster-admin --serviceaccount=default:cd-jenkins
export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/component=jenkins-master" -l "app.kubernetes.io/instance=cd" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward $POD_NAME 8080:8080 >> /dev/null &
kubectl get svc
printf $(kubectl get secret cd-jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo
'; tput sgr0;

kubectl get svc
printf $(kubectl get secret cd-jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo

cd sample-app
kubectl create ns production
kubectl apply -f k8s/production -n production
kubectl apply -f k8s/canary -n production
kubectl apply -f k8s/services -n production

completed "Task 3"
kubectl scale deployment gceme-frontend-production -n production --replicas 4
kubectl get pods -n production -l app=gceme -l role=frontend
kubectl get pods -n production -l app=gceme -l role=backend
kubectl get service gceme-frontend -n production

export FRONTEND_SERVICE_IP=$(kubectl get -o jsonpath="{.status.loadBalancer.ingress[0].ip}" --namespace=production services gceme-frontend)
curl http://$FRONTEND_SERVICE_IP/version
gcloud source repos create default

completed "Task 4"
git init
git config credential.helper gcloud.sh
git remote add origin https://source.developers.google.com/p/$DEVSHELL_PROJECT_ID/r/default
git config --global user.email "$(gcloud config get-value core/account)"
git config --global user.name "$(gcloud config get-value core/account)"
git add .
git commit -m "Initial commit"
git push origin master

completed "Lab"

remove_files 
