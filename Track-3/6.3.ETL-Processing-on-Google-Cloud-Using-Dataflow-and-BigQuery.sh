curl -o default.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/default.sh
source default.sh

gcloud services enable dataflow.googleapis.com
gsutil -m cp -R gs://spls/gsp290/dataflow-python-examples .
export PROJECT=$GOOGLE_CLOUD_PROJECT
gcloud config set project $PROJECT
gsutil mb -c regional -l us-central1 gs://$PROJECT
completed "Task 1"

gsutil cp gs://spls/gsp290/data_files/usa_names.csv gs://$PROJECT/data_files/
gsutil cp gs://spls/gsp290/data_files/head_usa_names.csv gs://$PROJECT/data_files/
completed "Task 2"

bq mk lake
completed "Task 3"

echo "${CYAN}		Now do manually as given on lab page"

warning "${CYAN}https://console.cloud.google.com/dataflow/jobs?project=$PROJECT_ID"

rm default.sh
rm .bash_history