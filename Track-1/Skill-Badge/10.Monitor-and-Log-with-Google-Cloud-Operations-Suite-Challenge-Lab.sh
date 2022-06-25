curl -o default.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/default.sh
source default.sh
	
echo " "
read -p "${BOLD}${YELLOW}Enter Custom Metric Name : ${RESET}" CUSTOM_METRIC_NAME
read -p "${BOLD}${YELLOW}Enter Alert Threshold    : ${RESET}" ALERT_THRESHOLD
echo "${BOLD}" 
echo "${YELLOW}Custom Metric Name :${CYAN} $CUSTOM_METRIC_NAME "
echo "${YELLOW}Alert Threshold    :${CYAN} $ALERT_THRESHOLD "
echo " "

read -p "${BOLD}${YELLOW}Verify all details are correct? [ y/n ] : ${RESET}" VERIFY_DETAILS

while [ $VERIFY_DETAILS != 'y' ];
do 	echo " " && 
read -p "${BOLD}${YELLOW}Enter Custom Metric Name : ${RESET}" CUSTOM_METRIC_NAME && 
read -p "${BOLD}${YELLOW}Enter Alert Threshold    : ${RESET}" ALERT_THRESHOLD && 
echo "${BOLD}"  && 
echo "${YELLOW}Custom Metric Name :${CYAN} $CUSTOM_METRIC_NAME " && 
echo "${YELLOW}Alert Threshold    :${CYAN} $ALERT_THRESHOLD " && 
echo " " && 
read -p "${BOLD}${YELLOW}Verify all details are correct? [ y/n ] : ${RESET}" VERIFY_DETAILS ;
done
	

warning "Visit ${CYAN} https://console.cloud.google.com/monitoring/dashboards?project=$PROJECT_ID${YELLOW} and Click Media_Dashboard."

read -p "${BOLD}${YELLOW}Created Media_Dashboard? [ y/n ] : ${RESET}" PROCEED1

while [ $PROCEED1 != 'y' ];
do echo "Do it Manually" && read -p "${BOLD}${YELLOW}Created Media_Dashboard? [ y/n ] : ${RESET}" PROCEED1;
done
completed "Task 1"

PROJECT_ID=$(gcloud info --format='value(config.project)')
INSTANCE_ID=$(gcloud compute instances describe video-queue-monitor --zone us-east1-b --format="value(id)")
INSTANCE_ZONE=us-east1-b

gcloud compute instances stop video-queue-monitor --zone us-east1-b 

curl -o startup_script.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/startup_script.sh
sed -i "s/REPLACE_WITH_PROJECT_ID/$PROJECT_ID/g" startup_script.sh
sed -i "s/REPLACE_WITH_INSTANCE_ID/$INSTANCE_ID/g" startup_script.sh
sed -i "s/REPLACE_WITH_INSTANCE_ZONE/$INSTANCE_ZONE/g" startup_script.sh


gcloud compute instances remove-metadata video-queue-monitor --keys=startup-script --zone us-east1-b
gcloud compute instances describe video-queue-monitor --zone us-east1-b 
gcloud compute instances add-metadata video-queue-monitor --metadata-from-file=startup-script=startup_script.sh --zone us-east1-b
echo "${MAGENTA}"
gcloud compute instances describe video-queue-monitor --zone us-east1-b 


gcloud compute instances start video-queue-monitor --zone us-east1-b 

#gcloud compute instances describe video-queue-monitor --zone us-east1-b --format="value(metadata.items.value)" > startup_script.sh

#--metadata=startup-script-url=gs://$PROJECT/startup_script.sh

#gcloud compute instances create gcelab --machine-type n1-standard-2 --zone us-central1-f --tags=http-server --create-disk=auto-delete=yes,boot=yes,device-name=gcela,image=projects/debian-cloud/global/images/debian-10-buster-v20210916,mode=rw,size=10,type=projects/$PROJECT/zones/us-central1-f/diskTypes/pd-balanced --metadata=startup-script-url=gs://$PROJECT/ssh.sh --scopes=https://www.googleapis.com/auth/devstorage.read_only


#gcloud compute instances add-metadata INSTANCE_NAME[--metadata=KEY=VALUE,[KEY=VALUE,...]][--metadata-from-file=KEY=LOCAL_FILE_PATH,[...]] [--zone=ZONE] [GCLOUD_WIDE_FLAG ...]
		
		
#gcloud compute instances describe video-queue-monitor --zone us-east1-b --format="value(metadata)"
completed "Task 2"

echo "${BOLD}${BLUE}Open logs explorer - ${YELLOW}https://console.cloud.google.com/logs/query?project=$PROJECT_ID ${BLUE} and slide ${YELLOW}Show query${BLUE} button to enter below query{$RED}"
echo '	textPayload=~"file_format\: ([4,8]K).*"'
warning "${BLUE}Click Run query. Click Create metric - (${YELLOW}https://console.cloud.google.com/logs/metrics/edit?project=$PROJECT_ID ${BLUE}) on Logs Explorer page 
	Log metric name : $CUSTOM_METRIC_NAME
	filter          : ABOVE QUERY"

read -p "${BOLD}${YELLOW}Created Metric? [ y/n ] : ${RESET}" PROCEED2

while [ $PROCEED2 != 'y' ];
do echo "Do it Manually" && read -p "${BOLD}${YELLOW}Created Metric? [ y/n ] : ${RESET}" PROCEED2;
done
completed "Task 3"

warning "${MAGENTA}Go to Monitoring Media_Dashboard ${CYAN}  https://console.cloud.google.com/monitoring/dashboards?project=$PROJECT_ID&pageState=(%22dashboards%22:(%22t%22:%22All%22)) ${MAGENTA} and
	- Click Edit Dashboard
	- Select Line Chart
	- in Select a metric, Start typing 'custom.google' and select${CYAN} opencensus/my.videoservice.org/measure/input_queue_size ${MAGENTA}
	- Click add filter
		Label      :${CYAN} instance_id ${MAGENTA}
		Comparison :${CYAN} = ${MAGENTA}
		value      :${CYAN} select predefined($INSTANCE_ID) ${MAGENTA}
		Click Done
	- Click ADD ANOTHER METRIC
	- Start typing 'logging' and select${CYAN} logging.googleapis.com/user/$CUSTOM_METRIC_NAME ${MAGENTA}
	  (you may need to to Toggle 'Show only active resources& metrics')"

read -p "${BOLD}${YELLOW}Configured Monitoring Media_Dashboard? [ y/n ] : ${RESET}" PROCEED3

while [ $PROCEED3 != 'y' ];
do echo "Do it Manually" && read -p "${BOLD}${YELLOW}Configured Monitoring Media_Dashboard? [ y/n ] : ${RESET}" PROCEED3;
done
completed "Task 4"


warning "${BLUE}Create a alerting Policy - ${CYAN}https://console.cloud.google.com/monitoring/alerting/policies/create?project=$PROJECT_ID
${BLUE}
	- in Select a metric, Start typing 'logging' and select${CYAN} logging.googleapis.com/user/$CUSTOM_METRIC_NAME ${BLUE}
	 (you may need to to Toggle 'Show only active resources& metrics', it would be under vm_instance )
	- Select Configure Trigger, and put threshold value to${CYAN} $ALERT_THRESHOLD ${BLUE}as given on lab page
	- Click Next
	- Alert Policy Name : Your choice
	- Click Create policy"
read -p "${BOLD}${YELLOW}Created Alert Policy? [ y/n ] : ${RESET}" PROCEED4

while [ $PROCEED4 != 'y' ];
do echo "Do it Manually" && read -p "${BOLD}${YELLOW}Created Alert Policy? [ y/n ] : ${RESET}" PROCEED4;
done
completed "Task 5"

completed "Lab"

remove_files 