curl -o default.sh https://raw.githubusercontent.com/user9-21/LearnToEarn-June-2022/main/files/default.sh
source default.sh

gcloud services enable notebooks.googleapis.com
#gcloud compute images describe-from-family tf2-ent-2-3-cpu --project deeplearning-platform-release

gcloud notebooks instances create instance-without-gpu \
  --vm-image-project=deeplearning-platform-release \
  --vm-image-family=tf2-ent-2-3-cpu \
  --machine-type=n1-standard-2 \
  --location=us-west1-b
  
gcloud notebooks instances list --location=us-west1-b

warning "https://console.cloud.google.com/vertex-ai/workbench/list/instances?project=$PROJECT_ID"
STATE=$(gcloud notebooks instances list --location=us-west1-b --format='value(STATE)')
echo $STATE
while [ $STATE = PROVISIONING ]; 
do echo "PROVISIONING" && sleep 2 && STATE=$(gcloud notebooks instances list --location=us-west1-b --format='value(STATE)') ; 
done

if [ $STATE = 'ACTIVE' ]
then
echo "${BOLD}${GREEN}$STATE ${RESET}"
fi

JUPYTERLAB_URL=`gcloud notebooks instances describe instance-without-gpu --location=us-west1-b --format='value(proxyUri)'`
warning "Visit ${CYAN}https://$JUPYTERLAB_URL ${YELLOW}to open Jupyterlab"

warning "Run below command in Jupyterlab Terminal:
${MAGENTA}
	git clone https://github.com/GoogleCloudPlatform/training-data-analyst
	${YELLOW}
	and navigate to training-data-analyst/self-paced-labs/ai-platform-qwikstart and run all command ai_platform_qwik_start.ipynb
	
	
	${CYAN}https://$JUPYTERLAB_URL/lab/tree/training-data-analyst/self-paced-labs/ai-platform-qwikstart/ai_platform_qwik_start.ipynb"

sleep 100
remove_files