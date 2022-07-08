curl -o default.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/default.sh
source default.sh

warning "Visit ${CYAN}https://console.cloud.google.com/apis/credentials?project=$PROJECT_ID ${YELLOW}and create an api key manually to get ${GREEN}Task 1${YELLOW} marks"
gcloud services enable language.googleapis.com
gcloud services enable apikeys.googleapis.com
gcloud alpha services api-keys create --display-name="test"	

export add=`gcloud alpha services api-keys list --filter="displayName: test"  --format="value(NAME)"`
echo $add	
export API_KEY=`gcloud alpha services api-keys get-key-string $add --format="value(keyString)"`
echo $API_KEY
completed "Task 1"


cat > request.json <<EOF
{
  "config": {
      "encoding":"FLAC",
      "languageCode": "en-US"
  },
  "audio": {
      "uri":"gs://cloud-samples-data/speech/brooklyn_bridge.flac"
  }
}
EOF
completed "Task 2"
curl -s -X POST -H "Content-Type: application/json" --data-binary @request.json \
"https://speech.googleapis.com/v1/speech:recognize?key=${API_KEY}" > result.json

completed "Task 3"
warning "Visit ${CYAN}https://console.cloud.google.com/apis/credentials?project=$PROJECT_ID ${YELLOW}and create an api key manually to get ${GREEN}Task 1${YELLOW} marks"

completed "Lab"

remove_files