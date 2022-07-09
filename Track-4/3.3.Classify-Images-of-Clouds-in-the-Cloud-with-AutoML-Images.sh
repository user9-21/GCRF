curl -o default.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/default.sh
source default.sh

gcloud services enable automl.googleapis.com
gsutil mb -p $GOOGLE_CLOUD_PROJECT \
    -c standard    \
    -l us-central1 \
    gs://$GOOGLE_CLOUD_PROJECT-vcm/
	
completed "Task 1"	
	
export BUCKET=$GOOGLE_CLOUD_PROJECT-vcm
gsutil -m cp -r gs://spls/gsp223/images/* gs://${BUCKET}
gsutil cp gs://spls/gsp223/data.csv .
sed -i -e "s/placeholder/${BUCKET}/g" ./data.csv
gsutil cp ./data.csv gs://${BUCKET}


warning "Visit -${CYAN} https://console.cloud.google.com/vertex-ai/datasets/create?project=$PROJECT_ID

${RESET}${YELLOW}
	- Type clouds for the Dataset name.
	- Select Single-Label Classification.
	- Click CREATE DATASET.
	- Choose Select a CSV file on Cloud Storage and add the file name to the URL for the file you just uploaded - gs://your-bucket-name/data.csv"




warning "It will take 2 - 5 minutes for your images to import. Once the import has completed, you'll be brought to a page with all the images in your dataset."

completed "Task 2"

completed "Lab"

remove_files