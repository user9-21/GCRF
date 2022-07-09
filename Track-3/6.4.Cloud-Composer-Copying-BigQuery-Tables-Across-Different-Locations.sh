curl -o default.sh https://raw.githubusercontent.com/user9-21/LearnToEarn-June-2022/main/files/default.sh
source default.sh

gsutil mb -l us gs://$PROJECT_ID-us
gsutil mb -l eu gs://$PROJECT_ID-eu

warning "It can take up to 20 minutes for the environment to complete the setup process.
${CYAN}
	https://console.cloud.google.com/composer/environments?project=$PROJECT_ID"
gcloud composer environments create composer-advanced-lab  --location us-east1 --zone us-east1-c

completed "Task 1"

gcloud composer environments describe composer-advanced-lab --location us-east1
completed "Task 2"

bq --location=eu mk nyc_tlc_EU
completed "Task 3"

export DAGS_BUCKET=`gcloud composer environments describe composer-advanced-lab --location=us-east1 --format='value(config.dagGcsPrefix)'`
echo $DAGS_BUCKET
cd ~
gsutil -m cp -r gs://spls/gsp283/python-docs-samples .
gsutil cp -r python-docs-samples/third_party/apache-airflow/plugins/* gs://$DAGS_BUCKET/plugins
gsutil cp python-docs-samples/composer/workflows/bq_copy_across_locations.py gs://$DAGS_BUCKET/dags
gsutil cp python-docs-samples/composer/workflows/bq_copy_eu_to_us_sample.csv gs://$DAGS_BUCKET/dags

gsutil cp python-docs-samples/composer/workflows/bq_copy_across_locations.py $DAGS_BUCKET
gsutil cp python-docs-samples/composer/workflows/bq_copy_eu_to_us_sample.csv $DAGS_BUCKET
completed "Task 4"

completed "Lab"

remove_files