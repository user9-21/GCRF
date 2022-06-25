curl -o default.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/default.sh
source default.sh


echo " "
read -p "${BOLD}${YELLOW}Enter Version : ${RESET}" VERSION
read -p "${BOLD}${YELLOW}Enter Colour  : ${RESET}" COLOUR
echo "${BOLD}" 
echo "${YELLOW}Version :${CYAN} $VERSION "
echo "${YELLOW}Colour  :${CYAN} $COLOUR "
echo " "

read -p "${BOLD}${YELLOW}Verify all details are correct? [ y/n ] : ${RESET}" VERIFY_DETAILS

while [ $VERIFY_DETAILS != 'y' ];
do echo " " && 
read -p "${BOLD}${YELLOW}Enter Version : ${RESET}" VERSION && 
read -p "${BOLD}${YELLOW}Enter Colour  : ${RESET}" COLOUR && 
echo "${BOLD}"  && 
echo "${YELLOW}Version :${CYAN} $VERSION " && 
echo "${YELLOW}Colour  :${CYAN} $COLOUR " && 
echo " " && 
read -p "${BOLD}${YELLOW}Verify all details are correct? [ y/n ] : ${RESET}" VERIFY_DETAILS ;
done

gcloud config set compute/zone us-east1-b
git clone https://source.developers.google.com/p/$DEVSHELL_PROJECT_ID/r/sample-app

gcloud container clusters get-credentials jenkins-cd
kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$(gcloud config get-value account)
helm repo add stable https://kubernetes-charts.storage.googleapis.com/  → this might not work… use the next line of code instead…
helm repo add stable https://charts.helm.sh/stable
helm repo update
helm install cd stable/jenkins
kubectl get pods

sleep 10

function ConfigureJenkins{
export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/component=jenkins-master" -l "app.kubernetes.io/instance=cd" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward $POD_NAME 8080:8080 >> /dev/null &
printf $(kubectl get secret cd-jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo

warning "
Now, ${CYAN}Web Preview on port 80 -${MAGENTA} https://shell.cloud.google.com/devshell/proxy?authuser=0&port=8080&environment_id=default ${YELLOW} to open jenkins
	${RED}${BOLD}Username    : ${CYAN}admin
	${RED}${BOLD}Password    : ${CYAN}$(kubectl get secret cd-jenkins -o jsonpath='{.data.jenkins-admin-password}' | base64 --decode)${YELLOW}
	 - Click ${CYAN}Manage Jenkins ${YELLOW}
	 - Click ${CYAN}Manage Credentials ${YELLOW}
	 - Click ${CYAN}global ${YELLOW}
	 - Click ${CYAN}ading some credentials?${YELLOW}
	 - Select ${CYAN}Google Service Account fromm metadata ${YELLOW} 
	 - Click ok to Create credentials
	 - Now, go to dashboard and Click new item 
	 - item Name :${CYAN} sample-app${YELLOW}
	 - select ${CYAN}Multibranch Pipeline${YELLOW} project  and click ok 
	 - Under Branch Sources, Click Add Source and select${CYAN} Git${YELLOW}  
	 - Project Repository :${CYAN} $(gcloud source repos list --format='value(URL)')${YELLOW} 
	 - Credentials :${CYAN} $PROJECT_ID service account${YELLOW} 
	 - Under Scan Multibranch Pipeline Triggers, Check ${GREEN}Periodically if not otherwise run${YELLOW}
	 - Interval :${CYAN} 1 minute${YELLOW}
	 - Click save 
	 
	Now Proceed with cloudShell"
warning "
	${RED}${BOLD}Username       : ${CYAN}admin
	${RED}${BOLD}Password       : ${CYAN}$(kubectl get secret cd-jenkins -o jsonpath='{.data.jenkins-admin-password}' | base64 --decode)
	${RED}${BOLD}Repository URL : ${CYAN}$(gcloud source repos list --format='value(URL)')"

}

ConfigureJenkins

warning "If error in sample-app pipeline, retry"

read -p "${BOLD}${YELLOW}sample-app created? [ y/n ] : ${RESET}" PROCEED1

while [ $PROCEED1 != 'y' ];
do echo "Do it Manually" && read -p "${BOLD}${YELLOW}sample-app created? [ y/n ] : ${RESET}" PROCEED1;
done

completed "Task 1"

cd sample-app
kubectl create ns production
kubectl apply -f k8s/production -n production
kubectl apply -f k8s/canary -n production
kubectl apply -f k8s/services -n production
sed -i s/1.0.0/$VERSION/g main.go
sed -i s/blue/$COLOUR/g html.go

kubectl get svc
kubectl get service gceme-frontend -n production


git init
git config credential.helper gcloud.sh
git remote add origin https://source.developers.google.com/p/$DEVSHELL_PROJECT_ID/r/sample-app
git config --global user.email $EMAIL
git config --global user.name $USER
git add .
git commit -m "initial commit"
git push origin master


completed "Task 2"

sleep 30

git checkout -b new-feature

#sed -i -- 's/nginx/Google Cloud Platform - '"\$HOSTNAME"'/' /var/www/html/index.nginx-debian.html


git add Jenkinsfile html.go main.go
git commit -m "Version 2.0.0"
git push origin new-feature


sleep 70

curl http://localhost:8001/api/v1/namespaces/new-feature/services/gceme-frontend:80/proxy/version
kubectl get service gceme-frontend -n production
git checkout -b canary
git push origin canary

sleep 100

export FRONTEND_SERVICE_IP=$(kubectl get -o \
jsonpath="{.status.loadBalancer.ingress[0].ip}" --namespace=production services gceme-frontend)
git checkout master
git push origin master
completed "Task 3"


export FRONTEND_SERVICE_IP=$(kubectl get -o \
jsonpath="{.status.loadBalancer.ingress[0].ip}" --namespace=production services gceme-frontend)
warning "http://$FRONTEND_SERVICE_IP/version"
sleep 5
while true; do curl http://$FRONTEND_SERVICE_IP/version; sleep 1; done

kubectl get service gceme-frontend -n production
git merge canary
git push origin master
export FRONTEND_SERVICE_IP=$(kubectl get -o \
jsonpath="{.status.loadBalancer.ingress[0].ip}" --namespace=production services gceme-frontend)
completed "Task 4"

completed "Lab"

warning "Lab will be completed only after all jenking Branch successfully deployed.
	Kindly Wait"

remove_files 