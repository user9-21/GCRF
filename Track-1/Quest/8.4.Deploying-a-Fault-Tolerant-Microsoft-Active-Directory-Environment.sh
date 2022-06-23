curl -o default.sh https://raw.githubusercontent.com/user9-21/GoogleCloudReady-Facilitator-program/main/files/default.sh
source default.sh
export region1=us-central1
export region2=us-west1
export zone_1=${region1}-b
export zone_2=${region2}-c
export vpc_name=webappnet
export project_id=$(gcloud config get-value project)
gcloud config set compute/region ${region1}
gcloud compute networks create ${vpc_name}  \
    --description "VPC network to deploy Active Directory" \
    --subnet-mode custom
gcloud compute networks subnets create private-ad-zone-1 \
    --network ${vpc_name} \
    --range 10.1.0.0/24 \
    --region ${region1}
gcloud compute networks subnets create private-ad-zone-2 \
    --network ${vpc_name} \
    --range 10.2.0.0/24 \
    --region ${region2}
gcloud compute firewall-rules create allow-internal-ports-private-ad \
    --network ${vpc_name} \
    --allow tcp:1-65535,udp:1-65535,icmp \
    --source-ranges  10.1.0.0/24,10.2.0.0/24
gcloud compute firewall-rules create allow-rdp \
    --network ${vpc_name} \
    --allow tcp:3389 \
    --source-ranges 0.0.0.0/0

completed "Task 1"

gcloud compute instances create ad-dc1 --machine-type n1-standard-2 \
    --boot-disk-type pd-ssd \
    --boot-disk-size 50GB \
    --image-family windows-2016 --image-project windows-cloud \
    --network ${vpc_name} \
    --zone ${zone_1} --subnet private-ad-zone-1 \
    --private-network-ip=10.1.0.100

completed "Task 2"
sleep 100
gcloud compute reset-windows-password ad-dc1 --zone ${zone_1} --quiet --user=admin > ad-dc1.rdp
sed -i "s/ip_address: /full address:s:/g" ad-dc1.rdp
sed -i "s/username:   /username:s:/g" ad-dc1.rdp
cat ad-dc1.rdp
cloudshell download ad-dc1.rdp
warning "Download ad-dc1.rdp file and connect using given credentials"

export region2=us-west1
export zone_2=${region2}-c
export vpc_name=webappnet
export project_id=$(gcloud config get-value project)
gcloud config set compute/region ${region2}
gcloud compute instances create ad-dc2 --machine-type n1-standard-2 \
    --boot-disk-size 50GB \
    --boot-disk-type pd-ssd \
    --image-family windows-2016 --image-project windows-cloud \
    --can-ip-forward \
    --network ${vpc_name} \
    --zone ${zone_2} \
    --subnet private-ad-zone-2 \
    --private-network-ip=10.2.0.100
#gcloud compute reset-windows-password ad-dc2 --zone ${zone_2} --quiet --user=admin

gcloud compute instances create ad-dc2 --machine-type n1-standard-2 --boot-disk-size 50GB --boot-disk-type pd-ssd --image-family windows-2016 --image-project windows-cloud --can-ip-forward --network ${vpc_name} --zone us-west1-b --subnet private-ad-zone-2 --private-network-ip=10.2.0.100

completed "Task 3"

completed "Lab"

remove_files 