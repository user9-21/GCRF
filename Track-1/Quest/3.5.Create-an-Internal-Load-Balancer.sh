curl -o default.sh https://raw.githubusercontent.com/user9-21/GoogleCloudReady-Facilitator-program/main/files/default.sh
source default.sh


cat > 2.sh << EOF
gcloud compute health-checks create tcp my-ilb-health-check --region=us-central1 --port=80
gcloud compute backend-services create my-ilb --load-balancing-scheme=internal --protocol=tcp --region=us-central1 --health-checks=my-ilb-health-check --health-checks-region=us-central1
echo "${YELLOW}${BOLD}
Confirm load balancer is properly Configured -${CYAN} https://console.cloud.google.com/net-services/loadbalancing/loadBalancers/list?project=$PROJECT_ID 
${RESET}"
gcloud compute forwarding-rules create fr-ilb --region=us-central1 --load-balancing-scheme=internal --network=my-internal-app --subnet=subnet-b --address=10.10.30.5 --ip-protocol=TCP --ports=80 --backend-service=my-ilb --backend-service-region=us-central1
gcloud compute firewall-rules create app-allow-http --direction=INGRESS --priority=1000 --network=my-internal-app --action=ALLOW --rules=tcp:80 --source-ranges=0.0.0.0/0 --target-tags=lb-backend
gcloud compute firewall-rules create app-allow-health-check --direction=INGRESS --priority=1000  --action=ALLOW --rules=tcp --source-ranges=130.211.0.0/22,35.191.0.0/16 --target-tags=lb-backend
echo "${YELLOW}${BOLD}
firewall created
${RESET}"

completed "Task 1" 
gcloud compute instances create utility-vm --zone=us-central1-f --machine-type=f1-micro --network-interface=network-tier=PREMIUM,private-network-ip=10.10.20.50,subnet=subnet-a --maintenance-policy=MIGRATE --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any --create-disk=auto-delete=yes,boot=yes,device-name=utility-vm,image=projects/debian-cloud/global/images/debian-10-buster-v20210916,mode=rw,size=10,type=projects/$GOOGLE_CLOUD_PROJECT/zones/us-central1-a/diskTypes/pd-balanced 

completed "Task 2"
gcloud beta compute instance-groups managed set-autoscaling "instance-group-1" --zone "us-central1-a" --cool-down-period "45" --max-num-replicas "5" --min-num-replicas "1" --target-cpu-utilization "0.8" --mode "on"
gcloud compute backend-services add-backend my-ilb --region=us-central1 --instance-group=instance-group-1 --instance-group-zone=us-central1-a
EOF
chmod +x 2.sh
echo "${YELLOW}${BOLD}
Run this in another instance:
${BG_RED}
./2.sh
${RESET}"


gcloud beta compute instance-templates create instance-template-1 --machine-type=n1-standard-1 --subnet=projects/$GOOGLE_CLOUD_PROJECT/regions/us-central1/subnetworks/subnet-a --network-tier=PREMIUM --metadata=startup-script-url=gs://cloud-training/gcpnet/ilb/startup.sh --maintenance-policy=MIGRATE --region=us-central1 --tags=lb-backend --boot-disk-device-name=instance-template-1
gcloud beta compute instance-templates create instance-template-2 --machine-type=n1-standard-1 --subnet=projects/$GOOGLE_CLOUD_PROJECT/regions/us-central1/subnetworks/subnet-b --network-tier=PREMIUM --metadata=startup-script-url=gs://cloud-training/gcpnet/ilb/startup.sh --maintenance-policy=MIGRATE --region=us-central1 --tags=lb-backend --boot-disk-device-name=instance-template-2

tput bold; tput setaf 3 ;echo instance template created; tput sgr0

gcloud compute instance-groups managed create instance-group-1 --base-instance-name=instance-group-1 --template=instance-template-1 --size=1 --zone=us-central1-a

gcloud compute instance-groups managed create instance-group-2 --base-instance-name=instance-group-2 --template=instance-template-2 --size=1 --zone=us-central1-b
gcloud beta compute instance-groups managed set-autoscaling "instance-group-2" --zone "us-central1-b" --cool-down-period "45" --max-num-replicas "5" --min-num-replicas "1" --target-cpu-utilization "0.8" --mode "on"

echo "${YELLOW}${BOLD}
instance group created
${RESET}"


echo "${YELLOW}${BOLD}
Confirm load balancer is properly Configured -${CYAN} https://console.cloud.google.com/net-services/loadbalancing/loadBalancers/list?project=$PROJECT_ID 
${RESET}"

gcloud compute backend-services add-backend my-ilb --region=us-central1 --instance-group=instance-group-2 --instance-group-zone=us-central1-b

completed "Task 3"

completed "Lab"

remove_files 
