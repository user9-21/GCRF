curl -o default.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/default.sh
source default.sh

warning "${CYAN}https://console.cloud.google.com/bigquery?project=$PROJECT_ID"

read -p "${BOLD}${YELLOW}  Training Year : ${RESET}" TRAINING_YEAR
read -p "${BOLD}${YELLOW}Evaluation Year : ${RESET}" EVALUATION_YEAR
echo "${BOLD}"
echo "${YELLOW}  Training Year :${CYAN} $TRAINING_YEAR"
echo "${YELLOW}Evaluation Year :${CYAN} $EVALUATION_YEAR"

read -p "${BOLD}${YELLOW}Confirm all inside-details are correct? [ y/n ] : ${RESET}" CONFIRM_DETAILS

while [ $CONFIRM_DETAILS != 'y' ];
do echo " " && 	
read -p "${BOLD}${YELLOW}  Training Year : ${RESET}" TRAINING_YEAR && 
read -p "${BOLD}${YELLOW}Evaluation Year : ${RESET}" EVALUATION_YEAR && 
echo "${BOLD}" && 
echo "${YELLOW}  Training Year :${CYAN} $TRAINING_YEAR" && 
echo "${YELLOW}Evaluation Year :${CYAN} $EVALUATION_YEAR" && 
read -p "${BOLD}${YELLOW}Confirm all inside-details are correct? [ y/n ] : ${RESET}" CONFIRM_DETAILS
done

sed -i "s/<TRAINING_YEAR>/$TRAINING_YEAR/g" script.sh
sed -i "s/<EVALUATION_YEAR>/$EVALUATION_YEAR/g" script.sh

cp script.sh bq.sh
sed -i '1d;4,36d' bq.sh

chmod +x bq.sh
./bq.sh

#bq query --nouse_legacy_sql --format=sparse   "SELECT EVENT_DATA FROM dsongcp.flights_simevents WHERE EVENT_TYPE = 'wheelsoff' AND EVENT_TIME BETWEEN '2015-03-01' AND '2015-03-02'"  | grep FL_DATE > simevents_sample.json




bq mk austin
completed "Task 1"



bq query --use_legacy_sql=false \
'CREATE OR REPLACE MODEL austin.location_model
OPTIONS
  (model_type="linear_reg", labels=["duration_minutes"]) AS
SELECT
    start_station_name,
    EXTRACT(HOUR FROM start_time) AS start_hour,
    EXTRACT(DAYOFWEEK FROM start_time) AS day_of_week,
    duration_minutes,
    address as location
FROM
    `bigquery-public-data.austin_bikeshare.bikeshare_trips` AS trips
JOIN
    `bigquery-public-data.austin_bikeshare.bikeshare_stations` AS stations
ON
    trips.start_station_name = stations.name
WHERE
    EXTRACT(YEAR FROM start_time) = <TRAINING_YEAR>
    AND duration_minutes > 0'
bq query --use_legacy_sql=false \
'CREATE OR REPLACE MODEL austin.location_model
OPTIONS
  (model_type="linear_reg", labels=["duration_minutes"]) AS
SELECT
    start_station_name,
    EXTRACT(HOUR FROM start_time) AS start_hour,
    EXTRACT(DAYOFWEEK FROM start_time) AS day_of_week,
    duration_minutes,
    address as location
FROM
    `bigquery-public-data.austin_bikeshare.bikeshare_trips` AS trips
JOIN
    `bigquery-public-data.austin_bikeshare.bikeshare_stations` AS stations
ON
    trips.start_station_name = stations.name
WHERE
    EXTRACT(YEAR FROM start_time) = <TRAINING_YEAR>
    AND duration_minutes > 0'


completed "Task 2"

bq query --use_legacy_sql=false \
'CREATE OR REPLACE MODEL austin.subscriber_model
OPTIONS
  (model_type="linear_reg", labels=["duration_minutes"]) AS
SELECT
    start_station_name,
    EXTRACT(HOUR FROM start_time) AS start_hour,
    subscriber_type,
    duration_minutes
FROM `bigquery-public-data.austin_bikeshare.bikeshare_trips` AS trips
WHERE EXTRACT(YEAR FROM start_time) = <TRAINING_YEAR>
'
bq query --use_legacy_sql=false \
'CREATE OR REPLACE MODEL austin.subscriber_model
OPTIONS
  (model_type="linear_reg", labels=["duration_minutes"]) AS
SELECT
    start_station_name,
    EXTRACT(HOUR FROM start_time) AS start_hour,
    subscriber_type,
    duration_minutes
FROM `bigquery-public-data.austin_bikeshare.bikeshare_trips` AS trips
WHERE EXTRACT(YEAR FROM start_time) = <TRAINING_YEAR>
'
#bq query --use_legacy_sql=false ''

completed "Task 3"

bq query --use_legacy_sql=false \
'#Evaluation metrics for location_model
SELECT
  SQRT(mean_squared_error) AS rmse,
  mean_absolute_error
FROM
  ML.EVALUATE(MODEL austin.location_model, (
  SELECT
    start_station_name,
    EXTRACT(HOUR FROM start_time) AS start_hour,
    EXTRACT(DAYOFWEEK FROM start_time) AS day_of_week,
    duration_minutes,
    address as location
  FROM
    `bigquery-public-data.austin_bikeshare.bikeshare_trips` AS trips
  JOIN
   `bigquery-public-data.austin_bikeshare.bikeshare_stations` AS stations
  ON
    trips.start_station_name = stations.name
  WHERE EXTRACT(YEAR FROM start_time) = <EVALUATION_YEAR> )
)
'

bq query --use_legacy_sql=false \
'#Evaluation metrics for subscriber_model
SELECT
  SQRT(mean_squared_error) AS rmse,
  mean_absolute_error
FROM
  ML.EVALUATE(MODEL austin.subscriber_model, (
  SELECT
    start_station_name,
    EXTRACT(HOUR FROM start_time) AS start_hour,
    subscriber_type,
    duration_minutes
  FROM
    `bigquery-public-data.austin_bikeshare.bikeshare_trips` AS trips
  WHERE
    EXTRACT(YEAR FROM start_time) = <EVALUATION_YEAR>)
)'

completed "Task 4"

bq query --use_legacy_sql=false \
'SELECT
  start_station_name,
  COUNT(*) AS trips
FROM
  `bigquery-public-data.austin_bikeshare.bikeshare_trips`
WHERE
  EXTRACT(YEAR FROM start_time) = <EVALUATION_YEAR>
GROUP BY
  start_station_name
ORDER BY
  trips DESC'
bq query --use_legacy_sql=false \
'SELECT AVG(predicted_duration_minutes) AS average_predicted_trip_length
FROM ML.predict(MODEL austin.subscriber_model, (
SELECT
    start_station_name,
    EXTRACT(HOUR FROM start_time) AS start_hour,
    subscriber_type,
    duration_minutes
FROM
  `bigquery-public-data.austin_bikeshare.bikeshare_trips`
WHERE 
  EXTRACT(YEAR FROM start_time) = <EVALUATION_YEAR>
  AND subscriber_type = "Single Trip"
  AND start_station_name = "21st & Speedway @PCL"))
'
  
#bq query --nouse_legacy_sql --format=sparse "" 
#bq query --nouse_legacy_sql --format=sparse "" 


completed "Task 5"

completed "Lab"

remove_files