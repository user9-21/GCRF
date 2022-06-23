curl -o default.sh https://raw.githubusercontent.com/user9-21/GoogleCloudReady-Facilitator-program/main/files/default.sh
source default.sh



export BUCKET_NAME=$(gcloud info --format='value(config.project)')
gsutil mb gs://$BUCKET_NAME/
completed "Task 1"

wget --output-document ada.jpg https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Ada_Lovelace_portrait.jpg/800px-Ada_Lovelace_portrait.jpg
gsutil cp ada.jpg gs://$BUCKET_NAME
rm ada.jpg
gsutil cp -r gs://$BUCKET_NAME/ada.jpg .
gsutil cp gs://$BUCKET_NAME/ada.jpg gs://$BUCKET_NAME/image-folder/


completed "Task 2"

gsutil ls gs://$BUCKET_NAME
gsutil ls -l gs://$BUCKET_NAME/ada.jpg
gsutil acl ch -u AllUsers:R gs://$BUCKET_NAME/ada.jpg
gsutil acl ch -d AllUsers gs://$BUCKET_NAME/ada.jpg
gsutil rm gs://$BUCKET_NAME/ada.jpg


completed "Task 3"

completed "Lab"

remove_files 
