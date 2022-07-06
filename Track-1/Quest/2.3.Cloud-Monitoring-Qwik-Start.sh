curl -o default.sh https://raw.githubusercontent.com/user9-21/GoogleCloudReady-Facilitator-program/main/files/default.sh
source default.sh


gcloud config set compute/zone us-central1-a
export PROJECT_ID=$(gcloud info --format='value(config.project)')

gsutil mb gs://$PROJECT_ID/

echo '#!/bin/bash
sudo apt update
sudo apt install apache2 php7.0 -y
sudo service apache2 restart
curl -sSO https://dl.google.com/cloudagents/add-monitoring-agent-repo.sh
sudo bash add-monitoring-agent-repo.sh
sudo apt update
sudo apt install stackdriver-agent -y
curl -sSO https://dl.google.com/cloudagents/add-logging-agent-repo.sh
sudo bash add-logging-agent-repo.sh
sudo apt update
sudo apt install google-fluentd' > startup_script.sh

gsutil  cp startup_script.sh gs://$PROJECT_ID

gcloud compute instances create lamp-1-vm \
    --machine-type=n1-standard-2 \
	--zone=us-central1-a \
	--metadata=startup-script-url=gs://$PROJECT_ID/startup_script.sh \
	--tags=http-server \
	--create-disk=auto-delete=yes,boot=yes,device-name=lamp-1-vm,image=projects/debian-cloud/global/images/debian-10-buster-v20220621,mode=rw,size=10,type=projects/$PROJECT_ID/zones/us-central1-a/diskTypes/pd-balanced --no-shielded-secure-boot

completed "Task 1"

warning "Wait for Apache2 HTTP server to install"


echo "${BOLD}${YELLOW}
Now Allow http trapic in lamp-1-vm and click save -${CYAN} https://console.cloud.google.com/compute/instancesEdit/zones/us-central1-a/instances/lamp-1-vm 
${YELLOW}
Now create Uptime check -${CYAN} https://console.cloud.google.com/monitoring/uptime
 ${RESET}"
 
 echo "${BOLD}${CYAN}
   Title: Lamp Uptime Check
 
   Protocol: HTTP
 
   Resource Type: Instance
 
   Applies to: Single, lamp-1-vm
 
   Check Frequency: 1 min
${RESET}"

echo "${BOLD}${YELLOW}
Now create alerting policy -${CYAN} https://console.cloud.google.com/monitoring/alerting
${RESET}"

 echo "${BOLD}${CYAN}
   Resource Type: VM Instance (gce_instance)
 
   Metric: agent.googleapis.com/interface/traffic

   Configuration: 
 
     Condition: is above
     Threshold: 500
     For: 1 minute
   
   Alert name: Inbound Traffic Alert
 
${RESET}"
  

completed "Lab"

remove_files