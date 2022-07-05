curl -o default.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/default.sh
source default.sh


echo " "
read -p "${BOLD}${YELLOW}          Language : ${RESET}" LANGUAGE
read -p "${BOLD}${YELLOW}            Locale : ${RESET}" LOCALE
read -p "${BOLD}${YELLOW}     BigQuery Role : ${RESET}" BIGQUERY_ROLE
read -p "${BOLD}${YELLOW}Cloud Storage Role : ${RESET}" CLOUD_STORAGE_ROLE
echo "${BOLD}" 
echo "${YELLOW}           Language :${CYAN} $LANGUAGE "
echo "${YELLOW}            Locale  :${CYAN} $LOCALE "
echo "${YELLOW}     BigQuery Role  :${CYAN} $BIGQUERY_ROLE "
echo "${YELLOW}Cloud Storage Role  :${CYAN} $CLOUD_STORAGE_ROLE "
echo " "

read -p "${BOLD}${YELLOW}Verify all details are correct? [ y/n ] : ${RESET}" VERIFY_DETAILS

while [ $VERIFY_DETAILS != 'y' ];
do echo " " && 
read -p "${BOLD}${YELLOW}          Language : ${RESET}" LANGUAGE && 
read -p "${BOLD}${YELLOW}            Locale : ${RESET}" LOCALE && 
read -p "${BOLD}${YELLOW}     BigQuery Role : ${RESET}" BIGQUERY_ROLE && 
read -p "${BOLD}${YELLOW}Cloud Storage Role : ${RESET}" CLOUD_STORAGE_ROLE && 
echo "${BOLD}"  && 
echo "${YELLOW}           Language :${CYAN} $LANGUAGE " && 
echo "${YELLOW}            Locale  :${CYAN} $LOCALE " && 
echo "${YELLOW}     BigQuery Role  :${CYAN} $BIGQUERY_ROLE " && 
echo "${YELLOW}Cloud Storage Role  :${CYAN} $CLOUD_STORAGE_ROLE " && 
echo " " && 
read -p "${BOLD}${YELLOW}Verify all details are correct? [ y/n ] : ${RESET}" VERIFY_DETAILS ;
done

export SA=challenge
gcloud iam service-accounts create $SA
gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID --member=serviceAccount:$SA@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com --role=$BIGQUERY_ROLE
gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID --member=serviceAccount:$SA@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com --role=$CLOUD_STORAGE_ROLE
gcloud iam service-accounts keys create sa-key.json --iam-account $SA@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com
completed "Task 1"

export GOOGLE_APPLICATION_CREDENTIALS=${PWD}/sa-key.json
echo $GOOGLE_APPLICATION_CREDENTIALS
completed "Task 2"
#gsutil cp gs://$DEVSHELL_PROJECT_ID/analyze-images.py .

wget  https://raw.githubusercontent.com/user9-21/GCRF/main/Track-4/analyze-images.py

sed -i "s/'en'/'${LOCALE}'/g" analyze-images.py
python3 analyze-images.py $DEVSHELL_PROJECT_ID $DEVSHELL_PROJECT_ID
completed "Task 3"
completed "Task 4"

bq query --use_legacy_sql=false \ 'SELECT locale,COUNT(locale) as lcount FROM image_classification_dataset.image_text_detail GROUP BY locale ORDER BY lcount DESC'

completed "Task 5"

completed "Lab"

remove_files