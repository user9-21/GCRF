curl -o default.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/default.sh
source default.sh


echo " "
read -p "${BOLD}${YELLOW}Enter Instance name   : ${RESET}" INSTANCE_NAME
read -p "${BOLD}${YELLOW}Enter App port number : ${RESET}" APP_PORT
read -p "${BOLD}${YELLOW}Enter Firewall rule   : ${RESET}" FIREWALL_RULE
echo "${BOLD} "
echo "${YELLOW}Instance name   : ${CYAN}$INSTANCE_NAME  "
echo "${YELLOW}App port number : ${CYAN}$APP_PORT  "
echo "${YELLOW}Firewall rule   : ${CYAN}$FIREWALL_RULE  ${RESET}"
echo " "

read -p "${BOLD}${YELLOW}Verify all details are correct? [ y/n ] : ${RESET}" VERIFY_DETAILS


while [ $VERIFY_DETAILS != 'y' ];
do echo " " && 
read -p "${BOLD}${YELLOW}Enter Instance name   : ${RESET}" INSTANCE_NAME && 
read -p "${BOLD}${YELLOW}Enter App port number : ${RESET}" APP_PORT && 
read -p "${BOLD}${YELLOW}Enter Firewall rule   : ${RESET}" FIREWALL_RULE && 
echo "${BOLD} " && 
echo "${YELLOW}Instance name   : ${CYAN}$INSTANCE_NAME  " && 
echo "${YELLOW}App port number : ${CYAN}$APP_PORT  " && 
echo "${YELLOW}Firewall rule   : ${CYAN}$FIREWALL_RULE  ${RESET}" && 
echo " " && 
read -p "${BOLD}${YELLOW}Verify all details are correct? [ y/n ] : ${RESET}" VERIFY_DETAILS;
done

gcloud compute instances create $INSTANCE_NAME \
          --network nucleus-vpc \
          --zone us-east1-b  \
          --machine-type f1-micro  \
          --image-family debian-9  \
          --image-project debian-cloud 
completed "Task 1"

gcloud container clusters create nucleus-backend \
          --num-nodes 1 \
          --network nucleus-vpc \
          --zone us-east1-b
gcloud container clusters get-credentials nucleus-backend \
          --zone us-east1-b

kubectl create deployment hello-server \
          --image=gcr.io/google-samples/hello-app:2.0

kubectl expose deployment hello-server \
          --type=LoadBalancer \
          --port $APP_PORT

completed "Task 2"

cat << EOF > startup.sh
#! /bin/bash
apt-get update
apt-get install -y nginx
service nginx start
sed -i -- 's/nginx/Google Cloud Platform - '"\$HOSTNAME"'/' /var/www/html/index.nginx-debian.html
EOF

gcloud compute instance-templates create web-server-template \
       --metadata-from-file startup-script=startup.sh \
       --network nucleus-vpc \
       --machine-type g1-small \
       --region us-east1

gcloud compute target-pools create nginx-pool --region us-east1

gcloud compute instance-groups managed create web-server-group \
       --base-instance-name web-server \
       --size 2 \
       --template web-server-template \
       --region us-east1

gcloud compute firewall-rules create $FIREWALL_RULE \
       --allow tcp:80 \
       --network nucleus-vpc

gcloud compute http-health-checks create http-basic-check

gcloud compute instance-groups managed \
       set-named-ports web-server-group \
       --named-ports http:80 \
       --region us-east1

gcloud compute backend-services create web-server-backend \
       --protocol HTTP \
       --http-health-checks http-basic-check \
       --global

gcloud compute backend-services add-backend web-server-backend \
       --instance-group web-server-group \
       --instance-group-region us-east1 \
       --global

gcloud compute url-maps create web-server-map \
       --default-service web-server-backend

gcloud compute target-http-proxies create http-lb-proxy \
       --url-map web-server-map

gcloud compute forwarding-rules create http-content-rule \
        --global \
        --target-http-proxy http-lb-proxy \
        --ports 80
		
gcloud compute forwarding-rules list
gcloud compute forwarding-rules describe http-content-rule  --global
gcloud compute forwarding-rules describe http-content-rule --global --format='get(IPAddress)'
warning "${CYAN} https://console.cloud.google.com/net-services/loadbalancing/loadBalancers/list?project=$PROJECT_ID"
export IP_ADDRESS=$(gcloud compute forwarding-rules describe http-content-rule --global --format='value(IPAddress)')
echo $IP_ADDRESS
warning "Wait for Frontend to load - ${BLUE}http://$IP_ADDRESS"
completed "Task 3"

completed "Lab"

remove_files 