curl -o default.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/default.sh
source default.sh

warning "Enter Zone from in-betwwen the instructions."
echo " "
read -p "${BOLD}${YELLOW}      Enter SSH IAP network tag : ${RESET}" IAP_NETWORK_TAG
read -p "${BOLD}${YELLOW} Enter SSH internal network tag : ${RESET}" INTERNAL_NETWORK_TAG
read -p "${BOLD}${YELLOW}         Enter HTTP network tag : ${RESET}" HTTP_NETWORK_TAG
read -p "${BOLD}${YELLOW}                     Enter zone : ${RESET}" ZONE
echo "${BOLD}"
echo "${YELLOW}SSH IAP network tag      :${CYAN} $IAP_NETWORK_TAG "
echo "${YELLOW}SSH internal network tag :${CYAN} $INTERNAL_NETWORK_TAG "
echo "${YELLOW}HTTP network tag         :${CYAN} $HTTP_NETWORK_TAG "
echo "${YELLOW}                     Zone:${CYAN} $ZONE "
echo " "

read -p "${BOLD}${YELLOW}Verify all details are correct? [ y/n ] : ${RESET}" VERIFY_DETAILS

while [ $VERIFY_DETAILS != 'y' ];
do echo " " && 
read -p "${BOLD}${YELLOW}Enter SSH IAP network tag      : ${RESET}" IAP_NETWORK_TAG && 
read -p "${BOLD}${YELLOW}Enter SSH internal network tag : ${RESET}" INTERNAL_NETWORK_TAG && 
read -p "${BOLD}${YELLOW}Enter HTTP network tag         : ${RESET}" HTTP_NETWORK_TAG && 
read -p "${BOLD}${YELLOW}                     Enter zone : ${RESET}" ZONE && 
echo "${BOLD}" && 
echo "${YELLOW}SSH IAP network tag      :${CYAN} $IAP_NETWORK_TAG " && 
echo "${YELLOW}SSH internal network tag :${CYAN} $INTERNAL_NETWORK_TAG " && 
echo "${YELLOW}HTTP network tag         :${CYAN} $HTTP_NETWORK_TAG " && 
echo "${YELLOW}                     Zone:${CYAN} $ZONE " && 
echo " " && 
read -p "${BOLD}${YELLOW}Verify all details are correct? [ y/n ] : ${RESET}" VERIFY_DETAILS ;
done


gcloud compute firewall-rules delete open-access --quiet
completed "Task 1"

gcloud compute instances start bastion  --zone=$ZONE
completed "Task 2"


gcloud compute firewall-rules create $IAP_NETWORK_TAG  --allow=tcp:22 --source-ranges 35.235.240.0/20 --target-tags $IAP_NETWORK_TAG  --network acme-vpc
gcloud compute instances add-tags bastion --tags=$IAP_NETWORK_TAG  --zone=$ZONE
completed "Task 3"


gcloud compute firewall-rules create $HTTP_NETWORK_TAG  --allow=tcp:80 --source-ranges 0.0.0.0/0 --target-tags $HTTP_NETWORK_TAG  --network acme-vpc
gcloud compute instances add-tags juice-shop --tags=$HTTP_NETWORK_TAG  --zone=$ZONE
completed "Task 4"

gcloud compute firewall-rules create $INTERNAL_NETWORK_TAG --allow=tcp:22 --source-ranges 192.168.10.0/24 --target-tags $INTERNAL_NETWORK_TAG --network acme-vpc
gcloud compute instances add-tags juice-shop --tags=$INTERNAL_NETWORK_TAG --zone=$ZONE
completed "Task 5"


export PROJECT_ID=$(gcloud info --format='value(config.project)')
export PROJECT_NUMBER=$(gcloud projects list --filter="PROJECT_ID: $PROJECT_ID" | grep PROJECT_NUMBER |  awk '{print $2}')
export INTERNAL_IP_JUICE_SHOP=$(gcloud compute instances list --filter='name:juice-shop' --format='value(INTERNAL_IP)')


echo "${BOLD}${YELLOW}INTERNAL IP of juice-shop instance :${CYAN} $INTERNAL_IP_JUICE_SHOP"

echo "${BOLD}${YELLOW}
SSH to bastion instance here( NOTE - may throw error) :
${BOLD}${BG_RED}
https://ssh.cloud.google.com/projects/$PROJECT_ID/zones/$ZONE/instances/bastion?authuser=0&hl=en_US&projectNumber=$PROJECT_NUMBER&useAdminProxy=true&troubleshoot4005Enabled=true&troubleshoot255Enabled=true
${RESET}${BOLD}${YELLOW}
then SSH to juice-shop instance via bastion instance, RUN this(inside bastion instance ssh):
${BOLD}${BG_RED}
ssh $INTERNAL_IP_JUICE_SHOP
${RESET}${BOLD}${YELLOW}
If error appeared in above step , do ssh manually here - https://console.cloud.google.com/compute/instances
1. ssh to bastion
2. Now ssh to juice-shop from bastion
Try this inside bastion instance ssh
ssh <INTERNAL IP OF juice-shop>
${RESET}"
#gcloud compute ssh juice-shop --zone=$ZONE  --internal-ip
#gcloud compute instances ssh bastion  --zone=$ZONE --quiet
read -p "${BOLD}${YELLOW}Done with above step? (y/n) : ${RESET}" DONE_SSH 

while [ $DONE_SSH != 'y' ] ;
do sleep 20 &&  read -p "${BOLD}${YELLOW}Done with above step? (y/n) : ${RESET}" DONE_SSH ;
done
completed "Task 6"

completed "Lab"

remove_files 