curl -o default.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/default.sh
source default.sh

gsutil mb gs://$PROJECT_ID
gcloud compute addresses create staticip --region=us-central1
IP=`gcloud compute addresses describe staticip --region=us-central1 --format="value(address)"`

gcloud compute instances create instance-1  --zone=us-central1-a --machine-type=e2-custom-4-8192 --network-interface=address=$IP,network-tier=PREMIUM,subnet=default --metadata=enable-oslogin=true --maintenance-policy=MIGRATE --provisioning-model=STANDARD --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --tags=http-server 
	
completed "Task 1"
gcloud compute firewall-rules create allow-http-web-server --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:80,icmp --source-ranges=0.0.0.0/0 --target-tags=http-server
echo '
curl -o default.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/default.sh
source default.sh
apt-get update
apt-get install -y protobuf-compiler python3-pil python3-lxml python3-pip python3-dev git
pip3 install --upgrade pip
pip3 install Flask==2.1.2 WTForms==3.0.1 Flask_WTF==1.0.1 Werkzeug==2.0.3 itsdangerous==2.1.2 jinja2==3.1.2 protobuf~=3.19.0
pip3 install tensorflow==2.9.0
cd /opt
git clone https://github.com/tensorflow/models
cd models/research
protoc object_detection/protos/*.proto --python_out=.
mkdir -p /opt/graph_def
cd /tmp

for model in \
  ssd_mobilenet_v1_coco_11_06_2017 \
  ssd_inception_v2_coco_11_06_2017 \
  rfcn_resnet101_coco_11_06_2017 \
  faster_rcnn_resnet101_coco_11_06_2017 \
  faster_rcnn_inception_resnet_v2_atrous_coco_11_06_2017
do \
  curl -OL http://download.tensorflow.org/models/object_detection/$model.tar.gz
  tar -xzf $model.tar.gz $model/frozen_inference_graph.pb
  cp -a $model /opt/graph_def/
done

ln -sf /opt/graph_def/faster_rcnn_resnet101_coco_11_06_2017/frozen_inference_graph.pb /opt/graph_def/frozen_inference_graph.pb

cd $HOME
git clone https://github.com/GoogleCloudPlatform/tensorflow-object-detection-example
cp -a tensorflow-object-detection-example/object_detection_app_p3 /opt/
chmod u+x /opt/object_detection_app_p3/app.py
cp /opt/object_detection_app_p3/object-detection.service /etc/systemd/system/
systemctl daemon-reload

systemctl enable object-detection
systemctl start object-detection
completed "Task 2" 
echo "${BOLD}${YELLOW}Visit${CYAN} http://<EXTERNAL_IP> ${YELLOW}and 

Log in with the following credentials:
${RED}
Username -${CYAN} username${RED}
Password -${CYAN} passw0rd
${RESET}" 

for i in {1..3}; do systemctl status object-detection && sleep 5; done

systemctl status object-detection' > ssh.sh
chmod +x ssh.sh
EXTERNAL_IP=`gcloud compute instances list --format="value(EXTERNAL_IP)"`

sed -i "s/<EXTERNAL_IP>/$EXTERNAL_IP/g" ssh.sh
gsutil cp ssh.sh gs://$PROJECT_ID/ 

sleep 4
warning "
Run this in ssh:
${BG_RED}
sudo -i ${RESET}${BOLD}${YELLOW}
and run this inside it
${BG_RED}
gsutil cp gs://$PROJECT_ID/ssh.sh .
source ssh.sh
${RESET}"
gcloud compute ssh --zone "us-central1-a" "instance-1"  --quiet

completed "Lab"

remove_files