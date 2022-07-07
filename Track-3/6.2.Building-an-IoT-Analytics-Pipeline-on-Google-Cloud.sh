curl -o default.sh https://raw.githubusercontent.com/user9-21/GoogleCloudReady-Facilitator-program/main/files/default.sh
source default.sh

gcloud pubsub topics create iotlab
completed "Task 1"
export IOT_EMAIL=cloud-iot@system.gserviceaccount.com
gcloud beta pubsub topics add-iam-policy-binding iotlab\
    --role roles/pubsub.publisher --member serviceAccount:$IOT_EMAIL
completed "Task 2"
bq mk iotlabdataset
completed "Task 3"
bq mk \
  -t \
  --label organization:development \
  iotlabdataset.sensordata \
  timestamp:TIMESTAMP,device:STRING,temperature:FLOAT
completed "Task 4"
gsutil mb -l us gs://$PROJECT_ID-bucket
completed "Task 5"
gcloud services enable dataflow.googleapis.com

gcloud dataflow jobs run iotlabflow --gcs-location gs://dataflow-templates-us-central1/latest/PubSub_to_BigQuery --region us-central1 --max-workers 2 --staging-location gs://$PROJECT_ID-bucket/tmp/ --parameters inputTopic=projects/$PROJECT_ID/topics/iotlab,outputTableSpec=$PROJECT_ID:iotlabdataset.sensordata

STATE=`gcloud dataflow jobs list --region us-central1 --format="value(STATE)"`
while [ $STATE != 'Done' ]; 
do echo $STATE && sleep 5 && STATE=`gcloud dataflow jobs list --region us-central1 --format="value(STATE)"` ;
done

if [ $STATE = 'Done' ]
then
echo "${BOLD}${GREEN}$STATE${RESET}" 
fi
completed "Task 6"

git clone http://github.com/GoogleCloudPlatform/training-data-analyst
export MY_REGION=us-central1
echo $PROJECT_ID && $MY_REGION
gcloud iot registries create iotlab-registry \
   --project=$PROJECT_ID \
   --region=$MY_REGION \
   --event-notification-config=topic=projects/$PROJECT_ID/topics/iotlab

completed "Task 7"

cd $HOME/training-data-analyst/quests/iotlab/
openssl req -x509 -newkey rsa:2048 -keyout rsa_private.pem \
    -nodes -out rsa_cert.pem -subj "/CN=unused"
gcloud iot devices create temp-sensor-buenos-aires \
  --project=$PROJECT_ID \
  --region=$MY_REGION \
  --registry=iotlab-registry \
  --public-key path=rsa_cert.pem,type=rs256
gcloud iot devices create temp-sensor-istanbul \
  --project=$PROJECT_ID \
  --region=$MY_REGION \
  --registry=iotlab-registry \
  --public-key path=rsa_cert.pem,type=rs256
completed "Task 8"

cd $HOME/training-data-analyst/quests/iotlab/
curl -o roots.pem -s -m 10 --retry 0 "https://pki.goog/roots.pem"
python cloudiot_mqtt_example_json.py \
   --project_id=$PROJECT_ID \
   --cloud_region=$MY_REGION \
   --registry_id=iotlab-registry \
   --device_id=temp-sensor-buenos-aires \
   --private_key_file=rsa_private.pem \
   --message_type=event \
   --algorithm=RS256 > buenos-aires-log.txt 2>&1 &
   

bq query --use_legacy_sql=false \
'SELECT timestamp, device, temperature from iotlabdataset.sensordata
ORDER BY timestamp DESC
LIMIT 100'

completed "Lab"

remove_files