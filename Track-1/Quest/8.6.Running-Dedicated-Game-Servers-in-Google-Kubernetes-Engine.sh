curl -o default.sh https://raw.githubusercontent.com/user9-21/GoogleCloudReady-Facilitator-program/main/files/default.sh
source default.sh

gcloud compute instances create instance --zone=us-central1-a --machine-type=e2-medium --scopes=https://www.googleapis.com/auth/cloud-platform 

gcloud compute instances list



cat > ssh.sh <<EOF
sudo apt-get update
sudo apt-get -y install kubectl
sudo apt-get -y install \
     apt-transport-https \
     ca-certificates \
     curl \
     gnupg2 \
     software-properties-common
	 
curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")    $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get -y install docker-ce
sudo usermod -aG docker $USER
sleep 10
docker run hello-world
exit
logout
warning "Exit from ssh"
EOF

chmod +x ssh.sh
echo "${CYAN}${BOLD}
File permission granted to ssh.sh
${RESET}"
sleep 20
gcloud compute scp --zone us-central1-a --quiet ssh.sh instance:~

echo "${BOLD}${YELLOW}
Run this in ssh:
${BG_RED}
./ssh.sh
${RESET}"

gcloud compute ssh instance --zone=us-central1-a --quiet
completed "Task 1"

echo "${BOLD}${YELLOW}
Run this in ssh:
${BG_RED}
docker run hello-world
${RESET}"

gcloud compute ssh instance --zone=us-central1-a --quiet

gsutil -m cp -r gs://spls/gsp133/gke-dedicated-game-server .
GCR_REGION=us 
PROJECT_ID=$PROJECT_ID
printf "$GCR_REGION \n$PROJECT_ID\n"
cd gke-dedicated-game-server/openarena
docker build -t \
${GCR_REGION}.gcr.io/${PROJECT_ID}/openarena:0.8.8 .
gcloud docker -- push \
  ${GCR_REGION}.gcr.io/${PROJECT_ID}/openarena:0.8.8
  
echo "${BOLD}${YELLOW}
Run this in ssh:
${BG_RED}
gsutil -m cp -r gs://spls/gsp133/gke-dedicated-game-server .
GCR_REGION=us 
PROJECT_ID=$PROJECT_ID
cd gke-dedicated-game-server/openarena
docker build -t ${GCR_REGION}.gcr.io/${PROJECT_ID}/openarena:0.8.8 .
gcloud docker -- push ${GCR_REGION}.gcr.io/${PROJECT_ID}/openarena:0.8.8
exit
${RESET}"

gcloud compute ssh instance --zone=us-central1-a --quiet
completed "Task 2"

region=us-east1
zone_1=${region}-b
gcloud config set compute/region ${region}
gcloud compute instances create openarena-asset-builder \
   --machine-type f1-micro \
   --image-family debian-9 \
   --image-project debian-cloud \
   --zone ${zone_1}
gcloud compute disks create openarena-assets \
   --size=50GB --type=pd-ssd\
   --description="OpenArena data disk. Mount read-only at
/usr/share/games/openarena/baseoa/" \
   --zone ${zone_1}
gcloud compute instances attach-disk openarena-asset-builder \
   --disk openarena-assets --zone ${zone_1}

completed "Task 3"

cat > ssh_openarena.sh <<EOF
sudo lsblk
sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb
sudo mkdir -p /usr/share/games/openarena/baseoa/
sudo mount -o discard,defaults /dev/sdb \
    /usr/share/games/openarena/baseoa/
sudo apt-get update
sudo apt-get -y install openarena-server
sudo gsutil cp gs://qwiklabs-assets/single-match.cfg /usr/share/games/openarena/baseoa/single-match.cfg
sudo umount -f -l /usr/share/games/openarena/baseoa/
exit
EOF

chmod +x ssh_openarena.sh
echo "${CYAN}${BOLD}
File permission granted to ssh_openarena.sh
${RESET}"

gcloud compute scp --zone $zone_1 --quiet ssh_openarena.sh openarena-asset-builder:~

echo "${BOLD}${YELLOW}
Run this in ssh:
${BG_RED}
./ssh_openarena.sh
${RESET}"

gcloud compute ssh openarena-asset-builder --zone $zone_1 --quiet

region=us-east1
zone_1=${region}-b
gcloud compute instances delete openarena-asset-builder --zone ${zone_1} --quiet

gcloud compute networks create game
gcloud compute firewall-rules create openarena-dgs --network game \
    --allow udp:27961-28061
gcloud container clusters create openarena-cluster \
   --num-nodes 3 \
   --network game \
   --machine-type=n1-standard-2 \
   --zone=${zone_1}	
completed "Task 4"

gcloud container clusters get-credentials openarena-cluster --zone ${zone_1}
kubectl apply -f k8s/asset-volume.yaml
kubectl apply -f k8s/asset-volumeclaim.yaml
kubectl get persistentVolume
kubectl get persistentVolumeClaim

completed "Task 5"
GCR_REGION=us 
PROJECT_ID=$PROJECT_ID
cd ../scaling-manager
chmod +x build-and-push.sh
source ./build-and-push.sh

echo "${BOLD}${YELLOW}
Run this in ssh:
${BG_RED}
GCR_REGION=us 
PROJECT_ID=$PROJECT_ID
cd gke-dedicated-game-server/scaling-manager
chmod +x build-and-push.sh
source ./build-and-push.sh
exit
${RESET}"

gcloud compute ssh instance --zone=us-central1-a --quiet

completed "Task 6"
gcloud compute instance-groups managed list
GKE_BASE_INSTANCE_NAME=$(gcloud compute instance-groups managed list --format="value(BASE_INSTANCE_NAME)")
GCP_ZONE=$(gcloud compute instance-groups managed list --format="value(LOCATION)")


printf "$GCR_REGION \n$PROJECT_ID \n$GKE_BASE_INSTANCE_NAME \n$GCP_ZONE \n"
sed -i "s/\[GCR_REGION\]/$GCR_REGION/g" k8s/openarena-scaling-manager-deployment.yaml
sed -i "s/\[PROJECT_ID\]/$PROJECT_ID/g" k8s/openarena-scaling-manager-deployment.yaml
sed -i "s/\[ZONE\]/$GCP_ZONE/g" k8s/openarena-scaling-manager-deployment.yaml
sed -i "s/\gke-openarena-cluster-default-pool-\[REPLACE_ME\]/$GKE_BASE_INSTANCE_NAME/g" k8s/openarena-scaling-manager-deployment.yaml
kubectl apply -f k8s/openarena-scaling-manager-deployment.yaml
kubectl get pods


completed "Task 7"

cd ..
sed -i "s/\[GCR_REGION\]/$GCR_REGION/g" openarena/k8s/openarena-pod.yaml
sed -i "s/\[PROJECT_ID\]/$PROJECT_ID/g" openarena/k8s/openarena-pod.yaml
kubectl apply -f openarena/k8s/openarena-pod.yaml
kubectl get pods


completed "Task 8"

kubectl delete pod openarena.dgs
sed -i "s/\/usr\/share\/games\/openarena\/baseoa/\/usr\/lib\/openarena-server\/baseoa/g"  openarena/k8s/openarena-pod.yaml
kubectl apply -f openarena/k8s/openarena-pod.yaml
completed "Lab"

remove_files 
