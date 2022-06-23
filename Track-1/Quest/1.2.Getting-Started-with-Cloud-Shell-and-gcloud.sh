curl -o default.sh https://raw.githubusercontent.com/user9-21/GoogleCloudReady-Facilitator-program/main/files/default.sh
source default.sh


gcloud compute instances create gcelab2 --machine-type n1-standard-2 --zone us-central1-a


completed "Lab"
remove_files 
