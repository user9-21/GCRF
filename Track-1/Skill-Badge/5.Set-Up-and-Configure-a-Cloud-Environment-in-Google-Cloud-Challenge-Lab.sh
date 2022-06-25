curl -o default.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/default.sh
source default.sh


gcloud compute networks create griffin-dev-vpc --subnet-mode custom

gcloud compute networks subnets create griffin-dev-wp --network=griffin-dev-vpc --region us-east1 --range=192.168.16.0/20

gcloud compute networks subnets create griffin-dev-mgmt --network=griffin-dev-vpc --region us-east1 --range=192.168.32.0/20

completed "Task 1"

gsutil cp -r gs://cloud-training/gsp321/dm .

cd dm

sed -i s/SET_REGION/us-east1/g prod-network.yaml

gcloud deployment-manager deployments create prod-network \
    --config=prod-network.yaml

cd ..

completed "Task 2"

gcloud compute instances create bastion --network-interface=network=griffin-dev-vpc,subnet=griffin-dev-mgmt  --network-interface=network=griffin-prod-vpc,subnet=griffin-prod-mgmt --tags=ssh --zone=us-east1-b

gcloud compute firewall-rules create fw-ssh-dev --source-ranges=0.0.0.0/0 --target-tags ssh --allow=tcp:22 --network=griffin-dev-vpc

gcloud compute firewall-rules create fw-ssh-prod --source-ranges=0.0.0.0/0 --target-tags ssh --allow=tcp:22 --network=griffin-prod-vpc

completed "Task 3"

gcloud sql instances create griffin-dev-db --root-password password --region=us-east1

warning "use 'password' as password to connect SQL"
tput bold; tput setab 1 ;echo '
CREATE DATABASE wordpress;
CREATE USER "wp_user"@"%" IDENTIFIED BY "stormwind_rules";
GRANT ALL PRIVILEGES ON wordpress.* TO "wp_user"@"%";
FLUSH PRIVILEGES;
exit
'; tput sgr0;
gcloud sql connect griffin-dev-db

completed "Task 4"

gcloud container clusters create griffin-dev \
  --network griffin-dev-vpc \
  --subnetwork griffin-dev-wp \
  --machine-type n1-standard-4 \
  --num-nodes 2  \
  --zone us-east1-b


gcloud container clusters get-credentials griffin-dev --zone us-east1-b

cd ~/

gsutil cp -r gs://cloud-training/gsp321/wp-k8s .
completed "Task 5"


sed -i s/username_goes_here/wp_user/g wp-k8s/wp-env.yaml
sed -i s/password_goes_here/stormwind_rules/g wp-k8s/wp-env.yaml
cd wp-k8s
kubectl create -f wp-env.yaml
gcloud iam service-accounts keys create key.json     --iam-account=cloud-sql-proxy@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com
kubectl create secret generic cloudsql-instance-credentials     --from-file key.json
completed "Task 6"

sed -i s/YOUR_SQL_INSTANCE/griffin-dev-db/g wp-deployment.yaml
kubectl create -f wp-deployment.yaml
kubectl create -f wp-service.yaml
completed "Task 7"


WORDPRESS_EXTERNAL_IP=$(kubectl get services | grep wordpress | awk '{print $4}')

while [ $WORDPRESS_EXTERNAL_IP = '<pending>' ];
do sleep 4 && WORDPRESS_EXTERNAL_IP=$(kubectl get services | grep wordpress | awk '{print $4}') && echo $WORDPRESS_EXTERNAL_IP ;
done

echo "${BOLD}${BLUE}$WORDPRESS_EXTERNAL_IP${RESET}"

warning "${BOLD}${YELLOW} Create uptime check manually -${MAGENTA} https://console.cloud.google.com/monitoring/uptime?project=$PROJECT_ID 
${YELLOW}
	Title    :${MAGENTA} Wordpress-Uptime${YELLOW}
	Hostname :${MAGENTA} $WORDPRESS_EXTERNAL_IP${YELLOW}
	Path     :${MAGENTA} /${YELLOW}
	Click Next. Click Next. Click Create"
completed "Task 8"


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

gcloud projects add-iam-policy-binding $PROJECT_ID --role='roles/editor' --member user:$LASTUSER
completed "Task 9"

completed "Lab"

remove_files 