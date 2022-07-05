curl -o default.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/default.sh
source default.sh
	
read -p "${BOLD}${YELLOW}    BigQuery Dataset Name : ${RESET}" DATASET
read -p "${BOLD}${YELLOW}Cloud Storage Bucket Name : ${RESET}" BUCKET
read -p "${BOLD}${YELLOW}                   Region : ${RESET}" REGION
echo "${BOLD}"
echo "${YELLOW}    BigQuery Dataset Name :${CYAN} $DATASET"
echo "${YELLOW}Cloud Storage Bucket Name :${CYAN} $BUCKET"
echo "${YELLOW}                   Region :${CYAN} $REGION"

read -p "${BOLD}${YELLOW}Verify all inside-details are correct? [ y/n ] : ${RESET}" VERIFY_DETAILS

while [ $VERIFY_DETAILS != 'y' ];
do echo " " && 
read -p "${BOLD}${YELLOW}    BigQuery Dataset Name : ${RESET}" DATASET && 
read -p "${BOLD}${YELLOW}Cloud Storage Bucket Name : ${RESET}" BUCKET && 
read -p "${BOLD}${YELLOW}                   Region : ${RESET}" REGION && 
echo "${BOLD}" && 
echo "${YELLOW}    BigQuery Dataset Name :${CYAN} $DATASET" && 
echo "${YELLOW}Cloud Storage Bucket Name :${CYAN} $BUCKET" && 
echo "${YELLOW}                   Region :${CYAN} $REGION" && 
read -p "${BOLD}${YELLOW}Verify all inside-details are correct? [ y/n ] : ${RESET}" VERIFY_DETAILS
done

bq mk $DATASET
gsutil mb -l $REGION gs://$BUCKET


gcloud dataflow jobs run Task1 --gcs-location gs://dataflow-templates-us-east1/latest/GCS_Text_to_BigQuery --region us-east1 --staging-location gs://$BUCKET/temp --parameters javascriptTextTransformGcsPath=gs://cloud-training/gsp323/lab.js,JSONPath=gs://cloud-training/gsp323/lab.schema,javascriptTextTransformFunctionName=transform,outputTable=$PROJECT_ID:$DATASET.customers_920,inputFilePattern=gs://cloud-training/gsp323/lab.csv,bigQueryLoadingTemporaryDirectory=gs://$BUCKET/bigquery_temp

gcloud dataflow jobs list 
STATE=`gcloud dataflow jobs list --region us-east1 --format="value(STATE)"`
echo $STATE
sleep 10
gcloud config set dataproc/region $REGION
gcloud config set compute/zone ${REGION}-b
gcloud dataproc clusters create sample-cluster --region $REGION
warning "
Run this in ssh:
${BG_RED}
hdfs dfs -cp gs://cloud-training/gsp323/data.txt /data.txt
exit
${RESET}"
gcloud compute ssh sample-cluster-m --zone=${REGION}-b --quiet

sleep 20
gcloud dataproc jobs submit spark --cluster sample-cluster \
  --class org.apache.spark.examples.SparkPageRank \
  --region $REGION \
  --jars file:///usr/lib/spark/examples/jars/spark-examples.jar -- /data.txt
  
gcloud dataproc jobs list
sleep 10
STATUS=`gcloud dataproc jobs list --region $REGION --format="value(STATUS)"`
echo $STATUS

warning "While Dataflow & Dataproc job are running, Start doing Dataprep Task, Visit - ${CYAN}https://console.cloud.google.com/dataprep?project=$PROJECT_ID {YELLOW} and accept Terms,grant required authorization to open Dataprep Dashboard.${RESET}${YELLOW}

	- Once Opened, Click Create Flow and import gs://cloud-training/gsp323/runs.csv into it.
	- Once Dataprep Sheet opened, Click Add Recipe:
			- Remove all rows with the state of FAILURE 
			${BLUE}	Click on column 10, Select FAILURE, Select Delete Rows, Click Add ${YELLOW}
			- Remove all rows with 0 or 0.0 as a score (Use the regex pattern /(^0$|^0\.0$)/)
			${BLUE}	Open column 9 menu, Select Filter, Select One Of, Paste REGEX, Select Keep, Click Add ${YELLOW}
			- Label columns with the names displayed on lab
			${BLUE}	Click on each column & Rename it ${YELLOW}
			- Once all 11 Recipe's are added, Click Run and wait for Dataflow Pipeline to Complete 
			
	 you can take help from Recipe.txt file "
cat > Recipe.txt <<EOF
${MAGENTA}
filter type: oneOf col: column10 oneOf: 'FAILURE' action: Delete
filter type: contains col: column9 contains: /(^0$|^0\.0$)/ action: Keep
rename type: manual mapping: [column2,'runid']
rename type: manual mapping: [column3,'userid']
rename type: manual mapping: [column4,'labid']
rename type: manual mapping: [column5,'lab_title']
rename type: manual mapping: [column6,'start']
rename type: manual mapping: [column7,'end']
rename type: manual mapping: [column8,'time']
rename type: manual mapping: [column9,'score']
rename type: manual mapping: [column10,'state']
EOF
cat Recipe.txt


STATE=`gcloud dataflow jobs list --region us-east1 --format="value(STATE)"`
while [ $STATE != 'Done' ]; 
do echo $STATE && sleep 5 && STATE=`gcloud dataflow jobs list --region us-east1 --format="value(STATE)"` ; 
done

if [ $STATE = 'Done' ]
then
echo "${BOLD}${GREEN}$STATE${RESET}" 
fi
completed "Task 1"

STATUS=`gcloud dataproc jobs list --region $REGION --format="value(STATUS)"`
while [ $STATUS != 'DONE' ]; 
do echo $STATUS && sleep 5 && STATUS=`gcloud dataproc jobs list --region $REGION --format="value(STATUS)"` ; 
done

if [ $STATUS = 'DONE' ]
then
echo "${BOLD}${GREEN}$STATUS${RESET}" 
fi
completed "Task 2"

gcloud iam service-accounts create my-natlang-sa \
  --display-name "my natural language service account"

gcloud iam service-accounts keys create ~/key.json \
  --iam-account my-natlang-sa@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com
  
cat > request.json <<EOF
{
  "config": {
      "encoding":"FLAC",
      "languageCode": "en-US"
  },
  "audio": {
      "uri":"gs://cloud-training/gsp323/task4.flac"
  }
}
EOF
gcloud services enable language.googleapis.com
gcloud services enable apikeys.googleapis.com
gcloud alpha services api-keys create --display-name="test"	
export add=`gcloud alpha services api-keys list --filter="displayName: test"  --format="value(NAME)"`
echo $add	
export API_KEY=`gcloud alpha services api-keys get-key-string $add --format="value(keyString)"`
echo $API_KEY
  
curl -s -X POST -H "Content-Type: application/json" --data-binary @request.json \
"https://speech.googleapis.com/v1/speech:recognize?key=${API_KEY}" > speech.json

gcloud ml language analyze-entities --content="Old Norse texts portray Odin as one-eyed and long-bearded, frequently wielding a spear named Gungnir and wearing a cloak and a broad hat." > language.json

cat > video-request.json <<EOF
{
   "inputUri":"gs://spls/gsp154/video/train.mp4",
   "features": [
       "LABEL_DETECTION"
   ]
}
EOF
curl -s -H 'Content-Type: application/json' \
    -H 'Authorization: Bearer '$(gcloud auth print-access-token)'' \
    'https://videointelligence.googleapis.com/v1/videos:annotate' \
    -d @video-request.json  > video.json

warning "${RED}You will find below details in between the instructions at ${CYAN}Task 4: AI ${BLUE}(https://www.cloudskillsboost.google/focuses/11044?parent=catalog#step8)${RED}

	- Only file name of Path should be entered below like if Google Cloud Speech API PATH is ${CYAN}gs://qwiklabs-gcp-XX-XXXXXXXXXXXX-marking/task4-gcs-XXX.result,${RED} it should be entered as ${CYAN}task4-gcs-XXX.result${RED} only."
	
read -p "${BOLD}${YELLOW}   Google Cloud Speech API PATH : ${RESET}" GCS_PATH
read -p "${BOLD}${YELLOW}Cloud Natural Language API PATH : ${RESET}" CNL_PATH	
read -p "${BOLD}${YELLOW} Google Video Intelligence PATH : ${RESET}" GVI_PATH
echo "${BOLD}"
echo "${YELLOW}   Google Cloud Speech API PATH :${CYAN} $GCS_PATH"
echo "${YELLOW}Cloud Natural Language API PATH :${CYAN} $CNL_PATH"
echo "${YELLOW} Google Video Intelligence PATH :${CYAN} $GVI_PATH"

read -p "${BOLD}${YELLOW}Confirm all inside-details are correct? [ y/n ] : ${RESET}" CONFIRM_DETAILS

while [ $CONFIRM_DETAILS != 'y' ];
do echo " " && 
read -p "${BOLD}${YELLOW}   Google Cloud Speech API PATH : ${RESET}" GCS_PATH && 
read -p "${BOLD}${YELLOW}Cloud Natural Language API PATH : ${RESET}" CNL_PATH && 
read -p "${BOLD}${YELLOW} Google Video Intelligence PATH : ${RESET}" GVI_PATH && 
echo "${BOLD}" && 
echo "${YELLOW}   Google Cloud Speech API PATH :${CYAN} $GCS_PATH" && 
echo "${YELLOW}Cloud Natural Language API PATH :${CYAN} $CNL_PATH" && 
echo "${YELLOW} Google Video Intelligence PATH :${CYAN} $GVI_PATH" && 
read -p "${BOLD}${YELLOW}Confirm all inside-details are correct? [ y/n ] : ${RESET}" CONFIRM_DETAILS
done

gsutil cp speech.json gs://$DEVSHELL_PROJECT_ID-marking/$GCS_PATH
gsutil cp language.json gs://$DEVSHELL_PROJECT_ID-marking/$CNL_PATH
gsutil cp video.json gs://$DEVSHELL_PROJECT_ID-marking/$GVI_PATH
  

completed "Task 4"

completed "Lab"

remove_files