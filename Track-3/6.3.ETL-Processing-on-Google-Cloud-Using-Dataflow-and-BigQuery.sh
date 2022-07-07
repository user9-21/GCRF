curl -o default.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/default.sh
source default.sh

gcloud services disable dataflow.googleapis.com
gcloud services enable dataflow.googleapis.com
gsutil -m cp -R gs://spls/gsp290/dataflow-python-examples .
export PROJECT=`gcloud config get-value project`
gsutil mb -c regional -l us-central1 gs://$PROJECT
completed "Task 1"

gsutil cp gs://spls/gsp290/data_files/usa_names.csv gs://$PROJECT/data_files/
gsutil cp gs://spls/gsp290/data_files/head_usa_names.csv gs://$PROJECT/data_files/
completed "Task 2"

bq mk lake
completed "Task 3"

warning "${CYAN}https://console.cloud.google.com/dataflow/jobs?project=$PROJECT_ID"

cat > Python-file.sh <<EOF
${BOLD}${MAGENTA}
curl -o default.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/default.sh
source default.sh

pip install apache-beam[gcp]==2.24.0
cd dataflow/
python dataflow_python_examples/data_ingestion.py --project=$PROJECT --region=us-central1 --runner=DataflowRunner --staging_location=gs://$PROJECT/test --temp_location gs://$PROJECT/test --input gs://$PROJECT/data_files/head_usa_names.csv --save_main_session
completed "Task 4"

python dataflow_python_examples/data_transformation.py --project=$PROJECT --region=us-central1 --runner=DataflowRunner --staging_location=gs://$PROJECT/test --temp_location gs://$PROJECT/test --input gs://$PROJECT/data_files/head_usa_names.csv --save_main_session
completed "Task 5"

sed -i "s#x.decode('utf8') for x in csv_row#x for x in csv_row#g" dataflow_python_examples/data_enrichment.py

python dataflow_python_examples/data_enrichment.py --project=$PROJECT --region=us-central1 --runner=DataflowRunner --staging_location=gs://$PROJECT/test --temp_location gs://$PROJECT/test --input gs://$PROJECT/data_files/head_usa_names.csv --save_main_session
completed "Task 6"

python dataflow_python_examples/data_lake_to_mart.py --worker_disk_type="compute.googleapis.com/projects//zones//diskTypes/pd-ssd" --max_num_workers=4 --project=$PROJECT --runner=DataflowRunner --staging_location=gs://$PROJECT/test --temp_location gs://$PROJECT/test --save_main_session --region=us-central1
completed "Task 7"

exit
EOF
warning "	Now do manually as given on lab page or run each command displayed below inside${CYAN} python shell ${YELLOW}or run this:

${BG_RED}
	source Python-file.sh ${RESET}"

cat Python-file.sh
cp Python-file.sh dataflow-python-examples/Python-file.sh
rm default.sh
docker run -it -e PROJECT=$PROJECT -v $(pwd)/dataflow-python-examples:/dataflow python:3.7 /bin/bash

completed "Lab"

remove_files