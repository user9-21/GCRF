curl -o default.sh https://raw.githubusercontent.com/user9-21/GoogleCloudReady-Facilitator-program/main/files/default.sh
source default.sh

export PROJECT=$GOOGLE_CLOUD_PROJECT
gsutil mb gs://$PROJECT
cat > ssh.sh <<EOF
sudo apt-get update
sudo apt-get install nginx -y


exit

EOF

chmod +x ssh.sh
gsutil cp ssh.sh gs://$PROJECT
echo "${CYAN}${BOLD}

File permission granted to ssh.sh

${RESET}"
gcloud compute instances create gcelab --machine-type n1-standard-2 --zone us-central1-f --tags=http-server --create-disk=auto-delete=yes,boot=yes,device-name=gcela,image=projects/debian-cloud/global/images/debian-10-buster-v20210916,mode=rw,size=10,type=projects/$PROJECT/zones/us-central1-f/diskTypes/pd-balanced --metadata=startup-script-url=gs://$PROJECT/ssh.sh --scopes=https://www.googleapis.com/auth/devstorage.read_only


gcloud compute firewall-rules create default-allow-http \
    --network=default \
    --action=allow \
    --direction=ingress \
    --source-ranges=0.0.0.0/0 \
    --target-tags=http-server \
    --rules=tcp:80
EXTERNAL_IP=$(gcloud compute instances list --format='value(EXTERNAL_IP)')
gcloud compute instances create gcelab2 --machine-type n1-standard-2 --zone us-central1-f 

echo "${YELLOW} ${BOLD}

Navigate Here -${CYAN} http://$EXTERNAL_IP
${YELLOW}
if error in opening external ip of gcelab NAVIGATE here and Allow HTTP Traffic : 
${CYAN}
https://console.cloud.google.com/compute/instancesEdit/zones/us-central1-f/instances/gcelab?project=$GOOGLE_CLOUD_PROJECT

${RESET}"

completed "Task 1"
gcloud compute scp --zone=us-central1-f  --quiet ssh.sh gcelab:~

echo "${BOLD}${YELLOW}

if NGINX is not installed in gcelab, ssh to gcelab using this command :${CYAN} gcloud compute ssh gcelab --zone=us-central1-f 
${YELLOW}and Run this in ssh:
${BG_RED}
./ssh.sh
${RESET}"

completed "Task 2"

completed "Lab"

remove_files 
