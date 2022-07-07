curl -o default.sh https://raw.githubusercontent.com/user9-21/LearnToEarn-June-2022/main/files/default.sh
source default.sh

echo " "
read -p "${BOLD}${YELLOW}   Table Name : ${RESET}" TABLE_NAME
read -p "${BOLD}${YELLOW}  Fare Amount : ${RESET}" FARE_AMOUNT
read -p "${BOLD}${YELLOW}       Number : ${RESET}" NUMBER
read -p "${BOLD}${YELLOW}Example Value : ${RESET}" EXAMPLE_VALUE
read -p "${BOLD}${YELLOW}   Model Name : ${RESET}" MODEL_NAME
echo "${BOLD}"
echo "${YELLOW}   Table Name : ${CYAN} $TABLE_NAME"
echo "${YELLOW}  Fare Amount : ${CYAN} $FARE_AMOUNT"
echo "${YELLOW}       Number : ${CYAN} $NUMBER"
echo "${YELLOW}Example Value : ${CYAN} $EXAMPLE_VALUE"
echo "${YELLOW}   Model Name : ${CYAN} $MODEL_NAME"
echo " "

read -p "${BOLD}${YELLOW}Verify all details are correct? [ y/n ] : ${RESET}" VERIFY_DETAILS

while [ $VERIFY_DETAILS != 'y' ];
do echo " " && 
read -p "${BOLD}${YELLOW}   Table Name : ${RESET}" TABLE_NAME && 
read -p "${BOLD}${YELLOW}  Fare Amount : ${RESET}" FARE_AMOUNT && 
read -p "${BOLD}${YELLOW}       Number : ${RESET}" NUMBER && 
read -p "${BOLD}${YELLOW}Example Value : ${RESET}" EXAMPLE_VALUE && 
read -p "${BOLD}${YELLOW}   Model Name : ${RESET}" MODEL_NAME && 
echo "${BOLD}" && 
echo "${YELLOW}   Table Name : ${CYAN} $TABLE_NAME" && 
echo "${YELLOW}  Fare Amount : ${CYAN} $FARE_AMOUNT" && 
echo "${YELLOW}       Number : ${CYAN} $NUMBER" && 
echo "${YELLOW}Example Value : ${CYAN} $EXAMPLE_VALUE" && 
echo "${YELLOW}   Model Name : ${CYAN} $MODEL_NAME" && 
echo " " && 
read -p "${BOLD}${YELLOW}Verify all details are correct? [ y/n ] : ${RESET}" VERIFY_DETAILS;
done

warning "${CYAN}https://console.cloud.google.com/bigquery?project=$PROJECT_ID"

sed -i "s/<TABLE_NAME>/$TABLE_NAME/g" script.sh
sed -i "s/<FARE_AMOUNT>/$FARE_AMOUNT/g" script.sh
sed -i "s/<NUMBER>/$NUMBER/g" script.sh
sed -i "s/<EXAMPLE_VALUE>/$EXAMPLE_VALUE/g" script.sh
sed -i "s/<MODEL_NAME>/$MODEL_NAME/g" script.sh


cp script.sh bq.sh
sed -i '1d;4,54d;112d' bq.sh

chmod +x bq.sh
./bq.sh

remove_files




bq query --use_legacy_sql=false \
'CREATE OR REPLACE TABLE
taxirides.<TABLE_NAME> AS
SELECT
(tolls_amount + fare_amount) AS <FARE_AMOUNT>,
pickup_datetime,
pickup_longitude AS pickuplon,
pickup_latitude AS pickuplat,
dropoff_longitude AS dropofflon,
dropoff_latitude AS dropofflat,
passenger_count AS passengers,
FROM
taxirides.historical_taxi_rides_raw
WHERE
RAND() < 0.001
AND trip_distance > <NUMBER>
AND fare_amount >= <EXAMPLE_VALUE>
AND pickup_longitude > -78
AND pickup_longitude < -70
AND dropoff_longitude > -78
AND dropoff_longitude < -70
AND pickup_latitude > 37
AND pickup_latitude < 45
AND dropoff_latitude > 37
AND dropoff_latitude < 45
AND passenger_count > <NUMBER>'

completed "Task 1"

bq query --use_legacy_sql=false \
'CREATE OR REPLACE MODEL taxirides.<MODEL_NAME>
TRANSFORM(
* EXCEPT(pickup_datetime)
 
, ST_Distance(ST_GeogPoint(pickuplon, pickuplat), ST_GeogPoint(dropofflon, dropofflat)) AS euclidean
, CAST(EXTRACT(DAYOFWEEK FROM pickup_datetime) AS STRING) AS dayofweek
, CAST(EXTRACT(HOUR FROM pickup_datetime) AS STRING) AS hourofday
)
OPTIONS(input_label_cols=["<FARE_AMOUNT>"], model_type="linear_reg")
AS
 
SELECT * FROM taxirides.<TABLE_NAME>'
completed "Task 2"


bq query --use_legacy_sql=false \
'CREATE OR REPLACE TABLE taxirides.2015_fare_amount_predictions
AS
SELECT * FROM ML.PREDICT(MODEL taxirides.<MODEL_NAME>,(
SELECT * FROM taxirides.report_prediction_data)
)'
completed "Task 3"

completed "Lab"

remove_files