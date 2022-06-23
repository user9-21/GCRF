curl -o default.sh https://raw.githubusercontent.com/user9-21/GoogleCloudReady-Facilitator-program/main/files/default.sh
source default.sh

gcloud services enable datacatalog.googleapis.com
completed "Task 1"

gsutil cp gs://spls/gsp814/cloudsql-sqlserver-tooling.zip .
unzip cloudsql-sqlserver-tooling.zip
sleep 10
cd cloudsql-sqlserver-tooling
bash init-db.sh
bash init-db.sh
completed "Task 2"

gcloud iam service-accounts create sqlserver2dc-credentials \
--display-name  "Service Account for SQLServer to Data Catalog connector" \
--project $PROJECT_ID
gcloud iam service-accounts keys create "sqlserver2dc-credentials.json" \
--iam-account "sqlserver2dc-credentials@$PROJECT_ID.iam.gserviceaccount.com"
gcloud projects add-iam-policy-binding $PROJECT_ID \
--member "serviceAccount:sqlserver2dc-credentials@$PROJECT_ID.iam.gserviceaccount.com" \
--quiet \
--project $PROJECT_ID \
--role "roles/datacatalog.admin"
completed "Task 3"

cd infrastructure/terraform/
public_ip_address=$(terraform output -raw public_ip_address)
username=$(terraform output -raw username)
password=$(terraform output -raw password)
database=$(terraform output -raw db_name)
cd ~/cloudsql-sqlserver-tooling
docker run --rm --tty -v \
"$PWD":/data mesmacosta/sqlserver2datacatalog:stable \
--datacatalog-project-id=$PROJECT_ID \
--datacatalog-location-id=us-central1 \
--sqlserver-host=$public_ip_address \
--sqlserver-user=$username \
--sqlserver-pass=$password \
--sqlserver-database=$database
completed "Task 4"

./cleanup-db.sh
docker run --rm --tty -v \
"$PWD":/data mesmacosta/sqlserver-datacatalog-cleaner:stable \
--datacatalog-project-ids=$PROJECT_ID \
--rdbms-type=sqlserver \
--table-container-type=schema
./delete-db.sh
cd
gsutil cp gs://spls/gsp814/cloudsql-postgresql-tooling.zip .
unzip cloudsql-postgresql-tooling.zip
sleep 10
cd cloudsql-postgresql-tooling
bash init-db.sh
bash init-db.sh
completed "Task 5"

gcloud iam service-accounts create postgresql2dc-credentials \
--display-name  "Service Account for PostgreSQL to Data Catalog connector" \
--project $PROJECT_ID
gcloud iam service-accounts keys create "postgresql2dc-credentials.json" \
--iam-account "postgresql2dc-credentials@$PROJECT_ID.iam.gserviceaccount.com"
gcloud projects add-iam-policy-binding $PROJECT_ID \
--member "serviceAccount:postgresql2dc-credentials@$PROJECT_ID.iam.gserviceaccount.com" \
--quiet \
--project $PROJECT_ID \
--role "roles/datacatalog.admin"
completed "Task 6"

cd infrastructure/terraform/
public_ip_address=$(terraform output -raw public_ip_address)
username=$(terraform output -raw username)
password=$(terraform output -raw password)
database=$(terraform output -raw db_name)
cd ~/cloudsql-postgresql-tooling
docker run --rm --tty -v \
"$PWD":/data mesmacosta/postgresql2datacatalog:stable \
--datacatalog-project-id=$PROJECT_ID \
--datacatalog-location-id=us-central1 \
--postgresql-host=$public_ip_address \
--postgresql-user=$username \
--postgresql-pass=$password \
--postgresql-database=$database
completed "Task 7"

./cleanup-db.sh
docker run --rm --tty -v \
"$PWD":/data mesmacosta/postgresql-datacatalog-cleaner:stable \
--datacatalog-project-ids=$PROJECT_ID \
--rdbms-type=postgresql \
--table-container-type=schema
./delete-db.sh
cd
gsutil cp gs://spls/gsp814/cloudsql-mysql-tooling.zip .
unzip cloudsql-mysql-tooling.zip
sleep 10
cd cloudsql-mysql-tooling
bash init-db.sh
bash init-db.sh
completed "Task 8"

gcloud iam service-accounts create mysql2dc-credentials \
--display-name  "Service Account for MySQL to Data Catalog connector" \
--project $PROJECT_ID
gcloud iam service-accounts keys create "mysql2dc-credentials.json" \
--iam-account "mysql2dc-credentials@$PROJECT_ID.iam.gserviceaccount.com"
gcloud projects add-iam-policy-binding $PROJECT_ID \
--member "serviceAccount:mysql2dc-credentials@$PROJECT_ID.iam.gserviceaccount.com" \
--quiet \
--project $PROJECT_ID \
--role "roles/datacatalog.admin"
completed "Task 9"

cd infrastructure/terraform/
public_ip_address=$(terraform output -raw public_ip_address)
username=$(terraform output -raw username)
password=$(terraform output -raw password)
database=$(terraform output -raw db_name)
cd ~/cloudsql-mysql-tooling
docker run --rm --tty -v \
"$PWD":/data mesmacosta/mysql2datacatalog:stable \
--datacatalog-project-id=$PROJECT_ID \
--datacatalog-location-id=us-central1 \
--mysql-host=$public_ip_address \
--mysql-user=$username \
--mysql-pass=$password \
--mysql-database=$database
completed "Task 10"

./cleanup-db.sh
docker run --rm --tty -v \
"$PWD":/data mesmacosta/mysql-datacatalog-cleaner:stable \
--datacatalog-project-ids=$PROJECT_ID \
--rdbms-type=mysql \
--table-container-type=database
./delete-db.sh

completed "Lab"

remove_files