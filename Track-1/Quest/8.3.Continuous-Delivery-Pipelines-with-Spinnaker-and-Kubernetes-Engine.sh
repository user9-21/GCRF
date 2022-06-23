curl -o default.sh https://raw.githubusercontent.com/user9-21/GoogleCloudReady-Facilitator-program/main/files/default.sh
source default.sh

gcloud config set compute/zone us-central1-f
gcloud container clusters create spinnaker-tutorial --machine-type=n1-standard-2
gcloud iam service-accounts create spinnaker-account --display-name spinnaker-account
export SA_EMAIL=$(gcloud iam service-accounts list --filter="displayName:spinnaker-account"  --format='value(email)')
export PROJECT=$(gcloud info --format='value(config.project)')
gcloud projects add-iam-policy-binding $PROJECT --role='roles/storage.admin' --member serviceAccount:$SA_EMAIL
gcloud iam service-accounts keys create spinnaker-sa.json --iam-account $SA_EMAIL
gcloud pubsub topics create projects/$PROJECT/topics/gcr
gcloud pubsub subscriptions create gcr-triggers --topic projects/${PROJECT}/topics/gcr
export SA_EMAIL=$(gcloud iam service-accounts list --filter="displayName:spinnaker-account" --format='value(email)')
gcloud beta pubsub subscriptions add-iam-policy-binding gcr-triggers --role roles/pubsub.subscriber --member serviceAccount:$SA_EMAIL

completed "Task 1"

kubectl create clusterrolebinding user-admin-binding --clusterrole=cluster-admin --user=$(gcloud config get-value account)
kubectl create clusterrolebinding --clusterrole=cluster-admin --serviceaccount=default:default spinnaker-admin

helm repo add stable https://charts.helm.sh/stable
helm repo update
export PROJECT=$(gcloud info --format='value(config.project)')
export BUCKET=$PROJECT-spinnaker-config
gsutil mb -c regional -l us-central1 gs://$BUCKET

export SA_JSON=$(cat spinnaker-sa.json)
export PROJECT=$(gcloud info --format='value(config.project)')
export BUCKET=$PROJECT-spinnaker-config
cat > spinnaker-config.yaml <<EOF
gcs:
  enabled: true
  bucket: $BUCKET
  project: $PROJECT
  jsonKey: '$SA_JSON'
dockerRegistries:
- name: gcr
  address: https://gcr.io
  username: _json_key
  password: '$SA_JSON'
  email: 1234@5678.com
# Disable minio as the default storage backend
minio:
  enabled: false
# Configure Spinnaker to enable GCP services
halyard:
  spinnakerVersion: 1.19.4
  image:
    repository: us-docker.pkg.dev/spinnaker-community/docker/halyard
    tag: 1.32.0
    pullSecrets: []
  additionalScripts:
    create: true
    data:
      enable_gcs_artifacts.sh: |-
        \$HAL_COMMAND config artifact gcs account add gcs-$PROJECT --json-path /opt/gcs/key.json
        \$HAL_COMMAND config artifact gcs enable
      enable_pubsub_triggers.sh: |-
        \$HAL_COMMAND config pubsub google enable
        \$HAL_COMMAND config pubsub google subscription add gcr-triggers \
          --subscription-name gcr-triggers \
          --json-path /opt/gcs/key.json \
          --project $PROJECT \
          --message-format GCR
EOF

warning " iNSTALLING hELM
it can take upto 10 minutes. If taking more than 10 mins cancel by pressing 'CTRL + C' and install another helm chart you can try below mentioned code"

while sleep 1;do tput sc;tput cup 0 $(($(tput cols)-11));echo -e "\e[1;97m`date +%r`\e[39m";tput rc;done &
helm install -n default cd stable/spinnaker -f spinnaker-config.yaml --version 2.0.0-rc9 --timeout 20m0s --wait
export DECK_POD=$(kubectl get pods --namespace default -l "cluster=spin-deck"  -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward --namespace default $DECK_POD 8080:9000 >> /dev/null &

warning "WEB PREVIEW ON PORT 80"


completed "Task 2"


gsutil -m cp -r gs://spls/gsp114/sample-app.tar .
mkdir sample-app
tar xvf sample-app.tar -C ./sample-app
cd sample-app
git config --global user.email "$(gcloud config get-value core/account)"
git config --global user.name "$(gcloud config get-value core/account)"
git init
git add .
git commit -m "Initial commit"
gcloud source repos create sample-app
git config credential.helper gcloud.sh
export PROJECT=$(gcloud info --format='value(config.project)')
git remote add origin https://source.developers.google.com/p/$PROJECT/r/sample-app
git push origin master
gcloud services enable cloudbuild.googleapis.com
sleep 10
gcloud beta builds triggers create cloud-source-repositories --repo=sample-app --tag-pattern=v1.* --build-config=cloudbuild.yaml
export PROJECT=$(gcloud info --format='value(config.project)')
gsutil mb -l us-central1 gs://$PROJECT-kubernetes-manifests
gsutil versioning set on gs://$PROJECT-kubernetes-manifests
sed -i s/PROJECT/$PROJECT/g k8s/deployments/*
git commit -a -m "Set project ID"
git tag v1.0.0
git push --tags

warning "Origin master pushed
TRIGGER BUILD, NOW ${GREEN}Run Trigger${YELLOW} MANUALLY THROUGH CONSOLE :  ${CYAN}https://console.cloud.google.com/cloud-build/triggers?project=$PROJECT"

sleep 100
read -p "${BOLD}${YELLOW}Trigger Build Succedded? [y/n] : ${RESET}" PROCEED
while [ $PROCEED != 'y' ];
do sleep 5 && read -p "${BOLD}${YELLOW}Trigger Build Succedded? [y/n] : ${RESET}" PROCEED;
done

completed "Task 3"
curl -LO https://storage.googleapis.com/spinnaker-artifacts/spin/1.14.0/linux/amd64/spin
chmod +x spin
./spin application save --application-name sample \
                        --owner-email "$(gcloud config get-value core/account)" \
                        --cloud-providers kubernetes \
                        --gate-endpoint http://localhost:8080/gate
export PROJECT=$(gcloud info --format='value(config.project)')
sed s/PROJECT/$PROJECT/g spinnaker/pipeline-deploy.json > pipeline.json
./spin pipeline save --gate-endpoint http://localhost:8080/gate -f pipeline.json


warning "Now, Web Preview on port 80 to open spinnaker

Start MANUALLY Execution in spinnaker :${CYAN}
 - In the Spinnaker UI, click Applications at the top of the screen.
 - Click sample to view your application deployment.
 - Click Pipelines at the top to view your applications pipeline status.
 - Click Start Manual Execution and then click Run to trigger the pipeline this first time.
 - After 3 to 5 minutes the integration test phase completes and the pipeline requires manual approval to continue the deployment.

   Hover over the ${YELLOW}'yellow person'${CYAN} icon and click Continue. 
"
sleep 100
read -p "${BOLD}${YELLOW}Spinnaker Pipeline Build Succedded? [y/n] : ${RESET}" PROCEED1
while [ $PROCEED1 != 'y' ];
do sleep 5 && read -p "${BOLD}${YELLOW}Spinnaker Pipeline Build Succedded? [y/n] : ${RESET}" PROCEED1;
done

completed "Task 4"

completed "Task 5"

sed -i 's/orange/blue/g' cmd/gke-info/common-service.go
git commit -a -m "Change color to blue"
git tag v1.0.1
git push --tags

warning "Now wait for build to succeed both cloud build and Spinnaker and your lab is completed."

completed "Task 6"

completed "Lab"

remove_files 