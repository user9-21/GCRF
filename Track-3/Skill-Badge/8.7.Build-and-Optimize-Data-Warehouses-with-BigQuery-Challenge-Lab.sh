curl -o default.sh https://raw.githubusercontent.com/user9-21/GoogleCloudReady-Facilitator-program/main/files/default.sh
source default.sh

echo " "
read -p "${BOLD}${YELLOW}Enter Dataset name : ${RESET}" DATASET_NAME
read -p "${BOLD}${YELLOW}Enter Table name : ${RESET}" TABLE_NAME
echo "${BOLD} "
echo "${YELLOW}Your Dataset name :${CYAN} $DATASET_NAME  "
echo "${YELLOW}Your Table name :${CYAN} $TABLE_NAME  "
echo " "

read -p "${BOLD}${YELLOW}Verify all details are correct? [ y/n ] : ${RESET}" VERIFY_DETAILS

while [ $VERIFY_DETAILS != 'y' ];
do echo " " && read -p "${BOLD}${YELLOW}Enter Dataset name : ${RESET}" DATASET_NAME && read -p "${BOLD}${YELLOW}Enter Table name : ${RESET}" TABLE_NAME && echo "${BOLD} " && echo "${YELLOW}Your Dataset name :${CYAN} $DATASET_NAME" && echo "${YELLOW}Your Table name :${CYAN} $TABLE_NAME" && echo " " && read -p "${BOLD}${YELLOW}Verify all details are correct? [ y/n ] : ${RESET}" VERIFY_DETAILS;
done

bq mk $DATASET_NAME
sed -i "s/<DATASET NAME>/$DATASET_NAME/g" script.sh
sed -i "s/<TABLE NAME>/$TABLE_NAME/g" script.sh

cp script.sh bq.sh
sed -i '1d;4,27d' bq.sh

chmod +x bq.sh
./bq.sh


bq query --use_legacy_sql=false \
'
CREATE OR REPLACE TABLE <DATASET NAME>.<TABLE NAME>
PARTITION BY date
OPTIONS(
partition_expiration_days=360,
description="oxford_policy_tracker table in the COVID 19 Government Response public dataset with  an expiry time set to 90 days."
) AS
SELECT
   *
FROM
   `bigquery-public-data.covid19_govt_response.oxford_policy_tracker`
WHERE
   alpha_3_code NOT IN ("GBR", "BRA", "CAN","USA");'
completed "Task 1"


bq query --use_legacy_sql=false \
'ALTER TABLE <DATASET NAME>.<TABLE NAME>
ADD COLUMN population INT64,
ADD COLUMN country_area FLOAT64,
ADD COLUMN mobility STRUCT<
   avg_retail      FLOAT64,
   avg_grocery     FLOAT64,
   avg_parks       FLOAT64,
   avg_transit     FLOAT64,
   avg_workplace   FLOAT64,
   avg_residential FLOAT64
   >
'
completed "Task 2"


bq query --use_legacy_sql=false \
'CREATE OR REPLACE TABLE <DATASET NAME>.pop_data_2019 AS
SELECT
  country_territory_code,
  pop_data_2019
FROM 
  `bigquery-public-data.covid19_ecdc.covid_19_geographic_distribution_worldwide`
GROUP BY
  country_territory_code,
  pop_data_2019
ORDER BY
  country_territory_code;'

bq query --use_legacy_sql=false \
'UPDATE
   `<DATASET NAME>.<TABLE NAME>` t0
SET
   population = t1.pop_data_2019
FROM
   `<DATASET NAME>.pop_data_2019` t1
WHERE
   CONCAT(t0.alpha_3_code) = CONCAT(t1.country_territory_code);'
completed "Task 3"

bq query --use_legacy_sql=false \
'UPDATE
   `<DATASET NAME>.<TABLE NAME>` t0
SET
   t0.country_area = t1.country_area
FROM
   `bigquery-public-data.census_bureau_international.country_names_area` t1
WHERE
   t0.country_name = t1.country_name;'
completed "Task 4"

bq query --use_legacy_sql=false \
'UPDATE
   `<DATASET NAME>.<TABLE NAME>` t0
SET
   t0.mobility.avg_retail      = t1.avg_retail,
   t0.mobility.avg_grocery     = t1.avg_grocery,
   t0.mobility.avg_parks       = t1.avg_parks,
   t0.mobility.avg_transit     = t1.avg_transit,
   t0.mobility.avg_workplace   = t1.avg_workplace,
   t0.mobility.avg_residential = t1.avg_residential
FROM
   ( SELECT country_region, date,
      AVG(retail_and_recreation_percent_change_from_baseline) as avg_retail,
      AVG(grocery_and_pharmacy_percent_change_from_baseline)  as avg_grocery,
      AVG(parks_percent_change_from_baseline) as avg_parks,
      AVG(transit_stations_percent_change_from_baseline) as avg_transit,
      AVG(workplaces_percent_change_from_baseline) as avg_workplace,
      AVG(residential_percent_change_from_baseline)  as avg_residential
      FROM `bigquery-public-data.covid19_google_mobility.mobility_report`
      GROUP BY country_region, date
   ) AS t1
WHERE
   CONCAT(t0.country_name, t0.date) = CONCAT(t1.country_region, t1.date)'
completed "Task 5"


bq query --use_legacy_sql=false \
'SELECT country_name, population
FROM `<DATASET NAME>.<TABLE NAME>`
WHERE population is NULL
'

bq query --use_legacy_sql=false \
'SELECT country_name, country_area
FROM `<DATASET NAME>.<TABLE NAME>`
WHERE country_area IS NULL
'

bq query --use_legacy_sql=false \
'SELECT DISTINCT country_name
FROM `<DATASET NAME>.<TABLE NAME>`
WHERE population is NULL
UNION ALL
SELECT DISTINCT country_name
FROM `<DATASET NAME>.<TABLE NAME>`
WHERE country_area IS NULL
ORDER BY country_name ASC;'
completed "Task 6"

completed "Lab"

remove_files