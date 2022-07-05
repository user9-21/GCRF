curl -o default.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/default.sh
source default.sh

warning "Visit ${CYAN}https://console.cloud.google.com/apis/credentials?project=$PROJECT_ID ${YELLOW}and create an api key manually to get ${GREEN}Task 1${YELLOW} marks"

echo '
source default.sh
gcloud services enable language.googleapis.com
gcloud services enable apikeys.googleapis.com
gcloud alpha services api-keys create --display-name="test"	

export add=`gcloud alpha services api-keys list --filter="displayName: test"  --format="value(NAME)"`
echo $add	
export API_KEY=`gcloud alpha services api-keys get-key-string $add --format="value(keyString)"`
echo $API_KEY
cat > request.json <<EOF
{
  "config": {
      "encoding":"FLAC",
      "languageCode": "en-US"
  },
  "audio": {
      "uri":"gs://cloud-samples-tests/speech/brooklyn.flac"
  }
}
EOF
ls
completed "Task 2"
curl -s -X POST -H "Content-Type: application/json" --data-binary @request.json \
"https://speech.googleapis.com/v1/speech:recognize?key=${API_KEY}"
curl -s -X POST -H "Content-Type: application/json" --data-binary @request.json \
"https://speech.googleapis.com/v1/speech:recognize?key=${API_KEY}" > result.json
ls
completed "Task 3"

export PROJECT_ID=$(gcloud config get-value core/project)
# now go and create an api key manually to get the marks
warning "Visit ${CYAN}https://console.cloud.google.com/apis/credentials?project=$PROJECT_ID ${YELLOW}and create an api key manually to get ${GREEN}Task 1${YELLOW} marks"

completed "Lab"

remove_files
rm *
exit' > ssh.sh
chmod +x ssh.sh

sleep 2
gcloud compute scp --zone=us-central1-a  --quiet default.sh linux-instance:~
gcloud compute scp --zone=us-central1-a  --quiet ssh.sh linux-instance:~
warning "
Run this in ssh:
${BG_RED}
./ssh.sh
${RESET}"
gcloud compute ssh --zone "us-central1-a" "linux-instance"  --quiet


completed "Lab"

remove_files