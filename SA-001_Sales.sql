-- View: tableau."SA-001_Sales"

-- DROP VIEW tableau."SA-001_Sales";

--Crée la vue tableau."SA-001_Sales"
CREATE OR REPLACE VIEW tableau."SA-001_Sales" AS 
 --récupère 17 champs de la fonction report.get_sa001 dans la sous requête sales
 WITH sales AS (
         SELECT get_sa001."Period_date",
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
           FROM report.get_sa001('2015-01-01'::date::timestamp without time zone, 'now'::text::date::timestamp without time zone, 32) get_sa001("Period_date", "Site", "Customer_code", "Internal_reference", "InvoiceNumber", "Value_in_currency", "Value_in_EUR", "Value_Budget_in_EUR", "Selling_price_CUR", "Selling_price_EUR", "Currency_code", "Selling_quantity", "Variance_price_CUR", "Variance_price_EUR", "Variance_value_CUR", "Variance_value_EUR", "Selling_date")
        ), 
--récupère 9 champs des tables T02_Customers, C05_GeographicAreas, C04_GlobalCustomers dans la sous requête t02_customers
		t02_customers AS (
         SELECT "T02_Customers"."Customer_name",
            cc04."Global_customer" AS "T02_Global_customer",
				--stock dans Customer2 le Customer_name de T02_Customers si le Global_customer est vide, sinon le Global_customer de la C04_GlobalCustomers
                CASE
                    WHEN cc04."Global_customer"::text = '#ND'::text OR cc04."Global_customer"::text = ''::text THEN "T02_Customers"."Customer_name"
                    ELSE cc04."Global_customer"
                END AS "Customer2",
            "T02_Customers"."Country_ISO3",
            cc05."Continent" AS "Customer_continent",
            cc05."Country" AS "Customer_country",
            "T02_Customers"."Site",
            "T02_Customers"."Customer_code",
				--stock dans Reference_interco 'Y' si le Global_customer_C04 de T02_Customers = 'AVOCarbon', sinon 'N'
                CASE
                    WHEN "T02_Customers"."Global_customer_C04"::text = 'AVOCarbon'::text THEN 'Y'::character varying
                    ELSE 'N'::character varying
                END AS "Reference_interco"
           FROM dw."T02_Customers"
			 --jointure de la T02_Customers et la C05_GeographicAreas
             LEFT JOIN dw."C05_GeographicAreas" cc05 ON "T02_Customers"."Country_ISO3"::text = cc05."Country_ISO3"::text
			 --jointure de la T02_Customers et la C04_GlobalCustomers
             LEFT JOIN dw."C04_GlobalCustomers" cc04 ON "T02_Customers"."Global_customer_C04"::text = cc04."Global_customer"::text
			 --condition : récupère uniquement les enregistrements ou le site de T02_Customers est égal à notre première sous requête sales ainsi que le Customer_code afin de réduire le nombre de lignes
          WHERE (("T02_Customers"."Site"::text, "T02_Customers"."Customer_code"::text) IN ( SELECT d_1."Site",
                    d_1."Customer_code"
                   FROM sales d_1))
--récupère 4 lignes des tables T01_References et C02_ProductSegments dans la sous requête t02_customers_segments
        ), t02_customers_segments AS (
         SELECT "T01_References"."Segment_code" AS "T01_Segment_Code",
            "T01_References"."Site",
            "T01_References"."Internal_reference" AS "Reference",
            "C02_ProductSegments"."Segment_name" AS "Reference_segment"
           FROM dw."T01_References"
			 --jointure de la T01_References et la C02_ProductSegments
             LEFT JOIN dw."C02_ProductSegments" ON "T01_References"."Segment_code"::text = "C02_ProductSegments"."Segment_code"::text
			--condition : récupère uniquement les enregistrements ou le site de la T01_References est égal à notre première sous requête sales ainsi que l'internal_reference
          WHERE (("T01_References"."Site"::text, "T01_References"."Internal_reference"::text) IN ( SELECT d_1."Site",
                    d_1."Internal_reference"
                   FROM sales d_1))
--récupère 4 lignes des tables t02_customers_applications et C03_MotorApplications
        ), t02_customers_applications AS (
         SELECT 
		 max("T12_RefCustomer"."Application_code"::text) AS "T12_Application_code",
            "T12_RefCustomer"."Site",
            "T12_RefCustomer"."Internal_reference",
            max("C03_MotorApplications"."Motor_application"::text) AS "Reference_motorapplication"
           FROM dw."T12_RefCustomer"
			 --jointure de la T12_RefCustomer et la C03_MotorApplications
             JOIN dw."C03_MotorApplications" ON "T12_RefCustomer"."Application_code"::text = "C03_MotorApplications"."Application_code"::text
		  --condition : récupère uniquement les enregistrements ou le site de la T12_RefCustomer est égal à notre première sous requête sales ainsi que l'internal_reference
          WHERE (("T12_RefCustomer"."Site"::text, "T12_RefCustomer"."Internal_reference"::text) IN ( SELECT d_1."Site",
                    d_1."Internal_reference"
                   FROM sales d_1))
		  --groupe par Site et internal_reference	   
          GROUP BY "T12_RefCustomer"."Site", "T12_RefCustomer"."Internal_reference"
        )
 SELECT 
 --récupère 17 champs de la sous requête sales, 6 de la sous requête t02_customers, 2 de la sous requête t02_customers_segments et 1 de la t02_customers_applications
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
   FROM sales
     --jointure des sous requêtes 
     LEFT JOIN t02_customers ON sales."Customer_code"::text = t02_customers."Customer_code"::text AND sales."Site"::text = t02_customers."Site"::text
     LEFT JOIN t02_customers_segments ON sales."Internal_reference"::text = t02_customers_segments."Reference"::text AND sales."Site"::text = t02_customers_segments."Site"::text
     LEFT JOIN t02_customers_applications ON sales."Internal_reference"::text = t02_customers_applications."Internal_reference"::text AND sales."Site"::text = t02_customers_applications."Site"::text;

ALTER TABLE tableau."SA-001_Sales"
  OWNER TO avocarbon;
COMMENT ON VIEW tableau."SA-001_Sales"
  IS 'Get all from sales, link codes from sales with T01,T02 and T12 to get names customer, segment, motorapplication. Exemple : Customer_code = Customer_code => Customer_name';
