curl -o default.sh https://raw.githubusercontent.com/user9-21/GoogleCloudReady-Facilitator-program/main/files/default.sh
source default.sh

gcloud services enable iap.googleapis.com

gcloud compute instances create linux-iap --zone=us-central1-a --machine-type=n1-standard-1 --network-interface=subnet=default,no-address --metadata=enable-oslogin=true

gcloud compute instances create windows-iap --zone=us-central1-a --machine-type=n1-standard-1 --network-interface=subnet=default,no-address --metadata=enable-oslogin=true --maintenance-policy=MIGRATE --provisioning-model=STANDARD --create-disk=auto-delete=yes,boot=yes,device-name=windows-iap,image=projects/windows-cloud/global/images/windows-server-2016-dc-v20220624,mode=rw,size=50,type=projects/$PROJECT_ID/zones/us-central1-a/diskTypes/pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any

gcloud compute instances create windows-connectivity --zone=us-central1-a --machine-type=n1-standard-1 --network-interface=network-tier=PREMIUM,subnet=default --metadata=enable-oslogin=true --maintenance-policy=MIGRATE --provisioning-model=STANDARD --scopes=https://www.googleapis.com/auth/cloud-platform --create-disk=auto-delete=yes,boot=yes,device-name=windows-connectivity,image=projects/windows-cloud/global/images/windows-server-2016-dc-v20220624,mode=rw,size=50,type=projects/$PROJECT_ID/zones/us-central1-a/diskTypes/pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any

gcloud compute instances list
completed "Task 1"

#gcloud compute firewall-rules create allow-ingress-from-iap --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:22,tcp:3389 --source-ranges=35.235.240.0/20
warning "Visit -  ${CYAN}https://console.cloud.google.com/networking/firewalls/add?project=$PROJECT_ID ${YELLOW} 
	and create 'allow-ingress-from-iap' rule manually"
completed "Task 2"

#warning "if error in getting ${GREEN}Task 2${YELLOW} score, visit -  ${CYAN}https://console.cloud.google.com/networking/firewalls/list?project=$PROJECT_ID ${YELLOW} and Delete the 'allow-ingress-from-iap' rule and create it manually"
PROJECT_NUMBER=`gcloud projects list --filter="$(gcloud config get-value project)" --format="value(PROJECT_NUMBER)"`
SERVICE_ACCOUNT=$PROJECT_NUMBER-compute@developer.gserviceaccount.com

echo "${YELLOW}
Go here ${CYAN}https://console.cloud.google.com/security/iap?project=$PROJECT_ID ${YELLOW}
 - Click on SSH and TCP Resources tab 
 - Select the linux-iap and windows-iap VM instances
 
 - Click Add  Principal
 - enter service account: ${CYAN} $SERVICE_ACCOUNT ${YELLOW}
 - select role          : ${CYAN} IAP-Secured Tunnel User ${YELLOW}
 - click Save
 
 - Click Add  Principal
 - enter your email : ${CYAN} $EMAIL ${YELLOW}
 - select role      : ${CYAN} IAP-Secured Tunnel User ${YELLOW}
 - click Save
${RESET}"

completed "Task 3"

sleep 20
gcloud compute reset-windows-password windows-connectivity --zone us-central1-a --quiet --user=admin > windows-connectivity.rdp
sed -i "s/ip_address: /full address:s:/g" windows-connectivity.rdp
sed -i "s/username:   /username:s:/g" windows-connectivity.rdp
cat windows-connectivity.rdp
cloudshell download windows-connectivity.rdp
warning "Download windows-connectivity.rdp file and connect using given credentials


You can also complete Task 4 in cloudshell itself,But if score not given login to rdp and do as instructed on lab page"

echo "${YELLOW}${BOLD}
Run this in ssh
${BG_RED}
gcloud compute start-iap-tunnel windows-iap 3389 --local-host-port=localhost:0  --zone=us-central1-a
exit
${RESET}"

rm *
gcloud compute ssh linux-iap --zone us-central1-a --quiet
completed "Task 4"

completed "Lab"

remove_files