curl -o default.sh https://raw.githubusercontent.com/user9-21/GoogleCloudReady-Facilitator-program/main/files/default.sh
source default.sh

bq show bigquery-public-data:samples.shakespeare
bq query --use_legacy_sql=false \
'SELECT
   word,
   SUM(word_count) AS count
 FROM
   `bigquery-public-data`.samples.shakespeare
 WHERE
   word LIKE "%raisin%"
 GROUP BY
   word'
completed "Task 1"


bq query --use_legacy_sql=false \
'SELECT
   word
 FROM
   `bigquery-public-data`.samples.shakespeare
 WHERE
   word = "huzzah"'
completed "Task 2"

bq ls bigquery-public-data:
bq mk babynames
completed "Task 3"

curl -LO http://www.ssa.gov/OACT/babynames/names.zip
ls
unzip names.zip
bq load babynames.names2010 yob2010.txt name:string,gender:string,count:integer
completed "Task 4"

bq ls babynames
bq show babynames.names2010
bq query "SELECT name,count FROM babynames.names2010 WHERE gender = 'F' ORDER BY count DESC LIMIT 5"
bq query "SELECT name,count FROM babynames.names2010 WHERE gender = 'M' ORDER BY count ASC LIMIT 5"
completed "Task 5"

bq rm -r -f babynames
completed "Task 6"

completed "Lab"

remove_files 