curl -o default.sh https://raw.githubusercontent.com/user9-21/GoogleCloudReady-Facilitator-program/main/files/default.sh
source default.sh

warning "Open ${CYAN}https://console.cloud.google.com/logs/metrics/edit?project=$GOOGLE_CLOUD_PROJECT

${YELLOW}
Enter the following options on the Create logs metric page:

 Metric Type       :${CYAN} Counter ${YELLOW}
 Log metric name   :${CYAN} Error_Rate_SLI ${YELLOW}
 Filter Selection  : "
 tput setaf 6;echo '
 
		resource.labels.cluster_name="cloud-ops-sandbox" AND resource.labels.namespace_name="default" AND resource.type="k8s_container" AND labels.k8s-pod/app="recommendationservice" AND severity>=ERROR'
tput sgr0; 

completed "Task 1"
PROJECT_NUMBER=$(gcloud projects describe $GOOGLE_CLOUD_PROJECT --format='value(projectNumber)')
warning "Open ${CYAN} https://console.cloud.google.com/monitoring/services/$PROJECT_NUMBER/canonical-ist:proj-$PROJECT_NUMBER-default-recommendationservice?project=$PROJECT_ID
${YELLOW}
Click on + Create SLO on the top right of the page.

 Choose a metric                  :${CYAN} Other${YELLOW}
 Request-based or windows-based   :${CYAN} Request Based${YELLOW}

Click Continue.

 Performance Metric   :${CYAN} custom.googleapis.com/opencensus/grpc.io/client/roundtrip_latency${YELLOW}
 Range type           :${CYAN} In Between ${YELLOW}
 Value                :${CYAN} 0-800ms${YELLOW}

Click Continue.

 Period type       :${CYAN} Calendar${YELLOW}
 Period length     :${CYAN} Calendar month${YELLOW}
 Performance Goal  :${CYAN} 99%${YELLOW}

Click Continue.

Click Create SLO. "
completed "Task 2"

warning " Under section ${CYAN}'Current status of 1 SLO'${YELLOW}, expand the now created SLO and click on +Create SLO Alert. 

Leave the default values.
Click Next. Click Next. Click Save.

"


completed "Lab"

remove_files 