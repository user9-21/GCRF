curl -o default.sh https://raw.githubusercontent.com/user9-21/GoogleCloudReady-Facilitator-program/main/files/default.sh
source default.sh

mkdir gcf_hello_world
cd gcf_hello_world
cat > index.js <<EOF
/**
* Background Cloud Function to be triggered by Pub/Sub.
* This function is exported by index.js, and executed when
* the trigger topic receives a message.
*
* @param {object} data The event payload.
* @param {object} context The event metadata.
*/
exports.helloWorld = (data, context) => {
const pubSubMessage = data;
const name = pubSubMessage.data
    ? Buffer.from(pubSubMessage.data, 'base64').toString() : "Hello World";
console.log(`My Cloud Function: ${name}`);
};
EOF


export BUCKET_NAME=$(gcloud info --format='value(config.project)')
gsutil mb -p $BUCKET_NAME gs://$BUCKET_NAME

completed "Task 1"

gcloud functions deploy helloWorld \
  --stage-bucket $BUCKET_NAME \
  --trigger-topic hello_world \
  --runtime nodejs8
gcloud functions describe helloWorld
DATA=$(printf 'Hello World!'|base64) && gcloud functions call helloWorld --data '{"data":"'$DATA'"}'
gcloud functions logs read helloWorld

completed "Task 2"

completed "Lab"

remove_files 
