  --Task 1
SELECT
  *
FROM
  `ctg-storage.bigquery_billing_export.gcp_billing_export_v1_01150A_B8F62B_47D999`; 
  

--Task 2
SELECT
  service.description
FROM
  `ctg-storage.bigquery_billing_export.gcp_billing_export_v1_01150A_B8F62B_47D999`
GROUP BY
  service.description; 
  

--Task 3
SELECT
  service.description,
  COUNT(*) AS num
FROM
  `ctg-storage.bigquery_billing_export.gcp_billing_export_v1_01150A_B8F62B_47D999`
GROUP BY
  service.description; 


--Task 4
SELECT
  service.description,
  COUNT(*) AS num
FROM
  `ctg-storage.bigquery_billing_export.gcp_billing_export_v1_01150A_B8F62B_47D999`
GROUP BY
  service.description; 
  

--Explore above query WITH DATA Studio


SELECT
  location.region
FROM
  `ctg-storage.bigquery_billing_export.gcp_billing_export_v1_01150A_B8F62B_47D999`
GROUP BY
  location.region; 
  
  
--Task 5
SELECT
  location.region,
  COUNT(*) AS num
FROM
  `ctg-storage.bigquery_billing_export.gcp_billing_export_v1_01150A_B8F62B_47D999`
GROUP BY
  location.region;

