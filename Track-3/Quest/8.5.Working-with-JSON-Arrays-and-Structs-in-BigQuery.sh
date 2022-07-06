curl -o default.sh https://raw.githubusercontent.com/user9-21/GoogleCloudReady-Facilitator-program/main/files/default.sh
source default.sh


bq mk fruit_store

bq query --use_legacy_sql=false \
'#standardSQL
SELECT
["raspberry", "blackberry", "strawberry", "cherry"] AS fruit_array'

bq query --use_legacy_sql=false \
'#standardSQL
SELECT
["raspberry", "blackberry", "strawberry", "cherry", 1234567] AS fruit_array'

bq query --use_legacy_sql=false \
'#standardSQL
SELECT person, fruit_array, total_cost FROM `data-to-insights.advanced.fruit_store`'

bq mkdef --autodetect --source_format=NEWLINE_DELIMITED_JSON \
  gs://cloud-training/gsp416/shopping_cart.json > fruit_details_def

bq mk --table \
  --external_table_definition=fruit_details_def \
  fruit_store.fruit_details
completed "Task 1"


bq query --use_legacy_sql=false \
'SELECT
  fullVisitorId,
  date,
  v2ProductName,
  pageTitle
  FROM `data-to-insights.ecommerce.all_sessions`
WHERE visitId = 1501570398
ORDER BY date'

bq query --use_legacy_sql=false \
'SELECT
  fullVisitorId,
  date,
  ARRAY_AGG(v2ProductName) AS products_viewed,
  ARRAY_AGG(pageTitle) AS pages_viewed
  FROM `data-to-insights.ecommerce.all_sessions`
WHERE visitId = 1501570398
GROUP BY fullVisitorId, date
ORDER BY date'

bq query --use_legacy_sql=false \
'SELECT
  fullVisitorId,
  date,
  ARRAY_AGG(v2ProductName) AS products_viewed,
  ARRAY_LENGTH(ARRAY_AGG(v2ProductName)) AS num_products_viewed,
  ARRAY_AGG(pageTitle) AS pages_viewed,
  ARRAY_LENGTH(ARRAY_AGG(pageTitle)) AS num_pages_viewed
  FROM `data-to-insights.ecommerce.all_sessions`
WHERE visitId = 1501570398
GROUP BY fullVisitorId, date
ORDER BY date'

bq query --use_legacy_sql=false \
'SELECT
  fullVisitorId,
  date,
  ARRAY_AGG(DISTINCT v2ProductName) AS products_viewed,
  ARRAY_LENGTH(ARRAY_AGG(DISTINCT v2ProductName)) AS distinct_products_viewed,
  ARRAY_AGG(DISTINCT pageTitle) AS pages_viewed,
  ARRAY_LENGTH(ARRAY_AGG(DISTINCT pageTitle)) AS distinct_pages_viewed
  FROM `data-to-insights.ecommerce.all_sessions`
WHERE visitId = 1501570398
GROUP BY fullVisitorId, date
ORDER BY date'

completed "Task 2"


bq query --use_legacy_sql=false \
'SELECT
  *
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`
WHERE visitId = 1501570398'

bq query --use_legacy_sql=false \
'SELECT
  visitId,
  hits.page.pageTitle
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`
WHERE visitId = 1501570398'

bq query --use_legacy_sql=false \
'SELECT DISTINCT
  visitId,
  h.page.pageTitle
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`,
UNNEST(hits) AS h
WHERE visitId = 1501570398
LIMIT 10'

completed "Task 3"







bq query --use_legacy_sql=false \
'SELECT
  visitId,
  totals.*,
  device.*
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`
WHERE visitId = 1501570398
LIMIT 10'

bq query --use_legacy_sql=false \
'#standardSQL
SELECT STRUCT("Rudisha" as name, 23.4 as split) as runner'

bq query --use_legacy_sql=false \
'#standardSQL
SELECT STRUCT("Rudisha" as name, [23.4, 26.3, 26.4, 26.1] as splits) AS runner'

bq mk racing
cat > schema_race_results.json <<EOF
[
    {
        "name": "race",
        "type": "STRING",
        "mode": "NULLABLE"
    },
    {
        "name": "participants",
        "type": "RECORD",
        "mode": "REPEATED",
        "fields": [
            {
                "name": "name",
                "type": "STRING",
                "mode": "NULLABLE"
            },
            {
                "name": "splits",
                "type": "FLOAT",
                "mode": "REPEATED"
            }
        ]
    }
]
EOF

bq mkdef --source_format=NEWLINE_DELIMITED_JSON \
  gs://data-insights-course/labs/optimizing-for-performance/race_results.json > race_results_def

bq mk --table \
  --external_table_definition=race_results_def \
  racing.race_results \
  schema_race_results.json

completed "Task 4"






bq query --use_legacy_sql=false \
'#standardSQL
SELECT * FROM racing.race_results'

bq query --use_legacy_sql=false \
'#standardSQL
SELECT race, participants.name
FROM racing.race_results'


bq query --use_legacy_sql=false \
'#standardSQL
SELECT race, participants.name
FROM racing.race_results
CROSS JOIN
participants  # this is the STRUCT (it is like a table within a table)'

bq query --use_legacy_sql=false \
'#standardSQL
SELECT race, participants.name
FROM racing.race_results
CROSS JOIN
race_results.participants # full STRUCT name'

bq query --use_legacy_sql=false \
'#standardSQL
SELECT race, participants.name
FROM racing.race_results AS r, r.participants'

bq query --use_legacy_sql=false \
'#standardSQL
SELECT COUNT(participants.name) AS racer_count
FROM racing.race_results'

bq query --use_legacy_sql=false \
'#standardSQL
SELECT COUNT(p.name) AS racer_count
FROM racing.race_results AS r, UNNEST(r.participants) AS p'

completed "Task 5"






bq query --use_legacy_sql=false \
'#standardSQL
SELECT
  p.name,
  SUM(split_times) as total_race_time
FROM racing.race_results AS r
, UNNEST(r.participants) AS p
, UNNEST(p.splits) AS split_times
WHERE p.name LIKE "R%"
GROUP BY p.name
ORDER BY total_race_time ASC'

completed "Task 6"



bq query --use_legacy_sql=false \
'#standardSQL
SELECT
  p.name,
  split_time
FROM racing.race_results AS r
, UNNEST(r.participants) AS p
, UNNEST(p.splits) AS split_time
WHERE split_time = 23.2'

completed "Task 7"

completed "Lab"

remove_files 

