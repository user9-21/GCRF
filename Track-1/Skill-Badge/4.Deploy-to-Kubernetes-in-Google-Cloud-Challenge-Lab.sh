curl -o default.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/default.sh
source default.sh

echo " "
read -p "${BOLD}${YELLOW}Enter Docker Image    : ${RESET}" DOCKER_IMAGE
read -p "${BOLD}${YELLOW}Enter Tag Name        : ${RESET}" TAG_NAME
read -p "${BOLD}${YELLOW}Enter Updated Version : ${RESET}" UPDATED_VERSION
read -p "${BOLD}${YELLOW}Enter Replicas Count  : ${RESET}" REPLICAS_COUNT
echo "${BOLD}"
echo "${YELLOW}Docker Image    :${CYAN} $DOCKER_IMAGE "
echo "${YELLOW}Tag Name        :${CYAN} $TAG_NAME "
echo "${YELLOW}Updated Version :${CYAN} $UPDATED_VERSION "
echo "${YELLOW}Replicas Count  :${CYAN} $REPLICAS_COUNT "
echo " "

read -p "${BOLD}${YELLOW}Verify all details are correct? [ y/n ] : ${RESET}" VERIFY_DETAILS

while [ $VERIFY_DETAILS != 'y' ];
do echo " " && 
read -p "${BOLD}${YELLOW}Enter Docker Image    : ${RESET}" DOCKER_IMAGE && 
read -p "${BOLD}${YELLOW}Enter Tag Name        : ${RESET}" TAG_NAME && 
read -p "${BOLD}${YELLOW}Enter Updated Version : ${RESET}" UPDATED_VERSION && 
read -p "${BOLD}${YELLOW}Enter Replicas Count  : ${RESET}" REPLICAS_COUNT && 
echo "${BOLD}" && 
echo "${YELLOW}Docker Image    :${CYAN} $DOCKER_IMAGE " && 
echo "${YELLOW}Tag Name        :${CYAN} $TAG_NAME " && 
echo "${YELLOW}Updated Version :${CYAN} $UPDATED_VERSION " && 
echo "${YELLOW}Replicas Count  :${CYAN} $REPLICAS_COUNT " && 
echo " " && 
read -p "${BOLD}${YELLOW}Verify all details are correct? [ y/n ] : ${RESET}" VERIFY_DETAILS ;
done

gsutil cat gs://cloud-training/gsp318/marking/setup_marking_v2.sh | bash
gcloud source repos clone valkyrie-app
cd valkyrie-app
cat > Dockerfile <<EOF
FROM golang:1.10
WORKDIR /go/src/app
COPY source .
RUN go install -v
ENTRYPOINT ["app","-single=true","-port=8080"]
EOF
docker build -t $DOCKER_IMAGE:$TAG_NAME .
cd ..
cd marking
./step1_v2.sh
completed "Task 1"

cd ..
cd valkyrie-app
docker run -p 8080:8080 $DOCKER_IMAGE:$TAG_NAME &
docker run -p 8080:8080 $DOCKER_IMAGE:$TAG_NAME &
docker push $DOCKER_IMAGE:$TAG_NAME
sleep 10
docker run -p 8080:8080 $DOCKER_IMAGE:$TAG_NAME &
cd ..
cd marking
./step2_v2.sh
completed "Task 2"

cd ..
cd valkyrie-app
docker tag $DOCKER_IMAGE:$TAG_NAME gcr.io/$GOOGLE_CLOUD_PROJECT/$DOCKER_IMAGE:$TAG_NAME
docker push gcr.io/$GOOGLE_CLOUD_PROJECT/$DOCKER_IMAGE:$TAG_NAME
completed "Task 3"

sed -i s#IMAGE_HERE#gcr.io/$GOOGLE_CLOUD_PROJECT/$DOCKER_IMAGE:$TAG_NAME#g k8s/deployment.yaml
gcloud container clusters get-credentials valkyrie-dev --zone us-east1-d
kubectl create -f k8s/deployment.yaml
kubectl create -f k8s/service.yaml
completed "Task 4"

#sed "s/replicas: 1/replicas: 4/g" kubectl edit deployment valkyrie-dev

git merge origin/kurt-dev

warning "${RED}
	Edit replicas from ${CYAN}1${RED} to ${CYAN}$REPLICAS_COUNT${RED}.
	Edit image from ${CYAN}$TAG_NAME${RED} to ${CYAN}$UPDATED_VERSION${RED}.
	Make Sure you edited at ${BLUE}two places${RED} inside valkyrie-dev
${YELLOW}
		Press '${CYAN}i${YELLOW}' to start editing

		To ${RED}EXIT${YELLOW}, Press ${CYAN}Esc${YELLOW}, then ${CYAN}:wq${YELLOW}
"
sleep 15
kubectl edit deployment valkyrie-dev
completed "Task 5"
docker build -t gcr.io/$GOOGLE_CLOUD_PROJECT/$DOCKER_IMAGE:$UPDATED_VERSION .
docker push gcr.io/$GOOGLE_CLOUD_PROJECT/$DOCKER_IMAGE:$UPDATED_VERSION


echo "${MAGENTA}"
docker ps
docker kill $(docker ps -q)

completed "Task 6"
export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/component=jenkins-master" -l "app.kubernetes.io/instance=cd" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward $POD_NAME 8080:8080 >> /dev/null &
printf $(kubectl get secret cd-jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo


warning "
Now, ${CYAN}Web Preview on port 80${YELLOW} to open jenkins
	${RED}${BOLD}Username    : ${CYAN}admin
	${RED}${BOLD}Password    : ${CYAN}$(kubectl get secret cd-jenkins -o jsonpath='{.data.jenkins-admin-password}' | base64 --decode)${YELLOW}
	 - Click ${CYAN}Manage Jenkins ${YELLOW}
	 - Click ${CYAN}Manage Credentials ${YELLOW}
	 - Click ${CYAN}global ${YELLOW}
	 - Click ${CYAN}ading some credentials?${YELLOW}
	 - Select ${CYAN}Google Service Account fromm metadata ${YELLOW} 
	 - Click ok to Create credentials
	 - Now, go to dashboard and Click new item 
	 - item Name :${CYAN} valkyrie-app${YELLOW}
	 - select ${CYAN}pipeline${YELLOW} project  and click ok 
	 - Definition :${CYAN} Pipeline script from SCM${YELLOW} 
	 - SCM :${CYAN} git${YELLOW} 
	 - Repository URL :${CYAN} $(gcloud source repos list --format='value(URL)')${YELLOW} 
	 - Credentials :${CYAN} $PROJECT_ID service account${YELLOW} 
	 - Click save 
	 
	Now Proceed with cloudShell"
warning "
	${RED}${BOLD}Username       : ${CYAN}admin
	${RED}${BOLD}Password       : ${CYAN}$(kubectl get secret cd-jenkins -o jsonpath='{.data.jenkins-admin-password}' | base64 --decode)
	${RED}${BOLD}Repository URL : ${CYAN}$(gcloud source repos list --format='value(URL)')"



read -p "${BOLD}${YELLOW}Pipeline valkyrie-app saved? [ y/n ] : ${RESET}" PROCEED1

while [ $PROCEED1 != 'y' ];
do echo "Do it Manually" && read -p "${BOLD}${YELLOW}Pipeline valkyrie-app saved? [ y/n ] : ${RESET}" PROCEED1;
done

sed -i "s/green/orange/g" source/html.go
sed -i "s/YOUR_PROJECT/$GOOGLE_CLOUD_PROJECT/g" Jenkinsfile
git config --global user.email $EMAIL 
git config --global user.name $USER
git add .
git commit -m "initialized Pipeline"
git push
warning " Now Click Build now and wait for build to be created 

After Build created, Proceed with CloudShell "
read -p "${BOLD}${YELLOW}Build created? [ y/n ] : ${RESET}" PROCEED2

while [ $PROCEED2 != 'y' ];
do echo "Do it Manually" && read -p "${BOLD}${YELLOW}Build created? [ y/n ] : ${RESET}" PROCEED2;
done
completed "Task 7"

completed "Lab"

remove_files 