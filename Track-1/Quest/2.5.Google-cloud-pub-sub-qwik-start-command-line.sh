curl -o default.sh https://raw.githubusercontent.com/user9-21/GoogleCloudReady-Facilitator-program/main/files/default.sh
source default.sh

gcloud pubsub topics create myTopic
completed "Task 1"


gcloud  pubsub subscriptions create --topic myTopic mySubscription
completed "Task 2"

completed "Lab"

remove_files 
