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
  "document":{
    "type":"PLAIN_TEXT",
    "content":"A Smoky Lobster Salad With a Tapa Twist. This spin on the Spanish pulpo a la gallega skips the octopus, but keeps the sea salt, olive oil, pimentón and boiled potatoes."
  }
}
EOF

completed "Task 2"
curl "https://language.googleapis.com/v1/documents:classifyText?key=${API_KEY}" \
  -s -X POST -H "Content-Type: application/json" --data-binary @request.json
 
curl "https://language.googleapis.com/v1/documents:classifyText?key=${API_KEY}" \
  -s -X POST -H "Content-Type: application/json" --data-binary @request.json > result.json
 
completed "Task 3"
gsutil cat gs://spls/gsp063/bbc_dataset/entertainment/001.txt
bq mk news_classification_dataset
bq mk \
  -t \
  --label organization:development \
  news_classification_dataset.article_data \
  article_text:STRING,category:STRING,confidence:FLOAT
  
completed "Task 4"
export PROJECT=$(gcloud config get-value core/project)
gcloud iam service-accounts create my-account --display-name my-account
gcloud projects add-iam-policy-binding $PROJECT --member=serviceAccount:my-account@$PROJECT.iam.gserviceaccount.com --role=roles/bigquery.admin
gcloud iam service-accounts keys create key.json --iam-account=my-account@$PROJECT.iam.gserviceaccount.com
export GOOGLE_APPLICATION_CREDENTIALS=key.json

cat > classify-text.py <<EOF
from google.cloud import storage, language, bigquery
# Set up our GCS, NL, and BigQuery clients
storage_client = storage.Client()
nl_client = language.LanguageServiceClient()
# TODO: replace YOUR_PROJECT with your project name below
bq_client = bigquery.Client(project="$PROJECT")
dataset_ref = bq_client.dataset("news_classification_dataset")
dataset = bigquery.Dataset(dataset_ref)
table_ref = dataset.table("article_data")
table = bq_client.get_table(table_ref)
# Send article text to the NL APIs classifyText method
def classify_text(article):
        response = nl_client.classify_text(
                document=language.Document(
                        content=article,
                        type_=language.Document.Type.PLAIN_TEXT
                )
        )
        return response
rows_for_bq = []
files = storage_client.bucket("qwiklabs-test-bucket-gsp063").list_blobs()
print("Got article files from GCS, sending them to the NL API (this will take ~2 minutes)...")
# Send files to the NL API and save the result to send to BigQuery
for file in files:
        if file.name.endswith("txt"):
                article_text = file.download_as_bytes()
                nl_response = classify_text(article_text)
                if len(nl_response.categories) > 0:
                        rows_for_bq.append((str(article_text), nl_response.categories[0].name, nl_response.categories[0].confidence))
print("Writing NL API article data to BigQuery...")
# Write article text + category data to BQ
errors = bq_client.insert_rows(table, rows_for_bq)
assert errors == []
EOF
python3 classify-text.py

export PROJECT_ID=$(gcloud config get-value core/project)
# now go and create an api key manually to get the marks
warning "Visit ${CYAN}https://console.cloud.google.com/apis/credentials?project=$PROJECT_ID ${YELLOW}and create an api key manually to get ${GREEN}Task 1${YELLOW} marks"

completed "Lab"

remove_files
exit' > ssh.sh
chmod +x ssh.sh

gcloud compute scp --zone=us-central1-a  --quiet default.sh linux-instance:~
sleep 10
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