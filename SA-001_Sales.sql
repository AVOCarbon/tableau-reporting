
-- VIEW: tableau."SA-001_Sales" 
-- DROP VIEW tableau."SA-001_Sales";
-- create the view tableau."SA-001_Sales"
CREATE 
OR REPLACE VIEW tableau."SA - 001_Sales" AS 
--retrieve 17 fields from the function report.get_sa001 
--in the subquery sales
-- 1st CTE called sales below
WITH sales AS 
(
   SELECT
      get_sa001."Period_date",
      get_sa001."Site",
      get_sa001."Customer_code",
      get_sa001."Internal_reference",
      get_sa001."InvoiceNumber",
      get_sa001."Value_in_currency",
      get_sa001."Value_in_EUR",
      get_sa001."Value_Budget_in_EUR",
      get_sa001."Selling_price_CUR",
      get_sa001."Selling_price_EUR",
      get_sa001."Currency_code",
      get_sa001."Selling_quantity",
      get_sa001."Variance_price_CUR",
      get_sa001."Variance_price_EUR",
      get_sa001."Variance_value_CUR",
      get_sa001."Variance_value_EUR",
      get_sa001."Selling_date" 
   FROM
      report.get_sa001('2015-01-01'::date::TIMESTAMP WITHOUT TIME ZONE, 'now'::text::date::TIMESTAMP WITHOUT TIME ZONE, 32) get_sa001("Period_date", "Site", "Customer_code", "Internal_reference", "InvoiceNumber", "Value_in_currency", "Value_in_EUR", "Value_Budget_in_EUR", "Selling_price_CUR", "Selling_price_EUR", "Currency_code", "Selling_quantity", "Variance_price_CUR", "Variance_price_EUR", "Variance_value_CUR", "Variance_value_EUR", "Selling_date") 
)
,
-- the part above get_sa001("Period_date", ... 
-- is done automatically by Postgres when creating a view the part above
-- for the second CTE , 
-- retrieve 9 columns by joining the following tables:
-- "T02_Customers", 
-- "C05_GeographicAreas", 
-- "C04_GlobalCustomers" for the CTE called t02_customers
--2nd CTE called t02_customers below
t02_customers AS 
(
   SELECT
      "T02_Customers"."Customer_name",
      cc04."Global_customer" AS "T02_Global_customer",
      -- store in Customer2 the Customer_name of table "T02_Customers" if "Global_customer" is empty
      -- if it is not empty , it will put "Global_customer" from the table "C04_GlobalCustomers"
      -- This for the CASE below
      CASE
         WHEN
            cc04."Global_customer"::text = '#ND'::text 
            OR cc04."Global_customer"::text = ''::text 
         THEN
            "T02_Customers"."Customer_name" 
         ELSE
            cc04."Global_customer" 
      END
      AS "Customer2", "T02_Customers"."Country_ISO3", cc05."Continent" AS "Customer_continent", cc05."Country" AS "Customer_country", "T02_Customers"."Site", "T02_Customers"."Customer_code", 		--stock dans Reference_interco 'Y' si le Global_customer_C04 de T02_Customers = 'AVOCarbon', sinon 'N'
      -- ok
      CASE
         WHEN
            "T02_Customers"."Global_customer_C04"::text = 'AVOCarbon'::text 
         THEN
            'Y'::character varying 
         ELSE
            'N'::character varying 
      END
      AS "Reference_interco" 
   FROM
      dw."T02_Customers" 		--join of table "T02_Customers" and "C05_GeographicAreas" (see below)
      LEFT JOIN
         dw."C05_GeographicAreas" cc05 
         ON "T02_Customers"."Country_ISO3"::text = cc05."Country_ISO3"::text 			--jointure de la T02_Customers et la C04_GlobalCustomers
         --ok
      LEFT JOIN
         dw."C04_GlobalCustomers" cc04 
         ON "T02_Customers"."Global_customer_C04"::text = cc04."Global_customer"::text 			--condition : retrive only records where site of "T02_Customers" is equal to our first CTE 
         --sales and "Customer_code" to reduce the number of lines
   WHERE
      (
("T02_Customers"."Site"::text, "T02_Customers"."Customer_code"::text) IN 
         (
            SELECT
               d_1."Site",
               d_1."Customer_code" 
            FROM
               sales d_1
         )
      )
)
,
-- retrieve 4 lines 
-- from the tables T01_References and 
-- C02_ProductSegments from the CTE t02_customers_segments
--3rd CTE called t02_customers_segments
t02_customers_segments AS 
(
   SELECT
      "T01_References"."Segment_code" AS "T01_Segment_Code",
      "T01_References"."Site",
      "T01_References"."Internal_reference" AS "Reference",
      "C02_ProductSegments"."Segment_name" AS "Reference_segment" 
   FROM
      dw."T01_References" 		--jointure de la T01_References et la C02_ProductSegments --ok
      LEFT JOIN
         dw."C02_ProductSegments" 
         ON "T01_References"."Segment_code"::text = "C02_ProductSegments"."Segment_code"::text 			--condition : only retrieve records where site of table "T01_References" 
         --is equal to our first CTE sales as well as the internal_reference
         --same thing as above
   WHERE
      (
("T01_References"."Site"::text, "T01_References"."Internal_reference"::text) IN 
         (
            SELECT
               d_1."Site",
               d_1."Internal_reference" 
            FROM
               sales d_1
         )
      )
)
,
--retrieve 4 lines from tables "t02_customers_applications" and "C03_MotorApplications" 
--For the 4th CTE called t02_customers_segments below
t02_customers_applications AS 
(
   SELECT
      max("T12_RefCustomer"."Application_code"::text) AS "T12_Application_code",
      "T12_RefCustomer"."Site",
      "T12_RefCustomer"."Internal_reference",
      max("C03_MotorApplications"."Motor_application"::text) AS "Reference_motorapplication" 
   FROM
      dw."T12_RefCustomer" 		--jointure de la T12_RefCustomer et la C03_MotorApplications
      JOIN
         dw."C03_MotorApplications" 
         ON "T12_RefCustomer"."Application_code"::text = "C03_MotorApplications"."Application_code"::text 			--condition : only retrieve records where site of "T12_RefCustomer" is 
         -- equal to our first CTE, sales and internal_reference
   WHERE
      (
("T12_RefCustomer"."Site"::text, "T12_RefCustomer"."Internal_reference"::text) IN 
         (
            SELECT
               d_1."Site",
               d_1."Internal_reference" 
            FROM
               sales d_1
         )
      )
      --groupe par Site et internal_reference
   GROUP BY
      "T12_RefCustomer"."Site",
      "T12_RefCustomer"."Internal_reference" 
)
--final query below
--récupère 17 champs of CTE sales, 
--6 of CTE t02_customers, 
--2 of CTE t02_customers_segments 
--&  1 from CTE t02_customers_applications
--There are less fields than in the CTE as some of them were used
--for joins and not useful in the final query
SELECT
   sales."Period_date",
   sales."Site",
   sales."Customer_code",
   sales."Internal_reference",
   sales."InvoiceNumber",
   sales."Value_in_currency",
   sales."Value_in_EUR",
   sales."Value_Budget_in_EUR",
   sales."Selling_price_CUR",
   sales."Selling_price_EUR",
   sales."Currency_code",
   sales."Selling_quantity",
   sales."Variance_price_CUR",
   sales."Variance_price_EUR",
   sales."Variance_value_CUR",
   sales."Variance_value_EUR",
   sales."Selling_date",
   t02_customers."Customer_name",
   t02_customers."T02_Global_customer",
   t02_customers."Customer_country",
   t02_customers."Customer_continent",
   t02_customers."Customer2",
   t02_customers."Reference_interco",
   t02_customers_segments."Reference_segment",
   t02_customers_segments."Reference",
   t02_customers_applications."Reference_motorapplication" 
FROM
   sales 	--jointure des sous requêtes
   LEFT JOIN
      t02_customers 
      ON sales."Customer_code"::text = t02_customers."Customer_code"::text 
      AND sales."Site"::text = t02_customers."Site"::text 
   LEFT JOIN
      t02_customers_segments 
      ON sales."Internal_reference"::text = t02_customers_segments."Reference"::text 
      AND sales."Site"::text = t02_customers_segments."Site"::text 
   LEFT JOIN
      t02_customers_applications 
      ON sales."Internal_reference"::text = t02_customers_applications."Internal_reference"::text 
      AND sales."Site"::text = t02_customers_applications."Site"::text;
      
      
ALTER TABLE tableau."SA - 001_Sales" OWNER TO avocarbon;
COMMENT 
ON VIEW tableau."SA - 001_Sales" IS 'Get all from sales, link codes from sales with T01,T02 and T12 to get names customer, segment,
 motorapplication. Exemple : Customer_code = Customer_code => Customer_name';

