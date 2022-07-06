curl -o default.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/default.sh
source default.sh


warning "Visit - ${CYAN}https://console.cloud.google.com/dataprep?project=$PROJECT_ID ${YELLOW} and accept Terms,grant required authorization to open Dataprep Dashboard."

bq mk ecommerce

bq query --use_legacy_sql=false \ '#standardSQL
 CREATE OR REPLACE TABLE ecommerce.all_sessions_raw_dataprep
 OPTIONS(
   description="Raw data from analyst team to ingest into Cloud Dataprep"
 ) AS
 SELECT * FROM `data-to-insights.ecommerce.all_sessions_raw`
 WHERE date = "20170801"; # limiting to one day of data 56k rows for this lab'

#bq query --use_legacy_sql=false \ ''
#gs://qwiklabs-gcp-00-7b7835d09eab/revenue_reporting.csv
curl -o revenue_reporting.csv https://raw.githubusercontent.com/user9-21/GCRF/main/Track-3/revenue_reporting.csv
ls
bq --location=us load --autodetect --source_format=CSV ecommerce.revenue_reporting revenue_reporting.csv

warning "Check if score is given or not, if not Proceed as instructed below"
sleep 10
warning "Visit -${CYAN} https://console.cloud.google.com/dataprep?project=$PROJECT_ID ${YELLOW} and accept Terms,grant required authorization to open Dataprep Dashboard.${RESET}${YELLOW}

	- Once Opened, Click Create a new flow in the left corner.
	- Rename the Untitled Flow and specify these details:
		Flow Name        =${CYAN}  Ecommerce Analytics Pipeline${YELLOW}
		Flow Description =${CYAN}  Revenue reporting table${YELLOW}
	- Click Ok.Click the Add Icon in the Dataset box.
	- In the Add Datasets to Flow dialog box, select Import Datasets.
	- In the left pane, click BigQuery. Click on ecommerce dataset.
	- Click on the Create dataset icon (+ sign) on the left of the${CYAN}  all_sessions_raw_dataprep ${YELLOW}table.
	- Click Import & Add to Flow in the bottom right corner
		
	- Now, Configure recipe as instructed on lab page.
		Wrangle version of Recipe are displayed below for your convenience: 
		you can copy each line(without line number) and paste in recipe box by clicking${CYAN} Add New Step ${YELLOW}to Create Recipe Quickly."
cat > Recipe.txt <<EOF
${BOLD}${MAGENTA}
1. settype col: productSKU lockDataType: true type: String
2. drop col: itemQuantity action: Drop
3. drop col: itemRevenue action: Drop
4. deduplicate
5. filter type: custom rowType: single row: ISMISSING([totalTransactionRevenue]) action: Delete
6. filter type: custom rowType: single row: type == 'PAGE' action: Keep
7. merge col: fullVisitorId,visitId with: '-' as: 'unique_session_id'
8. case condition: columnConditions col: eCommerceAction_type colCases: [0,'Unknown'], [1,'Click through of product lists'], [2,'Product detail views'], [3,'Add product(s) to cart'], [4,'Remove product(s) from cart'], [5,'Check out'], [6,'Completed purchase'], [7,'Refund of purchase'], [8,'Checkout options'] as: 'eCommerceAction_label'
9. derive type: single value: DIVIDE(totalTransactionRevenue, 1000000) as: 'totalTransactionRevenue1'
10. settype col: totalTransactionRevenue1 lockDataType: true type: Float
EOF
cat Recipe.txt
warning "${RESET}${YELLOW}After all Recipe are created, verify it from lab page and click Run.

	- In the Run Job page, select Dataflow for your Running Environment.
	- Under Publishing Actions, Click on Edit to the right of Create-CSV.
	- In the following page, select BigQuery from the left hand menu.
	- Select your ecommerce dataset.
	- Click Create a New Table from the panel on the right.
	- Name your table${CYAN} revenue_reporting.${YELLOW}
	- Select Drop the Table every run.
	- Click on Update.

Click RUN.
"
completed "Task 1"

completed "Lab"

remove_files