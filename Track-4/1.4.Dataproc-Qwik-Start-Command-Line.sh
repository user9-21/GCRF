curl -o default.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/default.sh
source default.sh

gcloud config set dataproc/region us-central1
gcloud dataproc clusters create example-cluster --worker-boot-disk-size 500 --quiet
completed "Task 1"

gcloud dataproc jobs submit spark --cluster example-cluster \
  --class org.apache.spark.examples.SparkPi \
  --jars file:///usr/lib/spark/examples/jars/spark-examples.jar -- 1000
completed "Task 2"

gcloud dataproc clusters update example-cluster --num-workers 4
gcloud dataproc clusters update example-cluster --num-workers 2
completed "Lab"

remove_files