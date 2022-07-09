curl -o default.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/default.sh
source default.sh

gcloud beta compute instances create crypto-driver \
--zone=us-east1-c \
--machine-type=n1-standard-1 \
--subnet=default \
--network-tier=PREMIUM \
--maintenance-policy=MIGRATE \
--service-account=$(gcloud iam service-accounts list --format='value(email)' --filter="compute") \
--scopes=https://www.googleapis.com/auth/cloud-platform \
--image=debian-9-stretch-v20200618 \
--image-project=debian-cloud \
--boot-disk-size=20GB \
--boot-disk-type=pd-standard \
--boot-disk-device-name=crypto-driver
completed "Task 1"

echo '
source default.sh
apt-get update -y
sudo apt install python3-pip -y
sudo pip3 install -U virtualenv
virtualenv -p python3 venv
source venv/bin/activate
sudo apt -y --allow-downgrades install openjdk-8-jdk git maven google-cloud-sdk=271.0.0-0 google-cloud-sdk-cbt=271.0.0-0
export PROJECT=$(gcloud info --format="value(config.project)")
export ZONE=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/zone" -H "Metadata-Flavor: Google"|cut -d/ -f4)
gcloud services enable bigtable.googleapis.com \
bigtableadmin.googleapis.com \
dataflow.googleapis.com \
--project=${PROJECT}
gcloud bigtable instances create cryptorealtime \
    --cluster=cryptorealtime-c1 \
    --cluster-zone=${ZONE} \
    --display-name=cryptorealtime \
    --cluster-storage-type=HDD \
    --instance-type=DEVELOPMENT
cbt -instance=cryptorealtime createtable cryptorealtime families=market
completed "Task 2"

gsutil mb -p ${PROJECT} gs://realtimecrypto-${PROJECT}
completed "Task 3"

git clone https://github.com/GoogleCloudPlatform/professional-services
cd professional-services/examples/cryptorealtime
mvn clean install
./run.sh ${PROJECT} \
cryptorealtime gs://realtimecrypto-${PROJECT}/temp \
cryptorealtime market
cbt -instance=cryptorealtime read cryptorealtime
completed "Task 4"

gcloud compute --project=${PROJECT} firewall-rules create crypto-dashboard \
--direction=INGRESS \
--priority=1000 \
--network=default \
--action=ALLOW \
--rules=tcp:5000 \
--source-ranges=0.0.0.0/0 \
--target-tags=crypto-console \
--description="Open port 5000 for crypto visualization tutorial"
gcloud compute instances add-tags crypto-driver --tags="crypto-console" --zone=${ZONE}
completed "Task 5"

cd frontend/
pip install -r requirements.txt
python app.py ${PROJECT} cryptorealtime cryptorealtime market' > ssh.sh
chmod +x ssh.sh

sleep 10
gcloud compute scp --zone=us-east1-c  --quiet default.sh crypto-driver:~
gcloud compute scp --zone=us-east1-c  --quiet ssh.sh crypto-driver:~
warning "
Run this in ssh:
${BG_RED}
sudo -s ${RESET}${BOLD}${YELLOW}
and run this inside it
${BG_RED}
./ssh.sh
${RESET}"
gcloud compute ssh --zone "us-east1-c" "crypto-driver"  --quiet

completed "Lab"

remove_files