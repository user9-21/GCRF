curl -o default.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/default.sh
source default.sh

sudo apt-get update
sudo apt-get install apache2-utils -y
ab -V

git clone https://github.com/GoogleCloudPlatform/gke-migration-to-containers.git
cd gke-migration-to-containers
gcloud config set compute/region us-central1
gcloud config set compute/zone us-central1-a
sed -i "s/f1-micro/n1-standard-1/g" terraform/variables.tf
make create
completed "Task 1"

cat > cos_vm_ssh.sh << EOF
git clone https://github.com/GoogleCloudPlatform/gke-migration-to-containers.git
cd gke-migration-to-containers/container
sudo docker build -t gcr.io/migration-to-containers/prime-flask:1.0.2 .
ps aux | grep 8080
read -p "${BOLD}${YELLOW}Enter the first 'chronos' port number(from above command output) : ${RESET}" PORT_NUMBER
sudo kill -9 $PORT_NUMBER
sudo docker run --rm -d --name=appuser -p 8080:8080 gcr.io/migration-to-containers/prime-flask:1.0.2
ps aux
ls /usr/local/bin/python
sudo docker ps
sudo docker exec -it $(sudo docker ps |awk '/prime-flask/ {print $1}') ps aux
exit
EOF

echo "${CYAN}${BOLD}
Created cos_vm_ssh.sh
File permission granted to cos_vm_ssh.sh
${RESET}"

echo "${YELLOW}${BOLD}
Run this in cos-vm ssh:
${BG_RED}
source cos_vm_ssh.sh
${RESET}"

gcloud compute scp --zone us-central1-a --quiet cos_vm_ssh.sh cos-vm:~
gcloud compute scp --zone us-central1-a --quiet cos_vm_ssh.sh cos-vm:~

gcloud compute ssh cos-vm --zone us-central1-a --quiet

gcloud container clusters get-credentials prime-server-cluster
kubectl get pods
kubectl exec $(kubectl get pods -lapp=prime-server -ojsonpath='{.items[].metadata.name}')  -- ps aux
make validate


read -p "${BOLD}${YELLOW}Enter IP Address for Kubernetes Webapp(from above command output) : " IP_ADDRESS

echo "${BG_RED}${BOLD}
Run this in another(+) terminal:-
ab -c 120 -t 60  http://$IP_ADDRESS/prime/10000
${RESET}"


completed "Task 2"

kubectl scale --replicas 3 deployment/prime-server

echo "${BG_RED}${BOLD}
Again Run this in another(+) terminal:-
ab -c 120 -t 60  http://$IP_ADDRESS/prime/10000
${RESET}"

completed "Task 3"

completed "Lab"

remove_files