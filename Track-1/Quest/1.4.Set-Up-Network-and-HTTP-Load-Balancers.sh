curl -o default.sh https://raw.githubusercontent.com/user9-21/GoogleCloudReady-Facilitator-program/main/files/default.sh
source default.sh

gcloud config set compute/zone us-central1-a
gcloud config set compute/region us-central1
gcloud compute instances create www1 \
  --image-family debian-9 \
  --image-project debian-cloud \
  --zone us-central1-a \
  --tags network-lb-tag \
  --metadata startup-script="#! /bin/bash
    sudo apt-get update
    sudo apt-get install apache2 -y
    sudo service apache2 restart
    echo '<!doctype html><html><body><h1>www1</h1></body></html>' | tee /var/www/html/index.html"
gcloud compute instances create www2 \
  --image-family debian-9 \
  --image-project debian-cloud \
  --zone us-central1-a \
  --tags network-lb-tag \
  --metadata startup-script="#! /bin/bash
    sudo apt-get update
    sudo apt-get install apache2 -y
    sudo service apache2 restart
    echo '<!doctype html><html><body><h1>www2</h1></body></html>' | tee /var/www/html/index.html"
gcloud compute instances create www3 \
  --image-family debian-9 \
  --image-project debian-cloud \
  --zone us-central1-a \
  --tags network-lb-tag \
  --metadata startup-script="#! /bin/bash
    sudo apt-get update
    sudo apt-get install apache2 -y
    sudo service apache2 restart
    echo '<!doctype html><html><body><h1>www3</h1></body></html>' | tee /var/www/html/index.html"
gcloud compute firewall-rules create www-firewall-network-lb \
    --target-tags network-lb-tag --allow tcp:80
sleep 5    
gcloud compute instances list

completed "Task 1"


gcloud compute addresses create network-lb-ip-1 \
 --region us-central1
gcloud compute http-health-checks create basic-check
gcloud compute target-pools create www-pool \
    --region us-central1 --http-health-check basic-check
gcloud compute target-pools add-instances www-pool \
    --instances www1,www2,www3
gcloud compute forwarding-rules create www-rule \
    --region us-central1 \
    --ports 80 \
    --address network-lb-ip-1 \
    --target-pool www-pool
    

completed "Task 2"

gcloud compute forwarding-rules describe www-rule --region us-central1
gcloud compute forwarding-rules describe www-rule --format='get(IPAddress)'
export IP_ADDRESS=$(gcloud compute forwarding-rules describe www-rule --format='value(IPAddress)')
echo $IP_ADDRESS

#echo "${YELLOW}${BOLD}After some curl request, verify it and press `CTRL+C` Only once Carefully to exit the curl and continue with remaining command${RESET}"

for i in {1..50}; do  curl -m1 $IP_ADDRESS; done
#while true; do curl -m1 $IP_ADDRESS; done




gcloud compute instance-templates create lb-backend-template \
   --region=us-central1 \
   --network=default \
   --subnet=default \
   --tags=allow-health-check \
   --image-family=debian-9 \
   --image-project=debian-cloud \
   --metadata=startup-script='#! /bin/bash
     apt-get update
     apt-get install apache2 -y
     a2ensite default-ssl
     a2enmod ssl
     vm_hostname="$(curl -H "Metadata-Flavor:Google" \
     http://169.254.169.254/computeMetadata/v1/instance/name)"
     echo "Page served from: $vm_hostname" | \
     tee /var/www/html/index.html
     systemctl restart apache2'
gcloud compute instance-groups managed create lb-backend-group \
   --template=lb-backend-template --size=2 --zone=us-central1-a
gcloud compute firewall-rules create fw-allow-health-check \
    --network=default \
    --action=allow \
    --direction=ingress \
    --source-ranges=130.211.0.0/22,35.191.0.0/16 \
    --target-tags=allow-health-check \
    --rules=tcp:80
gcloud compute addresses create lb-ipv4-1 \
    --ip-version=IPV4 \
    --global
gcloud compute addresses describe lb-ipv4-1 \
    --format="get(address)" \
    --global
gcloud compute health-checks create http http-basic-check \
    --port 80
gcloud compute backend-services create web-backend-service \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=http-basic-check \
    --global
gcloud compute backend-services add-backend web-backend-service \
    --instance-group=lb-backend-group \
    --instance-group-zone=us-central1-a \
    --global
gcloud compute url-maps create web-map-http \
    --default-service web-backend-service
gcloud compute target-http-proxies create http-lb-proxy \
    --url-map web-map-http
gcloud compute forwarding-rules create http-content-rule \
    --address=lb-ipv4-1\
    --global \
    --target-http-proxy=http-lb-proxy \
    --ports=80
    

completed "Task 3"

completed "Lab"
warning "Verify Score on Lab Page before Removing files"
remove_files 
