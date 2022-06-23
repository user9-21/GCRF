curl -o default.sh https://raw.githubusercontent.com/user9-21/GoogleCloudReady-Facilitator-program/main/files/default.sh
source default.sh

gcloud config set compute/zone us-central1-a
gcloud compute instances create blue --zone=us-central1-a --machine-type=n1-standard-1 --network-interface=network-tier=PREMIUM,subnet=default --maintenance-policy=MIGRATE --scopes=https://www.googleapis.com/auth/devstorage.read_only --tags=web-server,http-server

completed "Task 1"

cat > blue.sh <<EOF
apt-get install -y nginx-light
sed -i 's/nginx/Blue server/g' /var/www/html/index.nginx-debian.html
EOF

cat > green.sh <<EOF
apt-get install -y nginx-light
sed -i 's/nginx/Green server/g' /var/www/html/index.nginx-debian.html
EOF


gcloud compute instances create green  --zone=us-central1-a


completed "Task 2"



cat > 2.sh <<EOF

echo "${YELLOW}${BOLD}

Run this in SSH:
${BG_RED}
sudo apt-get install -y nginx-light
exit
${RESET}"

gcloud compute ssh blue --zone us-central1-a --quiet

echo "${YELLOW}${BOLD}
Run this in SSH:
${BG_RED}
sudo apt-get install -y nginx-light
exit
${RESET}"

gcloud compute ssh green  --zone us-central1-a --quiet
tput bold; tput setaf 3 ;echo Back in cloudshell; tput sgr0;

completed "Task 3"
EOF

chmod +x 2.sh
echo "${YELLOW}${BOLD}
Run this in another terminal:
${BG_RED}
./2.sh
${RESET}"
gcloud compute firewall-rules create allow-http-web-server --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:80,icmp --source-ranges=0.0.0.0/0 --target-tags=web-server

completed "Task 4"
gcloud compute instances create test-vm --machine-type=f1-micro --subnet=default --zone=us-central1-a

completed "Task 5"
gcloud iam service-accounts create network-admin --display-name network-admin
export PROJECT=$(gcloud info --format="value(config.project)")
export SA_EMAIL=$(gcloud iam service-accounts list --filter="displayName:network-admin" --format="value(email)")
echo $SA_EMAIL
gcloud projects add-iam-policy-binding $PROJECT  --role roles/compute.admin  --member serviceAccount:$SA_EMAIL
gcloud iam service-accounts keys create credentials.json   --iam-account $SA_EMAIL




completed "Task 6"

completed "Lab"

remove_files 
