curl -o default.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/default.sh
source default.sh

gcloud services enable storage-api.googleapis.com
cat > values.json <<EOF
{  "name": "$GOOGLE_CLOUD_PROJECT",
   "location": "us",
   "storageClass": "multi_regional"
}
EOF
cat values.json

export OAUTH2_TOKEN=$(gcloud auth print-access-token)

export PROJECT_ID=$GOOGLE_CLOUD_PROJECT
echo $OAUTH2_TOKEN
echo $PROJECT_ID
curl -X POST --data-binary @values.json \
    -H "Authorization: Bearer $OAUTH2_TOKEN" \
    -H "Content-Type: application/json" \
    "https://www.googleapis.com/storage/v1/b?project=$PROJECT_ID"
completed "Task 1"


wget --output-document demo-image.png https://cdn.qwiklabs.com/E4%2BSx10I0HBeOFPB15BFPzf9%2F%2FOK%2Btf7S0Mbn6aQ8fw%3D
export OBJECT=$(realpath demo-image.png)
export BUCKET_NAME=$GOOGLE_CLOUD_PROJECT
echo $OBJECT
echo $BUCKET_NAME
curl -X POST --data-binary @$OBJECT \
    -H "Authorization: Bearer $OAUTH2_TOKEN" \
    -H "Content-Type: image/png" \
    "https://www.googleapis.com/upload/storage/v1/b/$BUCKET_NAME/o?uploadType=media&name=demo-image"
completed "Task 2"

completed "Lab"

remove_files