curl -o default.sh https://raw.githubusercontent.com/user9-21/GoogleCloudReady-Facilitator-program/main/files/default.sh
source default.sh

export PROJECT=$(gcloud info --format='value(config.project)')
gcloud compute networks create managementnet  --subnet-mode=custom --mtu=1460 --bgp-routing-mode=regional 
gcloud compute networks subnets create managementsubnet-us --network=managementnet --region=us-central1 --range=10.130.0.0/20 

completed "Task 1"

gcloud compute networks create privatenet --subnet-mode=custom
gcloud compute networks subnets create privatesubnet-us --network=privatenet --region=us-central1 --range=172.16.0.0/24
gcloud compute networks subnets create privatesubnet-eu --network=privatenet --region=europe-west4 --range=172.20.0.0/20

completed "Task 2"
gcloud compute firewall-rules create managementnet-allow-icmp-ssh-rdp --direction=INGRESS --priority=1000 --network=managementnet --action=ALLOW --rules=icmp,tcp:22,tcp:3389 --source-ranges=0.0.0.0/0

completed "Task 3"
gcloud compute firewall-rules create privatenet-allow-icmp-ssh-rdp --direction=INGRESS --priority=1000 --network=privatenet --action=ALLOW --rules=icmp,tcp:22,tcp:3389 --source-ranges=0.0.0.0/0

completed "Task 4"
gcloud compute instances create managementnet-us-vm --zone=us-central1-f --machine-type=f1-micro --subnet=managementsubnet-us

completed "Task 5"
gcloud compute instances create privatenet-us-vm --zone=us-central1-f --machine-type=n1-standard-1 --subnet=privatesubnet-us

completed "Task 6"

gcloud compute instances create vm-appliance --zone=us-central1-f --machine-type=n1-standard-4 --network-interface=network-tier=PREMIUM,subnet=managementsubnet-us --network-interface=network-tier=PREMIUM,subnet=privatesubnet-us --network-interface=network-tier=PREMIUM,subnet=mynetwork --maintenance-policy=MIGRATE --create-disk=auto-delete=yes,boot=yes,device-name=vm-appliance,image=projects/debian-cloud/global/images/debian-10-buster-v20210916,mode=rw,size=10,type=projects/$PROJECT/zones/us-central1-f/diskTypes/pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any

completed "Task 7"

completed "Lab"

remove_files 
