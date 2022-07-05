curl -o default.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/default.sh
source default.sh

gsutil mb -l us-central1 gs://$PROJECT_ID/
completed "Task 1"
gcloud services enable dataflow.googleapis.com
python3 --version
pip3 --version
sudo pip3 install -U pip
sudo pip3 install --upgrade virtualenv
virtualenv -p python3.7 env
source env/bin/activate
pip install apache-beam[gcp]


python -m apache_beam.examples.wordcount --output outputfile
BUCKET=gs://$PROJECT_ID
python -m apache_beam.examples.wordcount --project $PROJECT_ID \
  --runner DataflowRunner \
  --staging_location $BUCKET/staging \
  --temp_location $BUCKET/temp \
  --output $BUCKET/results/output \
  --region us-central1
  
cat > laststep.sh <<EOF
${YELLOW}
# If Dataflow job failed , try manually
${BG_RED}
virtualenv -p python3.7 env
source env/bin/activate
pip install apache-beam[gcp]
python -m apache_beam.examples.wordcount --output outputfile
BUCKET=gs://$DEVSHELL_PROJECT_ID
python -m apache_beam.examples.wordcount --project $DEVSHELL_PROJECT_ID \
  --runner DataflowRunner \
  --staging_location $BUCKET/staging \
  --temp_location $BUCKET/temp \
  --output $BUCKET/results/output \
  --region us-central1 \
  --wait 120
  
  
EOF
cat laststep.sh  

completed "Task 2"

completed "Lab"

remove_files