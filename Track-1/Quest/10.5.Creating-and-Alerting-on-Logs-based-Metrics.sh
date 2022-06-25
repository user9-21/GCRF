curl -o default.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/default.sh
source default.sh

gcloud config set compute/zone us-west1-b
export PROJECT_ID=$(gcloud info --format='value(config.project)')
gcloud container clusters create gmp-cluster --num-nodes=1 --zone us-west1-b
completed "Task 1"

warning "Do Manually, as per given instructions - ${CYAN}https://www.cloudskillsboost.google/focuses/619?parent=catalog#step4

https://console.cloud.google.com/logs/query?project=$PROJECT_ID"

read -p "${BOLD}${YELLOW}Created Log-based alert? [ y/n ] : ${RESET}" PROCEED1

while [ $PROCEED1 != 'y' ];
do echo "Do it Manually" && read -p "${BOLD}${YELLOW}Created Log-based alert? [ y/n ] : ${RESET}" PROCEED1;
done
gcloud compute instances stop instance1 --zone us-central1-a
completed "Task 2"

gcloud container clusters list
gcloud container clusters get-credentials gmp-cluster
kubectl create ns gmp-test
kubectl -n gmp-test apply -f https://storage.googleapis.com/spls/gsp091/gmp_flask_deployment.yaml
kubectl -n gmp-test apply -f https://storage.googleapis.com/spls/gsp091/gmp_flask_service.yaml
kubectl get services -n gmp-test
#kubectl get services -n gmp-test | grep hello | awk '{print $4}'

HELLO_EXTERNAL_IP=$(kubectl get services -n gmp-test | grep hello | awk '{print $4}')
echo $HELLO_EXTERNAL_IP

while [ $HELLO_EXTERNAL_IP = '<pending>' ];
do sleep 4 && HELLO_EXTERNAL_IP=$(kubectl get services -n gmp-test | grep hello | awk '{print $4}') && echo $HELLO_EXTERNAL_IP ;
done
completed "Task 3"

curl $(kubectl get services -n gmp-test -o jsonpath='{.items[*].status.loadBalancer.ingress[0].ip}')/metrics
warning "Create a log-based metric as per given instructions - ${CYAN}https://www.cloudskillsboost.google/focuses/619?parent=catalog#step6

		https://console.cloud.google.com/logs/metrics/edit?project=$PROJECT_ID	
"

read -p "${BOLD}${YELLOW}Created Log-based metric? [ y/n ] : ${RESET}" PROCEED2

while [ $PROCEED2 != 'y' ];
do echo "Do it Manually" && read -p "${BOLD}${YELLOW}Created Log-based metric? [ y/n ] : ${RESET}" PROCEED2;
done
completed "Task 4"

warning "Create a metrics-based alert as per given instructions - ${CYAN}https://www.cloudskillsboost.google/focuses/619?parent=catalog#step7

		https://console.cloud.google.com/monitoring/alerting/policies/create?agg=600s,ALIGN_DELTA,REDUCE_SUM&ct=t&f=metric.type%3D%22logging.googleapis.com%2Fuser%2Fhello-app-error%22&project=$PROJECT_ID&t=1&th=0	
"

read -p "${BOLD}${YELLOW}Created metrics-based alert? [ y/n ] : ${RESET}" PROCEED3

while [ $PROCEED3 != 'y' ];
do echo "Do it Manually" && read -p "${BOLD}${YELLOW}Created metrics-based alert? [ y/n ] : ${RESET}" PROCEED3;
done
completed "Task 5"

timeout 120 bash -c -- 'while true; do curl $(kubectl get services -n gmp-test -o jsonpath='{.items[*].status.loadBalancer.ingress[0].ip}')/error; sleep $((RANDOM % 4)) ; done'

completed "Task 6"

completed "Lab"

remove_files 