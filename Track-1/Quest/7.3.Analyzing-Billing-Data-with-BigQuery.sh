curl -o default.sh https://raw.githubusercontent.com/user9-21/GoogleCloudReady-Facilitator-program/main/files/default.sh
source default.sh

bq query --use_legacy_sql=false \
'SELECT * FROM `billing_dataset.enterprise_billing` WHERE Cost > 0'

bq query --use_legacy_sql=false \
'SELECT
 project.name as Project_Name,
 service.description as Service,
 location.country as Country,
 cost as Cost
FROM `billing_dataset.enterprise_billing`;'

completed "Task 1"
bq query --use_legacy_sql=false \
'SELECT CONCAT(service.description, " : ",sku.description) as Line_Item FROM `billing_dataset.enterprise_billing` GROUP BY 1'

completed "Task 2"
bq query --use_legacy_sql=false \
'SELECT CONCAT(service.description, " : ",sku.description) as Line_Item, Count(*) as NUM FROM `billing_dataset.enterprise_billing` GROUP BY CONCAT(service.description, " : ",sku.description)'


completed "Task 3"
bq query --use_legacy_sql=false \
'SELECT project.id, count(*) as count from `billing_dataset.enterprise_billing` GROUP BY project.id'

completed "Task 4"
bq query --use_legacy_sql=false \
'SELECT ROUND(SUM(cost),2) as Cost, project.name from `billing_dataset.enterprise_billing` GROUP BY project.name'

completed "Task 5"
completed "Lab"

warning "if error in points , Run particular query manually from lab instruction on BIGQUERY console:${CYAN}

	https://console.cloud.google.com/bigquery?project=$PROJECT_ID"
remove_files 