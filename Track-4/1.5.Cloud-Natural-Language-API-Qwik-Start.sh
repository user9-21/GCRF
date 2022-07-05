curl -o default.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/default.sh
source default.sh

warning "Visit ${CYAN}https://console.cloud.google.com/apis/credentials?project=$PROJECT_ID ${YELLOW}and create an api key manually to get ${GREEN}Task 1${YELLOW} marks"
export GOOGLE_CLOUD_PROJECT=$(gcloud config get-value core/project)
gcloud iam service-accounts create my-natlang-sa \
  --display-name "my natural language service account"
gcloud iam service-accounts keys create ~/key.json \
  --iam-account my-natlang-sa@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com
export GOOGLE_APPLICATION_CREDENTIALS="/home/USER/key.json"
completed "Task 1"

echo '
source default.sh
ls
gcloud ml language analyze-entities --content="Michelangelo Caravaggio, Italian painter, is known for The Calling of Saint Matthew." > result.json
ls
cat result.json
completed "Lab"
rm *
exit' > ssh.sh
chmod +x ssh.sh

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