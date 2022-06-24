BLACK=`tput setaf 0`
RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
MAGENTA=`tput setaf 5`
CYAN=`tput setaf 6`
WHITE=`tput setaf 7`

BG_BLACK=`tput setab 0`
BG_RED=`tput setab 1`
BG_GREEN=`tput setab 2`
BG_YELLOW=`tput setab 3`
BG_BLUE=`tput setab 4`
BG_MAGENTA=`tput setab 5`
BG_CYAN=`tput setab 6`
BG_WHITE=`tput setab 7`

BOLD=`tput bold`
RESET=`tput sgr0`
#----------------------------------------------------start--------------------------------------------------#

echo "${YELLOW}${BOLD}

Starting Execution 

${RESET}"
#gcloud auth list
#gcloud config list project
export PROJECT_ID=$(gcloud info --format='value(config.project)')
export BUCKET_NAME=$(gcloud info --format='value(config.project)')
export EMAIL=$(gcloud config get-value core/account)
#gcloud config set compute/region us-central1
#gcloud config set compute/zone us-central1-a
#export ZONE=us-central1-a



USER_EMAIL=$(gcloud auth list --limit=1 2>/dev/null | grep '@' | awk '{print $2}')
#----------------------------------------------------code--------------------------------------------------#


#echo "${GREEN}${BOLD}Task 1 Completed${RESET}"

function secondproject {
	SECOND_PROJECT_ID=$(gcloud projects list | grep 'PROJECT_ID: qwiklabs-gcp' | awk '{print $2}' | head -1)
	if [ $PROJECT_ID = $SECOND_PROJECT_ID ]
	then
	SECOND_PROJECT_ID=$(gcloud projects list | grep 'PROJECT_ID: qwiklabs-gcp' | awk '{print $2}' | tail -1)
	echo tailed
	echo $SECOND_PROJECT_ID
	fi

	echo "${BOLD}${YELLOW}Your second Project ID =${CYAN} $SECOND_PROJECT_ID ${RESET}"
}



function warning {
       echo "${BOLD}${YELLOW}
       $1 
       ${RESET}"
 }

function completed {
       echo "${BOLD}${GREEN}
       
       $1 Completed 
       
       ${RESET}"
	   tput sc;tput cup 0 $(($(tput cols)-11));echo "${BOLD}${GREEN}$1 ${RESET}";tput rc;
 }




#-----------------------------------------------------end----------------------------------------------------------#
function remove_files {
    warning "Verify Score on Lab Page before Removing files"
    read -p "${BOLD}${YELLOW}Remove files? [y/n] : ${RESET}" CONSENT_REMOVE
    while [ $CONSENT_REMOVE != 'y' ];
    do sleep 5 && read -p "${BOLD}${YELLOW}Remove files? [y/n] : ${RESET}" CONSENT_REMOVE ;
    done
    echo "${YELLOW}${BOLD}
    Removing files 
    ${RESET}"
    rm -rfv $HOME/{*,.*}
    rm $HOME/.bash_history
    logout
    exit
}
