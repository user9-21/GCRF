curl -o default.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/default.sh
source default.sh

bq mk demo_dataset
completed "Task 1"

bq cp bigquery-public-data:new_york_taxi_trips.tlc_yellow_trips_2018 $(gcloud config get project):demo_dataset.trips
completed "Task 2"

gcloud services enable datacatalog.googleapis.com

warning "${CYAN} https://console.cloud.google.com/datacatalog?project=$PROJECT_ID ${YELLOW}"

gcloud data-catalog tag-templates create demo_tag_template --location=us-central1 \
--field=id=source_of_data_asset,display-name='Source of data asset',type=string,required=TRUE \
--field=id=number_of_rows_in_data_asset,display-name='Number of rows in data asset',type=double \
--field=id=has_pii,display-name='Has PII',type=bool \
--field=id=pii_type,display-name='PII type',type='enum(Email|Social Security Number|None)' \
--display-name='Demo Tag Template' 

ENTRY_NAME=`gcloud data-catalog entries lookup "//bigquery.googleapis.com/projects/$PROJECT_ID/datasets/demo_dataset/tables/trips" --format="value(name)"`

cat > tag_file.json << EOF
  {
    "source_of_data_asset": "tlc_yellow_trips_2018",
    "pii_type": "NONE"
  }
EOF

gcloud data-catalog tags create --entry=${ENTRY_NAME} \
    --tag-template=demo_tag_template --tag-template-location=us-central1 --tag-file=tag_file.json

completed "Task 3"

completed "Lab"

remove_files