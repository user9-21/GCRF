curl -o default.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/default.sh
source default.sh

echo " "
read -p "${BOLD}${YELLOW}Enter Bucket Name         : ${RESET}" BUCKET_NAME
read -p "${BOLD}${YELLOW}Enter Topic Name          : ${RESET}" TOPIC_NAME
read -p "${BOLD}${YELLOW}Enter Cloud Function Name : ${RESET}" FUNCTION_NAME
echo "${BOLD} "
echo "${YELLOW}Bucket Name         : ${CYAN}$BUCKET_NAME  "
echo "${YELLOW}Topic Name          : ${CYAN}$TOPIC_NAME  "
echo "${YELLOW}Cloud Function Name : ${CYAN}$FUNCTION_NAME  ${RESET}"
echo " "

read -p "${BOLD}${YELLOW}Verify all details are correct? [ y/n ] : ${RESET}" VERIFY_DETAILS


while [ $VERIFY_DETAILS != 'y' ];
do echo " " && 
read -p "${BOLD}${YELLOW}Enter Bucket Name         : ${RESET}" BUCKET_NAME && 
read -p "${BOLD}${YELLOW}Enter Topic Name          : ${RESET}" TOPIC_NAME && 
read -p "${BOLD}${YELLOW}Enter Cloud Function Name : ${RESET}" FUNCTION_NAME && 
echo "${BOLD} " && 
echo "${YELLOW}Bucket Name         : ${CYAN}$BUCKET_NAME  " && 
echo "${YELLOW}Topic Name          : ${CYAN}$TOPIC_NAME  " && 
echo "${YELLOW}Cloud Function Name : ${CYAN}$FUNCTION_NAME  ${RESET}"  && 
echo " " && 
read -p "${BOLD}${YELLOW}Verify all details are correct? [ y/n ] : ${RESET}" VERIFY_DETAILS;
done

gsutil mb gs://$BUCKET_NAME/
completed "Task 1"

gcloud pubsub topics create $TOPIC_NAME 
completed "Task 2"

mkdir thumbnail-nodejs
cd thumbnail-nodejs/  
curl -o index.js https://raw.githubusercontent.com/user9-21/GCRF/main/files/index.js
curl -o package.json https://raw.githubusercontent.com/user9-21/GCRF/main/files/package.json
sed -i "s/REPLACE_WITH_YOUR_TOPIC ID/$TOPIC_NAME/g" index.js

gcloud functions deploy $FUNCTION_NAME --region=us-east1 --trigger-bucket=gs://$BUCKET_NAME --runtime=nodejs10 --entry-point=thumbnail  --quiet

wget --output-document map.jpg https://storage.googleapis.com/cloud-training/gsp315/map.jpg
gsutil cp map.jpg gs://$BUCKET_NAME
completed "Task 3"

PROJECT_ID=$(gcloud info --format='value(config.project)')
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

echo "${BOLD}${YELLOW}
Your second Email ID =${CYAN} $LASTUSER 
${RESET}"

gcloud projects remove-iam-policy-binding $PROJECT_ID --role='roles/viewer' --member user:$LASTUSER
completed "Task 4"

completed "Lab"

remove_files 