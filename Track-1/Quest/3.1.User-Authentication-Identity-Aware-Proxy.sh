curl -o default.sh https://raw.githubusercontent.com/user9-21/GoogleCloudReady-Facilitator-program/main/files/default.sh
source default.sh


gsutil cp gs://spls/gsp499/user-authentication-with-iap.zip .
unzip user-authentication-with-iap.zip
cd user-authentication-with-iap
cd 1-HelloWorld
cat main.py
gcloud services enable iap.googleapis.com

echo "${YELLOW}${BOLD}
create IAP from console
Go here${CYAN} https://console.cloud.google.com/apis/credentials/consent/edit;newAppInternalUser=true?project=$PROJECT_ID ${YELLOW}and configure Internal IAP with the given credentials
 
  Name         : ${CYAN} IAP Example ${YELLOW}
  Home page    : ${CYAN} YOUR_APP_URL ${YELLOW}
  DOMAIN       : ${CYAN} YOUR_APP_URL ${YELLOW} ( Do not include the starting https:// or trailing / from that URL. )
  Email        : ${CYAN} LOGIN_EMAIL ${YELLOW}
  
   
 Click Save and Continue
${RESET}"
gcloud app create --region "us-central"
gcloud app deploy --quiet
gcloud app browse


completed "Task 1"

gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID --role roles/iap.httpsResourceAccessor --member user:$EMAIL

YOUR_URL=$(gcloud app browse | grep 'https')
echo " ${BOLD}${BG_YELLOW} 
Confirm your iap configuration has following credentials 
${RESET}${YELLOW}${BOLD}
Navigate here   -     ${CYAN}     https://console.cloud.google.com/security/iap?project=$PROJECT_ID ${YELLOW} 
 
  Name          : ${CYAN} IAP Example ${YELLOW} 
  Home page     : ${CYAN} $YOUR_URL ${YELLOW}
  DOMAIN        : ${CYAN} $YOUR_URL ${YELLOW} ( Do not include the starting https:// or trailing / from that URL. )
  Email         : ${CYAN} $EMAIL ${YELLOW}
  
 
${RESET}"

tput bold; tput setaf 3 ;tput blink;echo  WAIT; tput sgr0

gcloud services disable appengineflex.googleapis.com
EMAIL=$(gcloud config get-value account)

echo "${YELLOW}${BOLD}
Go here ${CYAN}https://console.cloud.google.com/security/iap?project=$PROJECT_ID ${YELLOW} and Turn on IAP by sliding the switch next to App Engine app
 - select App Engine app and click add Principal
 - enter your email : ${CYAN} $EMAIL ${YELLOW}
 - select role      : ${CYAN} IAP-Secured WEB app user ${YELLOW}
 - click Add
${RESET}"

completed "Task 2"


cd ~/user-authentication-with-iap/2-HelloUser
gcloud app deploy --quiet
echo "${GREEN}${BOLD}
Task 3 Completed
${RESET}"


cd ~/user-authentication-with-iap/3-HelloVerifiedUser
gcloud app deploy --quiet


completed "Task 3"

completed "Lab"

remove_files 
