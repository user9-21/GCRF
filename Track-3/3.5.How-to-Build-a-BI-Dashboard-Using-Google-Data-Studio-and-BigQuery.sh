curl -o default.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/default.sh
source default.sh

bq mk Reports
completed "Task 1"

bq --location=us query --destination_table Reports.Trees \
 --use_legacy_sql=false 'SELECT
 TIMESTAMP_TRUNC(plant_date, MONTH) as plant_month,
  COUNT(tree_id) AS total_trees,
  species,
  care_taker,
  address,
  site_info
FROM
  `bigquery-public-data.san_francisco_trees.street_trees`
WHERE
  address IS NOT NULL
  AND plant_date >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 365 DAY)
  AND plant_date < TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), DAY)
GROUP BY
  plant_month,
  species,
  care_taker,
  address,
  site_info'

completed "Task 2"

bq query \
    --use_legacy_sql=false \
    --destination_table=Reports.Trees \
    --display_name='Update_trees_daily' \
    --schedule='every 24 hours' \
    --append_table=true \
	'SELECT
 TIMESTAMP_TRUNC(plant_date, MONTH) as plant_month,
  COUNT(tree_id) AS total_trees,
  species,
  care_taker,
  address,
  site_info
FROM
  `bigquery-public-data.san_francisco_trees.street_trees`
WHERE
  address IS NOT NULL
  AND plant_date >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 DAY)
  AND plant_date < TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), DAY)
GROUP BY
  plant_month,
  species,
  care_taker,
  address,
  site_info'

warning "Open${CYAN} https://datastudio.google.com/${YELLOW} and Create a Report.

	 Click on the BigQuery, then click Authorize.
	 Now you'll use the BigQuery connector to connect to the reports.trees table.
	 Click Add and then click Add to Report."

completed "Task 3"

completed "Lab"

remove_files