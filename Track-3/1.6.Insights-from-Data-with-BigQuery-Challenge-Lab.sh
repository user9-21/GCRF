curl -o default.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/default.sh
source default.sh

warning "${CYAN}https://console.cloud.google.com/bigquery?project=$PROJECT_ID"
#read -p "${BOLD}${YELLOW}Date[YYYY-MM-DD] (${BLUE}in Task 2${YELLOW}) : ${RESET}" DATE
warning "${RED}You will find below details in between the instructions

	- In Query 1, Date should be entered in ${CYAN}[YYYY-MM-DD]${RED} form like if given Date is ${CYAN}May 25, 2020${RED}, it should be entered as ${CYAN}2020-05-25${RED}.
	- In Query 4, Month should be entered in ${CYAN}[MM]${RED} format like if given Month is ${CYAN}April${RED}, it should be entered as ${CYAN}04"
	
read -p "${BOLD}${YELLOW}Date ${RED}[YYYY-MM-DD]${YELLOW} ${BLUE}(in Query 1,2,3 and 9)${YELLOW} : ${RESET}" DATE
read -p "${BOLD}${YELLOW}Deathcount ${BLUE}(in Query 2)${YELLOW} : ${RESET}" DEATHCOUNT21
read -p "${BOLD}${YELLOW}Deathcount ${BLUE}(in Query 3)${YELLOW} : ${RESET}" DEATHCOUNT31
read -p "${BOLD}${YELLOW}Month ${RED}[MM]${YELLOW} ${BLUE}(in Query 4)${YELLOW} : ${RESET}" MONTH4
read -p "${BOLD}${YELLOW}Deathcount ${BLUE}(in Query 5)${YELLOW} : ${RESET}" DEATHCOUNT51
read -p "${BOLD}${YELLOW}Start Date ${RED}[YYYY-MM-DD]${YELLOW} ${BLUE}(in Query 6)${YELLOW} : ${RESET}" DATE61
read -p "${BOLD}${YELLOW}End Date ${RED}[YYYY-MM-DD]${YELLOW} ${BLUE}(in Query 6)${YELLOW} : ${RESET}" DATE62
read -p "${BOLD}${YELLOW}Percent ${BLUE}(in Query 7)${YELLOW} : ${RESET}" PERCENT71
read -p "${BOLD}${YELLOW}Limit ${BLUE}(in Query 8)${YELLOW} : ${RESET}" LIMIT81
read -p "${BOLD}${YELLOW}Start Date ${RED}[YYYY-MM-DD]${YELLOW} ${BLUE}(in Query 10)${YELLOW} : ${RESET}" DATE101
read -p "${BOLD}${YELLOW}End Date ${RED}[YYYY-MM-DD]${YELLOW} ${BLUE}(in Query 10)${YELLOW} : ${RESET}" DATE102
echo "${BOLD}"
echo "${YELLOW}Date ${RED}[YYYY-MM-DD]${YELLOW} ${BLUE}(in Query 1,2,3 and 9)${YELLOW} :${CYAN} $DATE"
echo "${YELLOW}Deathcount ${BLUE}(in Query 2)${YELLOW} :${CYAN} $DEATHCOUNT21"
echo "${YELLOW}Deathcount ${BLUE}(in Query 3)${YELLOW} :${CYAN} $DEATHCOUNT31"
echo "${YELLOW}Month ${RED}[MM]${YELLOW} ${BLUE}(in Query 4)${YELLOW} :${CYAN} $MONTH4"
echo "${YELLOW}Deathcount ${BLUE}(in Query 5)${YELLOW} :${CYAN} $DEATHCOUNT51"
echo "${YELLOW}Start Date ${RED}[YYYY-MM-DD]${YELLOW} ${BLUE}(in Query 6)${YELLOW} :${CYAN} $DATE61"
echo "${YELLOW}End Date ${RED}[YYYY-MM-DD]${YELLOW} ${BLUE}(in Query 6)${YELLOW} :${CYAN} $DATE62"
echo "${YELLOW}Percent ${BLUE}(in Query 7)${YELLOW} :${CYAN} $PERCENT71"
echo "${YELLOW}Limit ${BLUE}(in Query 8)${YELLOW} :${CYAN} $LIMIT81"
echo "${YELLOW}Start Date ${RED}[YYYY-MM-DD]${YELLOW} ${BLUE}(in Query 10)${YELLOW} :${CYAN} $DATE101"
echo "${YELLOW}End Date ${RED}[YYYY-MM-DD]${YELLOW} ${BLUE}(in Query 10)${YELLOW} :${CYAN} $DATE102"

read -p "${BOLD}${YELLOW}Confirm all inside-details are correct? [ y/n ] : ${RESET}" CONFIRM_DETAILS

while [ $CONFIRM_DETAILS != 'y' ];
do echo " " && 
read -p "${BOLD}${YELLOW}Date ${RED}[YYYY-MM-DD]${YELLOW} ${BLUE}(in Query 1,2,3 and 9)${YELLOW} : ${RESET}" DATE && 
read -p "${BOLD}${YELLOW}Deathcount ${BLUE}(in Query 2)${YELLOW} : ${RESET}" DEATHCOUNT21 && 
read -p "${BOLD}${YELLOW}Deathcount ${BLUE}(in Query 3)${YELLOW} : ${RESET}" DEATHCOUNT31 && 
read -p "${BOLD}${YELLOW}Month ${RED}[MM]${YELLOW} ${BLUE}(in Query 4)${YELLOW} : ${RESET}" MONTH4 && 
read -p "${BOLD}${YELLOW}Deathcount ${BLUE}(in Query 5)${YELLOW} : ${RESET}" DEATHCOUNT51 && 
read -p "${BOLD}${YELLOW}Start Date ${RED}[YYYY-MM-DD]${YELLOW} ${BLUE}(in Query 6)${YELLOW} : ${RESET}" DATE61 && 
read -p "${BOLD}${YELLOW}End Date ${RED}[YYYY-MM-DD]${YELLOW} ${BLUE}(in Query 6)${YELLOW} : ${RESET}" DATE62 && 
read -p "${BOLD}${YELLOW}Percent ${BLUE}(in Query 7)${YELLOW} : ${RESET}" PERCENT71 && 
read -p "${BOLD}${YELLOW}Limit ${BLUE}(in Query 8)${YELLOW} : ${RESET}" LIMIT81 && 
read -p "${BOLD}${YELLOW}Start Date ${RED}[YYYY-MM-DD]${YELLOW} ${BLUE}(in Query 10)${YELLOW} : ${RESET}" DATE101 && 
read -p "${BOLD}${YELLOW}End Date ${RED}[YYYY-MM-DD]${YELLOW} ${BLUE}(in Query 10)${YELLOW} : ${RESET}" DATE102 && 
echo "${BOLD}" && 
echo "${YELLOW}Date ${RED}[YYYY-MM-DD]${YELLOW} ${BLUE}(in Query 1,2,3 and 9)${YELLOW} :${CYAN} $DATE" && 
echo "${YELLOW}Deathcount ${BLUE}(in Query 2)${YELLOW} :${CYAN} $DEATHCOUNT21" && 
echo "${YELLOW}Deathcount ${BLUE}(in Query 3)${YELLOW} :${CYAN} $DEATHCOUNT31" && 
echo "${YELLOW}Month ${RED}[MM]${YELLOW} ${BLUE}(in Query 4)${YELLOW} :${CYAN} $MONTH4" && 
echo "${YELLOW}Deathcount ${BLUE}(in Query 5)${YELLOW} :${CYAN} $DEATHCOUNT51" && 
echo "${YELLOW}Start Date ${RED}[YYYY-MM-DD]${YELLOW} ${BLUE}(in Query 6)${YELLOW} :${CYAN} $DATE61" && 
echo "${YELLOW}End Date ${RED}[YYYY-MM-DD]${YELLOW} ${BLUE}(in Query 6)${YELLOW} :${CYAN} $DATE62" && 
echo "${YELLOW}Percent ${BLUE}(in Query 7)${YELLOW} :${CYAN} $PERCENT71" && 
echo "${YELLOW}Limit ${BLUE}(in Query 8)${YELLOW} :${CYAN} $LIMIT81" && 
echo "${YELLOW}Start Date ${RED}[YYYY-MM-DD]${YELLOW} ${BLUE}(in Query 10)${YELLOW} :${CYAN} $DATE101" && 
echo "${YELLOW}End Date ${RED}[YYYY-MM-DD]${YELLOW} ${BLUE}(in Query 10)${YELLOW} :${CYAN} $DATE102" && 
read -p "${BOLD}${YELLOW}Confirm all inside-details are correct? [ y/n ] : ${RESET}" CONFIRM_DETAILS
done

MONTH41=2020-$MONTH4-01
MONTH42=2020-$MONTH4-30
echo $MONTH41
echo $MONTH42

sed -i "s/<DATE>/$DATE/g" script.sh
sed -i "s/<DEATHCOUNT21>/$DEATHCOUNT21/g" script.sh
sed -i "s/<DEATHCOUNT31>/$DEATHCOUNT31/g" script.sh
sed -i "s/<MONTH41>/$MONTH41/g" script.sh
sed -i "s/<MONTH42>/$MONTH42/g" script.sh
sed -i "s/<DEATHCOUNT51>/$DEATHCOUNT51/g" script.sh
sed -i "s/<DATE61>/$DATE61/g" script.sh
sed -i "s/<DATE62>/$DATE62/g" script.sh
sed -i "s/<PERCENT71>/$PERCENT71/g" script.sh
sed -i "s/<LIMIT81>/$LIMIT81/g" script.sh
sed -i "s/<DATE101>/$DATE101/g" script.sh
sed -i "s/<DATE102>/$DATE102/g" script.sh

cp script.sh bq.sh
sed -i '1d;4,90d' bq.sh

chmod +x bq.sh
./bq.sh






bq query --use_legacy_sql=false \ 'SELECT sum(cumulative_confirmed) as total_cases_worldwide
FROM `bigquery-public-data.covid19_open_data.covid19_open_data`
WHERE date="<DATE>"
'
completed "Task 1"
bq query --use_legacy_sql=false \ 'with deaths_by_states as (

    SELECT subregion1_name as state, sum(cumulative_deceased) as death_count

    FROM `bigquery-public-data.covid19_open_data.covid19_open_data`

    where country_name="United States of America" and date="<DATE>" and subregion1_name is NOT NULL

    group by subregion1_name
)

select count(*) as count_of_states

from deaths_by_states

where death_count > <DEATHCOUNT21>
'
completed "Task 2"
bq query --use_legacy_sql=false \ 'SELECT * FROM (

    SELECT subregion1_name as state, sum(cumulative_confirmed) as total_confirmed_cases

    FROM `bigquery-public-data.covid19_open_data.covid19_open_data`

    WHERE country_code="US" AND date="<DATE>" AND subregion1_name is NOT NULL

    GROUP BY subregion1_name

    ORDER BY total_confirmed_cases DESC
)
WHERE total_confirmed_cases > <DEATHCOUNT31>
'
completed "Task 3"

bq query --use_legacy_sql=false \ 'SELECT sum(cumulative_confirmed) as total_confirmed_cases, sum(cumulative_deceased) as total_deaths, (sum(cumulative_deceased)/sum(cumulative_confirmed))*100 as case_fatality_ratio

FROM `bigquery-public-data.covid19_open_data.covid19_open_data`

where country_name="Italy" AND date BETWEEN "<MONTH41>"and "<MONTH42>"
'
completed "Task 4"
bq query --use_legacy_sql=false \ 'SELECT date

FROM `bigquery-public-data.covid19_open_data.covid19_open_data`

where country_name="Italy" and cumulative_deceased><DEATHCOUNT51>

order by date asc

limit 1
'
completed "Task 5"
bq query --use_legacy_sql=false \ 'WITH india_cases_by_date AS (

  SELECT

    date,

    SUM( cumulative_confirmed ) AS cases

  FROM

    `bigquery-public-data.covid19_open_data.covid19_open_data`

  WHERE

    country_name ="India"

    AND date between "<DATE61>" and "<DATE62>"

  GROUP BY

    date

  ORDER BY

    date ASC

 )

, india_previous_day_comparison AS

(SELECT

  date,

  cases,

  LAG(cases) OVER(ORDER BY date) AS previous_day,

  cases - LAG(cases) OVER(ORDER BY date) AS net_new_cases

FROM india_cases_by_date

)

select count(*)

from india_previous_day_comparison

where net_new_cases=0
'
completed "Task 6"
bq query --use_legacy_sql=false \ 'WITH us_cases_by_date AS (

  SELECT

    date,

    SUM(cumulative_confirmed) AS cases

  FROM

    `bigquery-public-data.covid19_open_data.covid19_open_data`

  WHERE

    country_name="United States of America"

    AND date between "2020-03-22" and "2020-04-20"

  GROUP BY

    date

  ORDER BY

    date ASC

 )



, us_previous_day_comparison AS

(SELECT

  date,

  cases,

  LAG(cases) OVER(ORDER BY date) AS previous_day,

  cases - LAG(cases) OVER(ORDER BY date) AS net_new_cases,

  (cases - LAG(cases) OVER(ORDER BY date))*100/LAG(cases) OVER(ORDER BY date) AS percentage_increase

FROM us_cases_by_date

)



select Date, cases as Confirmed_Cases_On_Day, previous_day as Confirmed_Cases_Previous_Day, percentage_increase as Percentage_Increase_In_Cases

from us_previous_day_comparison

where percentage_increase > <PERCENT71>
'
completed "Task 7"
bq query --use_legacy_sql=false \ 'WITH cases_by_country AS (

  SELECT

    country_name AS country,

    sum(cumulative_confirmed) AS cases,

    sum(cumulative_recovered) AS recovered_cases

  FROM

    bigquery-public-data.covid19_open_data.covid19_open_data

  WHERE

    date = "2020-05-10"

  GROUP BY

    country_name

 )



, recovered_rate AS

(SELECT

  country, cases, recovered_cases,

  (recovered_cases * 100)/cases AS recovery_rate

FROM cases_by_country

)



SELECT country, cases AS confirmed_cases, recovered_cases, recovery_rate

FROM recovered_rate

WHERE cases > 50000

ORDER BY recovery_rate desc

LIMIT <LIMIT81>
'
completed "Task 8"
bq query --use_legacy_sql=false \ 'WITH

  france_cases AS (

  SELECT

    date,

    SUM(cumulative_confirmed) AS total_cases

  FROM

    `bigquery-public-data.covid19_open_data.covid19_open_data`

  WHERE

    country_name="France"

    AND date IN ("2020-01-24",

      "<DATE>")

  GROUP BY

    date

  ORDER BY

    date)

, summary as (

SELECT

  total_cases AS first_day_cases,

  LEAD(total_cases) OVER(ORDER BY date) AS last_day_cases,

  DATE_DIFF(LEAD(date) OVER(ORDER BY date),date, day) AS days_diff

FROM

  france_cases

LIMIT 1

)

select first_day_cases, last_day_cases, days_diff, POW((last_day_cases/first_day_cases),(1/days_diff))-1 as cdgr

from summary
'
completed "Task 9"
bq query  --use_legacy_sql=false \ 'SELECT
  date, SUM(cumulative_confirmed) AS country_cases,
  SUM(cumulative_deceased) AS country_deaths
FROM
  `bigquery-public-data.covid19_open_data.covid19_open_data`
WHERE
  date BETWEEN "<DATE101>"
  AND "<DATE102>"
  AND country_name ="United States of America"
GROUP BY date'

cat > laststep.txt <<EOF
${YELLOW}
# Now Copy this query and perform in datastudio
# select custom query under bigquery, billing project as your project id in datastudio and generate the report.
# Navigate to ${CYAN}https://datastudio.google.com/
${YELLOW}
QUERY = SELECT date, SUM(cumulative_confirmed) AS country_cases, SUM(cumulative_deceased) AS country_deaths FROM "bigquery-public-data.covid19_open_data.covid19_open_data" WHERE date BETWEEN "<DATE101>"  AND "<DATE102>" AND country_name ="United States of America" GROUP BY date
EOF

sed -i 's/"bigquery-public-data.covid19_open_data.covid19_open_data"/`bigquery-public-data.covid19_open_data.covid19_open_data`/g' laststep.txt
cat laststep.txt

#completed "Task 5"

completed "Lab"

remove_files