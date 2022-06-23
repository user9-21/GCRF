curl -o default.sh https://raw.githubusercontent.com/user9-21/GoogleCloudReady-Facilitator-program/main/files/default.sh
source default.sh

gcloud config set compute/zone us-east1-d
git clone https://github.com/GoogleCloudPlatform/continuous-deployment-on-kubernetes.git
cd continuous-deployment-on-kubernetes
gcloud container clusters create jenkins-cd \
--num-nodes 2 \
--machine-type n1-standard-2 \
--scopes "https://www.googleapis.com/auth/projecthosting,cloud-platform"

completed "Task 1"

gcloud container clusters list
gcloud container clusters get-credentials jenkins-cd
kubectl cluster-info
helm repo add stable https://charts.helm.sh/stable
helm repo update
warning " iNSTALLING hELM
it can take upto 10 minutes. If taking more than 10 mins cancel by pressing 'CTRL + C' and install another helm chart you can try below mentioned code"


while sleep 1;do tput sc;tput cup 0 $(($(tput cols)-11));echo -e "\e[1;97m`date +%r`\e[39m";tput rc;done &
helm install cd stable/jenkins -f jenkins/values.yaml --version 1.2.2 --wait

completed "Task 2"
kubectl get pods
export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/component=jenkins-master" -l "app.kubernetes.io/instance=cd" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward $POD_NAME 8080:8080 >> /dev/null &
kubectl get svc
printf $(kubectl get secret cd-jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo


completed "Lab"

remove_files 