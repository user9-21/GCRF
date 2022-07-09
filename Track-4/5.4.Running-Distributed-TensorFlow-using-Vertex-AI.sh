curl -o default.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/default.sh
source default.sh

gcloud services enable \
  compute.googleapis.com \
  iam.googleapis.com \
  iamcredentials.googleapis.com \
  monitoring.googleapis.com \
  logging.googleapis.com \
  notebooks.googleapis.com \
  aiplatform.googleapis.com \
  bigquery.googleapis.com \
  artifactregistry.googleapis.com \
  cloudbuild.googleapis.com \
  container.googleapis.com \
  notebooks.googleapis.com
  
SERVICE_ACCOUNT_ID=vertex-custom-training-sa
gcloud iam service-accounts create $SERVICE_ACCOUNT_ID  \
    --description="A custom service account for Vertex custom training" \
    --display-name="Vertex AI Custom Training"
PROJECT_ID=$(gcloud config get-value core/project)
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member=serviceAccount:$SERVICE_ACCOUNT_ID@$PROJECT_ID.iam.gserviceaccount.com \
    --role="roles/aiplatform.user"
	
completed "Task 1"

gcloud services enable notebooks.googleapis.com
#gcloud compute images describe-from-family tf2-ent-2-3-cpu --project deeplearning-platform-release

gcloud notebooks instances create instance-without-gpu \
  --vm-image-project=deeplearning-platform-release \
  --vm-image-family=tf2-ent-2-6-cpu \
  --machine-type=n1-standard-2 \
  --location=us-east1-b
  
gcloud notebooks instances list --location=us-east1-b
warning "https://console.cloud.google.com/vertex-ai/workbench/list/instances?project=$PROJECT_ID"
sleep 8
STATE=$(gcloud notebooks instances list --location=us-east1-b --format='value(STATE)')
echo $STATE

while [ $STATE != 'ACTIVE' ]; 
do echo $STATE && sleep 2 && STATE=$(gcloud notebooks instances list --location=us-east1-b --format='value(STATE)') ; 
done

if [ $STATE = 'ACTIVE' ]
then
echo "${BOLD}${GREEN}$STATE ${RESET}"
fi

completed "Task 2"
JUPYTERLAB_URL=`gcloud notebooks instances describe instance-without-gpu --location=us-east1-b --format='value(proxyUri)'`
warning "Visit ${CYAN}https://$JUPYTERLAB_URL ${YELLOW}to open Jupyterlab"

warning "Run below command in Jupyterlab Terminal:
${MAGENTA}
	git clone https://github.com/GoogleCloudPlatform/training-data-analyst
	${YELLOW}
	After cloning, execute Qwiklab_Running_Distributed_TensorFlow_using_Vertex_AI.ipynb file by visiting${CYAN} https://$JUPYTERLAB_URL/lab/tree/training-data-analyst/self-paced-labs/vertex-ai/vertex-distributed-tensorflow/Qwiklab_Running_Distributed_TensorFlow_using_Vertex_AI.ipynb

"



remove_files