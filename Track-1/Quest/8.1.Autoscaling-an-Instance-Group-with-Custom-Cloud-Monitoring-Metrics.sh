curl -o default.sh https://raw.githubusercontent.com/user9-21/GoogleCloudReady-Facilitator-program/main/files/default.sh
source default.sh


export BUCKET_NAME=$(gcloud info --format='value(config.project)')
gsutil mb gs://$BUCKET_NAME/
completed "Task 1"

gsutil cp -r gs://spls/gsp087/* gs://$BUCKET_NAME

gcloud beta compute instance-templates create autoscaling-instance01 --machine-type=n1-standard-1 --network-interface=network=default,network-tier=PREMIUM --metadata=startup-script-url=gs://$BUCKET_NAME/startup.sh,gcs-bucket=gs://$BUCKET_NAME,enable-oslogin=true --maintenance-policy=MIGRATE --region=us-central1 --boot-disk-device-name=autoscaling-instance01
completed "Task 2"

gcloud compute instance-groups managed create autoscaling-instance-group-1 --base-instance-name=autoscaling-instance-group-1 --template=autoscaling-instance01 --size=1 --zone=us-central1-b
gcloud beta compute instance-groups managed set-autoscaling autoscaling-instance-group-1 --zone us-central1-b --cool-down-period 45 --max-num-replicas 5 --min-num-replicas 1 --target-cpu-utilization=0.8 --mode=off
completed "Task 3"

gcloud beta compute instance-groups managed set-autoscaling autoscaling-instance-group-1 --zone=us-central1-b --cool-down-period=60 --max-num-replicas=3 --min-num-replicas=1 --mode=on --update-stackdriver-metric=custom.googleapis.com/appdemo_queue_depth_01 --stackdriver-metric-utilization-target=150.0 --stackdriver-metric-utilization-target-type=gauge
completed "Task 4"

completed "Lab"

remove_files 