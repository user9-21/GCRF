curl -o default.sh https://raw.githubusercontent.com/user9-21/LearnToEarn-June-2022/main/files/default.sh
source default.sh

gsutil -m cp -r gs://spls/gsp233/* .
cd tf-gke-k8s-service-lb

terraform init

warning "When asked to  Enter a value, type yes"
sleep 10
terraform apply

completed "Task 1"

completed "Lab"

remove_files