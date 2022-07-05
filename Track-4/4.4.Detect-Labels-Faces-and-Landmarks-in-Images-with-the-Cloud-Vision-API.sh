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
export BUCKET_NAME=$GOOGLE_CLOUD_PROJECT
echo $BUCKET_NAME
gsutil mb -b off gs://$BUCKET_NAME
wget --output-document donuts.png https://cdn.qwiklabs.com/V4PmEUI7yXdKpytLNRqwV%2ByGHqym%2BfhdktVi8nj4pPs%3D
gsutil cp donuts.png gs://$BUCKET_NAME
gsutil acl ch -u AllUsers:R gs://$BUCKET_NAME/donuts.png
completed "Task 2"

cat > request.json <<EOF
{
  "requests": [
      {
        "image": {
          "source": {
              "gcsImageUri": "gs://$BUCKET_NAME/donuts.png"
          }
        },
        "features": [
          {
            "type": "LABEL_DETECTION",
            "maxResults": 10
          }
        ]
      }
  ]
}
EOF
curl -s -X POST -H "Content-Type: application/json" --data-binary @request.json  https://vision.googleapis.com/v1/images:annotate?key=${API_KEY}
sed -i "s/LABEL_DETECTION/WEB_DETECTION/g" request.json
cat request.json
curl -s -X POST -H "Content-Type: application/json" --data-binary @request.json  https://vision.googleapis.com/v1/images:annotate?key=${API_KEY}
wget --output-document selfie.png https://cdn.qwiklabs.com/5%2FxwpTRxehGuIRhCz3exglbWOzueKIPikyYj0Rx82L0%3D
gsutil cp selfie.png gs://$BUCKET_NAME
gsutil acl ch -u AllUsers:R gs://$BUCKET_NAME/selfie.png
rm request.json
completed "Task 3"
cat > request.json <<EOF
{
  "requests": [
      {
        "image": {
          "source": {
              "gcsImageUri": "gs://$BUCKET_NAME/selfie.png"
          }
        },
        "features": [
          {
            "type": "FACE_DETECTION"
          },
          {
            "type": "LANDMARK_DETECTION"
          }
        ]
      }
  ]
}
EOF
curl -s -X POST -H "Content-Type: application/json" --data-binary @request.json  https://vision.googleapis.com/v1/images:annotate?key=${API_KEY}
wget --output-document city.png https://cdn.qwiklabs.com/%2Fv47QS0KOC28%2F03bZx0R%2FO0iLLvtYQUOZyvnjIfz%2BIE%3D
gsutil cp city.png gs://$BUCKET_NAME
gsutil acl ch -u AllUsers:R gs://$BUCKET_NAME/city.png
rm request.json
completed "Task 4"
cat > request.json <<EOF
{
  "requests": [
      {
        "image": {
          "source": {
              "gcsImageUri": "gs://$BUCKET_NAME/city.png"
          }
        },
        "features": [
          {
            "type": "LANDMARK_DETECTION",
            "maxResults": 10,
          }
        ]
      }
  ]
}
EOF
curl -s -X POST -H "Content-Type: application/json" --data-binary @request.json  https://vision.googleapis.com/v1/images:annotate?key=${API_KEY}

# now go and create an api key manually to get the marks
warning "Visit ${CYAN}https://console.cloud.google.com/apis/credentials?project=$PROJECT_ID ${YELLOW}and create an api key manually to get ${GREEN}Task 1${YELLOW} marks"

completed "Lab"

remove_files