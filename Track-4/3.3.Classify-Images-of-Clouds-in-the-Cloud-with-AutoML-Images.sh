PROJECT_ID=`gcloud projects list  --format='value(project_id)'| grep qwiklabs-gcp | head -1`
gcloud config set project $PROJECT_ID

curl -o default.sh https://raw.githubusercontent.com/user9-21/LearnToEarn-June-2022/main/files/default.sh
source default.sh

echo "${BOLD}${CYAN}$PROJECT_ID${RESET}"

git clone https://github.com/GoogleCloudPlatform/data-science-on-gcp
cd ~/data-science-on-gcp/10_mlops
pip3 install google-cloud-aiplatform cloudml-hypertune kfp numpy tensorflow

cat model.py
export PROJECT_ID=$(gcloud info --format='value(config.project)')
export BUCKET_NAME=$PROJECT_ID-dsongcp

warning "https://console.cloud.google.com/vertex-ai?project=$PROJECT_ID"
python3 model.py --bucket $BUCKET_NAME --develop

cat train_on_vertexai.py
warning " It takes approximately 30 minutes to complete the job"
python3 train_on_vertexai.py --project $PROJECT_ID --bucket $BUCKET_NAME --develop --cpuonly --tfversion 2.6

completed "Task 1"

completed "Lab"

remove_files