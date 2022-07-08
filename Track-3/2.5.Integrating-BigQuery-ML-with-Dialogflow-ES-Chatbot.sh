curl -o default.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/default.sh
source default.sh


PROJECT_ID=`gcloud config get-value project`
BUCKET=${PROJECT_ID}-bucket
gsutil mb gs://$BUCKET
gsutil cp -r gs://spls/gsp431/* gs://$BUCKET
bq mk helpdesk
completed "Task 1"

bq --location=us load --autodetect --source_format=CSV helpdesk.issues gs://$BUCKET/ml/issues.csv

completed "Task 2"

bq query --use_legacy_sql=false \
'SELECT * FROM `helpdesk.issues` LIMIT 1000;'

bq query --use_legacy_sql=false \
'CREATE OR REPLACE MODEL `helpdesk.predict_eta_v0`
OPTIONS(model_type="linear_reg") AS
SELECT
 category,
 resolutiontime as label
FROM
  `helpdesk.issues`;'
completed "Task 3"

bq query --use_legacy_sql=false \
'WITH eval_table AS (
SELECT
 category,
 resolutiontime as label
FROM
  helpdesk.issues
)
SELECT
  *
FROM
  ML.EVALUATE(MODEL helpdesk.predict_eta_v0,
    TABLE eval_table);'
bq query --use_legacy_sql=false \
'CREATE OR REPLACE MODEL `helpdesk.predict_eta`
OPTIONS(model_type="linear_reg") AS
SELECT
 seniority,
 experience,
 category,
 type,
 resolutiontime as label
FROM
  `helpdesk.issues`;'
bq query --use_legacy_sql=false \
'WITH eval_table AS (
SELECT
 seniority,
 experience,
 category,
 type,
 resolutiontime as label
FROM
  helpdesk.issues
)
SELECT
  *
FROM
  ML.EVALUATE(MODEL helpdesk.predict_eta,
    TABLE eval_table);'

completed "Task 4"

warning "Now execute Dialogflow Task as given on lab page"

completed "Lab"

remove_files 