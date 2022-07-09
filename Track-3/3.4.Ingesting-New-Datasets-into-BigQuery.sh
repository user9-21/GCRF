curl -o default.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/default.sh
source default.sh

bq mk ecommerce
completed "Task 1"

wget https://storage.googleapis.com/data-insights-course/exports/products.csv
ls
bq --location=us load --autodetect --source_format=CSV ecommerce.products products.csv
completed "Task 2"

bq query --use_legacy_sql=false \ '#standardSQL
SELECT
  *
FROM
  ecommerce.products
ORDER BY
  stockLevel DESC
LIMIT  5'

bq --location=us load --autodetect --replace --source_format=CSV ecommerce.products gs://data-insights-course/exports/products.csv
completed "Task 3"

cat > schema.json <<EOF
[
  {
    "mode": "NULLABLE",
    "name": "SKU",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "name",
    "type": "STRING"
  },
  {
    "mode": "NULLABLE",
    "name": "orderedQuantity",
    "type": "INTEGER"
  },
  {
    "mode": "NULLABLE",
    "name": "stockLevel",
    "type": "INTEGER"
  },
  {
    "mode": "NULLABLE",
    "name": "restockingLeadTime",
    "type": "INTEGER"
  },
  {
    "mode": "NULLABLE",
    "name": "ratio",
    "type": "FLOAT"
  }
]
EOF

#bq mk --external_table_definition=schema.json@GOOGLE_SHEETS=https://docs.google.com/spreadsheets/d/1XqL4TS5c3NCEzijsAaccKEtFpX29uncxr7LAR5V0Rp4/edit ecommerce.products_comments

bq mk --external_table_definition=schema.json@GOOGLE_SHEETS=https://docs.google.com/spreadsheets/d/1a-Xx1jYM58_vAcaN92O7Oi-NnvtK7WXW1tJTOD4bxAU/edit?usp=sharing ecommerce.products_comments

warning "If error in Task 4 score, visit${CYAN} https://console.cloud.google.com/bigquery?project=$PROJECT_ID ${YELLOW} and Perform Task 4 manually from${CYAN} https://www.cloudskillsboost.google/focuses/3692?parent=catalog#step7 "

completed "Task 4"

completed "Lab"

remove_files