curl -o default.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/default.sh
source default.sh

gcloud config set compute/zone us-central1-a
gcloud beta container clusters create private-cluster \
    --enable-private-nodes \
    --master-ipv4-cidr 172.16.0.16/28 \
    --enable-ip-alias \
    --create-subnetwork ""
completed "Task 1"

gcloud compute networks subnets list --network default
gcloud compute instances create source-instance --zone us-central1-a --scopes 'https://www.googleapis.com/auth/cloud-platform'
completed "Task 2"

natIP=`gcloud compute instances describe source-instance --zone us-central1-a | grep natIP | awk '{print $2}'`
#natIP=`gcloud compute instances  list --filter="NAME:source-instance" --format="value(EXTERNAL_IP)"`
MY_EXTERNAL_RANGE=$natIP/32
echo $MY_EXTERNAL_RANGE
gcloud container clusters update private-cluster \
    --enable-master-authorized-networks \
    --master-authorized-networks $MY_EXTERNAL_RANGE
completed "Task 3"

gcloud container clusters delete private-cluster --zone us-central1-a --quiet
completed "Task 4"

gcloud compute networks subnets create my-subnet \
    --network default \
    --range 10.0.4.0/22 \
    --enable-private-ip-google-access \
    --region us-central1 \
    --secondary-range my-svc-range=10.0.32.0/20,my-pod-range=10.4.0.0/14
completed "Task 5"

gcloud beta container clusters create private-cluster2 \
    --enable-private-nodes \
    --enable-ip-alias \
    --master-ipv4-cidr 172.16.0.32/28 \
    --subnetwork my-subnet \
    --services-secondary-range-name my-svc-range \
    --cluster-secondary-range-name my-pod-range
completed "Task 6"	
	
gcloud container clusters update private-cluster2 \
    --enable-master-authorized-networks \
    --master-authorized-networks $MY_EXTERNAL_RANGE
completed "Task 7"
completed "Lab"

remove_files