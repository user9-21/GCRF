curl -o default.sh https://raw.githubusercontent.com/user9-21/GoogleCloudReady-Facilitator-program/main/files/default.sh
source default.sh


export BUCKET_NAME=$(gcloud info --format='value(config.project)')
gsutil mb gs://$BUCKET_NAME/
touch sample.txt
gsutil cp sample.txt gs://$BUCKET_NAME

completed "Task 1"

export PROJECT_ID=$(gcloud info --format='value(config.project)')

FIRSTUSER=$(gcloud config get-value core/account)
LASTUSER=$(gcloud projects get-iam-policy $PROJECT_ID | grep student | awk '{print $2}' | tail -1 | sed -e 's/user://gm;t;d')

if [ $FIRSTUSER = $LASTUSER ]
then
LASTUSER=$(gcloud projects get-iam-policy $PROJECT_ID | grep student | awk '{print $2}' | tail -2  | head -1 | sed -e 's/user://gm;t;d')
fi

if [ $FIRSTUSER = $LASTUSER ]
then
read -p "${YELLOW}${BOLD}Enter second Email Address : ${RESET}" LASTUSER
echo $LASTUSER
fi

warning "Your second Email ID =${CYAN} $LASTUSER"
gcloud projects remove-iam-policy-binding $PROJECT_ID --role='roles/viewer' --member user:$LASTUSER

completed "Task 2"

gcloud projects add-iam-policy-binding $PROJECT_ID --role='roles/storage.objectViewer' --member $LASTUSER

completed "Task 3"

completed "Lab"

remove_files 
