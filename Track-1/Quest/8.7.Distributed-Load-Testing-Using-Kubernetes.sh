curl -o default.sh https://raw.githubusercontent.com/user9-21/GoogleCloudReady-Facilitator-program/main/files/default.sh
source default.sh


PROJECT=$(gcloud config get-value project)
REGION=us-central1
ZONE=${REGION}-a
CLUSTER=gke-load-test
TARGET=${PROJECT}.appspot.com
gcloud config set compute/region $REGION
gcloud config set compute/zone $ZONE
gsutil -m cp -r gs://spls/gsp182/distributed-load-testing-using-kubernetes .
cd distributed-load-testing-using-kubernetes/
gcloud builds submit --tag gcr.io/$PROJECT/locust-tasks:latest docker-image/.
completed "Task 1"

gcloud app deploy sample-webapp/app.yaml --region us-central --quiet
completed "Task 2"

gcloud container clusters create $CLUSTER \
  --zone $ZONE \
  --num-nodes=5
completed "Task 3"

sed -i -e "s/\[TARGET_HOST\]/$TARGET/g" kubernetes-config/locust-master-controller.yaml
sed -i -e "s/\[TARGET_HOST\]/$TARGET/g" kubernetes-config/locust-worker-controller.yaml
sed -i -e "s/\[PROJECT_ID\]/$PROJECT/g" kubernetes-config/locust-master-controller.yaml
sed -i -e "s/\[PROJECT_ID\]/$PROJECT/g" kubernetes-config/locust-worker-controller.yaml
kubectl apply -f kubernetes-config/locust-master-controller.yaml
kubectl get pods -l app=locust-master
kubectl apply -f kubernetes-config/locust-master-service.yaml
LOCUST_EXTERNAL_IP=$(kubectl get svc locust-master | grep locust-master | awk '{print $4}')
while [ $LOCUST_EXTERNAL_IP = '<pending>' ];
do sleep 10 && LOCUST_EXTERNAL_IP=$(kubectl get svc locust-master | grep locust-master | awk '{print $4}') && echo $LOCUST_EXTERNAL_IP ;
done
completed "Task 4"

kubectl apply -f kubernetes-config/locust-worker-controller.yaml
kubectl get pods -l app=locust-worker
kubectl scale deployment/locust-worker --replicas=20
kubectl get pods -l app=locust-worker
EXTERNAL_IP=$(kubectl get svc locust-master -o yaml | grep ip | awk -F": " '{print $NF}')
echo http://$EXTERNAL_IP:8089
echo http://$LOCUST_EXTERNAL_IP:8089
completed "Task 5"

completed "Lab"

remove_files 