curl -o default.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/default.sh
source default.sh

gcloud services enable notebooks.googleapis.com
gcloud notebooks instances list --location=us-west1-b
warning "https://console.cloud.google.com/vertex-ai/workbench/list/instances?project=$PROJECT_ID"
sleep 8
STATE=$(gcloud notebooks instances list --location=us-west1-b --format='value(STATE)')
echo $STATE

while [ $STATE != 'ACTIVE' ]; 
do echo $STATE && sleep 2 && STATE=$(gcloud notebooks instances list --location=us-west1-b --format='value(STATE)') ; 
done

if [ $STATE = 'ACTIVE' ]
then
echo "${BOLD}${GREEN}$STATE${RESET}"
fi
completed "Task 1"

JUPYTERLAB_URL=`gcloud notebooks instances describe qwiklabs-tensorflow-notebook --location=us-west1-b --format='value(proxyUri)'`
warning "Visit ${CYAN}https://$JUPYTERLAB_URL ${YELLOW}to open Jupyterlab"

warning "Run below command in Jupyterlab Terminal:
${MAGENTA}
	curl https://storage.googleapis.com/tensorflow_docs/docs/site/en/tutorials/images/transfer_learning.ipynb --output transfer_learning.ipynb
	jupyter nbconvert --clear-output --inplace transfer_learning.ipynb"

completed "Lab"

remove_files