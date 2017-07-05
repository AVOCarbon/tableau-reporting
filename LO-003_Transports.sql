--	View: tableau."LO-003_Transports"

--	DROP VIEW tableau."LO-003_Transports";

--	Create view tableau."LO-003_Transports"
CREATE OR REPLACE VIEW tableau."LO-003_Transports" AS 
--	CTE Receptions_data" : Has one CTE in it called "receptions"
-- 	This CTE was  inadvertently built and is only used at the end of 
--	the main CTE, "Transports_data" 
WITH "Receptions_data" AS 
(
--	retrieve in that CTE "Receptions_data", 18 fields using the "get_lo001" function 
--	in the sub-sub CTE "receptions"
         WITH receptions AS (
                 SELECT get_lo001."Period_date",
                    get_lo001."Site",
                    get_lo001."Supplier_code",
                    get_lo001."Internal_reference",
                    get_lo001."Shipment_number",
                    get_lo001."PO_number",
                    get_lo001."Quantity",
                    get_lo001."Movement_value_EUR",
                    get_lo001."Movement_value_CUR",
                    get_lo001."Reception_price_EUR",
                    get_lo001."Reception_price_CUR",
                    get_lo001."Variance_refprice_EUR",
                    get_lo001."Variance_refprice_CUR",
                    get_lo001."Variance_value@refprice_EUR",
                    get_lo001."Variance_value@refprice_CUR",
                    get_lo001."Purchasing_currency",
                    get_lo001."Movement_date",
                    get_lo001."Price_change"
                   FROM report.get_lo001('2015-01-01'::date::timestamp without time zone, 
					 'now'::text::date::timestamp without time zone, 32) 
		 get_lo001("Period_date", 
			   "Site", 
			   "Supplier_code", 
			   "Internal_reference", 
			   "Shipment_number", 
			   "PO_number", 
			   "Quantity", 
			   "Movement_value_EUR", 
			   "Movement_value_CUR", 
			   "Reception_price_EUR", 
			   "Reception_price_CUR", 
			   "Variance_refprice_EUR", 
			   "Variance_refprice_CUR", 
			   "Variance_value@refprice_EUR", 
			   "Variance_value@refprice_CUR", 
			   "Purchasing_currency", 
			   "Movement_date", 
			   "Price_change")
                )
--	retrieve 5 fields from the sub CTE, "receptions" to create 2 new fields : 
--	"Movement_value_EUR" = sum in Euros in receptions (Example : you received 20 000 Euros of brushes from Kunshan) 
--	"Quantity" = sum of quantity received (Example : you received 20 000 brushes from Kunshan)
--	The query is group by Period_date, Site and Supplier_code
         SELECT receptions."Period_date",
            receptions."Site",
            receptions."Supplier_code",
            sum(receptions."Movement_value_EUR") AS "Reception_value_EUR",
            sum(receptions."Quantity") AS "Reception_qty"
           FROM receptions
          GROUP BY receptions."Period_date", receptions."Site", receptions."Supplier_code"
), 
"Transports_data" AS 
(
--	retrieve 28 rows from the function "report.get_lo003" and store them in the 1st CTE, "transports"
         WITH transports AS 
				(
                 SELECT get_lo003."Period_date",
                    get_lo003."Site",
                    get_lo003."Carrier_code",
                    get_lo003.from_code,
                    get_lo003."Origin",
                    get_lo003.to_code,
                    get_lo003."Destination",
                    get_lo003."ETD_date",
--	logic : if get_lo003."ATD_date" (or attended date) is null then put get_lo003."ETD_date" (or estimated date)
--	else  get_lo003."ATD_date" (or attended date)
                        CASE
                            WHEN get_lo003."ATD_date" IS NULL THEN get_lo003."ETD_date"::date::timestamp without time zone
                            ELSE get_lo003."ATD_date"::date::timestamp without time zone
                        END 
							AS "ATD_date",
                    get_lo003."ETA_date",
--	logic : if get_lo003."ATA_date" is null then put get_lo003."ETD_date" (or ETA date)
--	else  get_lo003."ATA_date" (or ATA date)
                        CASE
                            WHEN get_lo003."ATA_date" IS NULL THEN get_lo003."ETA_date"::date::timestamp without time zone
                            ELSE get_lo003."ATA_date"::date::timestamp without time zone
                        END AS "ATA_date",
                    get_lo003."TD_delay_days",
                    get_lo003."TA_delay_days",
                    get_lo003."E_transit_days",
                    get_lo003."A_transit_days",
                    get_lo003."Shipment_type",
                    get_lo003."Premium_freight",
                    get_lo003."Costing_unit",
                    get_lo003."Units_shipped",
                    get_lo003."Invoice_amount_CUR",
                    get_lo003."Invoice_amount_EUR",
                    get_lo003."Transport_cost_CUR",
                    get_lo003."Transport_cost_EUR",
                    get_lo003."Tax_duty_cost_EUR",
                    get_lo003."Payer_code",
                    get_lo003."Total_cost_CUR",
                    get_lo003."Total_cost_EUR",
--	logic : on_time_prop equals 1 if "TA_delay_days" from "get_lo003" <> 0
--	else 1
                        CASE
                            WHEN get_lo003."TA_delay_days" <> 0 THEN 0
                            ELSE 1
                        END AS on_time_prop
                   FROM report.get_lo003('2015-01-01'::date::timestamp without time zone, 
					 'now'::text::date::timestamp without time zone, 32) 
				   get_lo003("Period_date", "Site", "Carrier_code", 
				   from_code, 
				   "Origin", 
				   to_code, 
				   "Destination", 
				   "ETD_date", 
				   "ATD_date", 
				   "ETA_date", 
				   "ATA_date", 
				   "TD_delay_days", 
				   "TA_delay_days", 
				   "E_transit_days", 
				   "A_transit_days", 
				   "Shipment_mode", 
				   "Shipment_type", 
				   "Premium_freight", 
				   "Costing_unit", 
				   "Units_shipped", 
				   "Invoice_amount_CUR", 
				   "Invoice_amount_EUR", 
				   "Transport_cost_CUR", 
				   "Transport_cost_EUR", 
				   "Tax_duty_cost_CUR", 
				   "Tax_duty_cost_EUR", 
				   "Payer_code", 
				   "Total_cost_CUR", 
				   "Total_cost_EUR")
                ), 
--	retrieve 16 fields from the view "Axis_Customers_Suppliers" and store them in the CTE, "customers_suppliers"
--	condition/logic : the CTE "customers_suppliers" retrieve rows where the field "Site" and "Customer_code" of "Axis_Customers_Suppliers" 
-- 	is equal to the fieldd "Site" and "from_code" in the CTE, "transports" 
		customers_suppliers AS 
				(
                 SELECT "Axis_Customers_Suppliers"."Site",
                    "Axis_Customers_Suppliers"."Customer_global",
                    "Axis_Customers_Suppliers"."Customer_code",
                    "Axis_Customers_Suppliers"."Customer_name",
                    "Axis_Customers_Suppliers"."Customer_account_manager",
                    "Axis_Customers_Suppliers"."Customer_interco",
                    "Axis_Customers_Suppliers"."Customer_incoterm",
                    "Axis_Customers_Suppliers"."Customer_incoterm_location",
                    "Axis_Customers_Suppliers"."Customer_incoterm_via",
                    "Axis_Customers_Suppliers"."Customer_continent",
                    "Axis_Customers_Suppliers"."Customer_country_ISO3",
                    "Axis_Customers_Suppliers"."Customer_country",
                    "Axis_Customers_Suppliers"."Customer_city",
                    "Axis_Customers_Suppliers"."Customer_zipcode",
                    "Axis_Customers_Suppliers"."Selling_payment_term_days",
                    "Axis_Customers_Suppliers"."Selling_payment_term_type"
                   FROM report."Axis_Customers_Suppliers"
                  WHERE (("Axis_Customers_Suppliers"."Site"::text, "Axis_Customers_Suppliers"."Customer_code"::text) IN ( SELECT transports."Site",
                            transports.from_code
                           FROM transports ))
                ), 
--	retrieve 16 fields from "Axis_Customers_Suppliers" and store them in the CTE, "customers_suppliers2"
--	condition/logic : retrieve records when "Site" and "Customer_code" of "Axis_Customers_Suppliers" is equal  
--	to "Site" and "to_code" from the CTE, "transports"	
		customers_suppliers2 AS 
				(
                 SELECT "Axis_Customers_Suppliers"."Site",
                    "Axis_Customers_Suppliers"."Customer_global",
                    "Axis_Customers_Suppliers"."Customer_code",
                    "Axis_Customers_Suppliers"."Customer_name",
                    "Axis_Customers_Suppliers"."Customer_account_manager",
                    "Axis_Customers_Suppliers"."Customer_interco",
                    "Axis_Customers_Suppliers"."Customer_incoterm",
                    "Axis_Customers_Suppliers"."Customer_incoterm_location",
                    "Axis_Customers_Suppliers"."Customer_incoterm_via",
                    "Axis_Customers_Suppliers"."Customer_continent",
                    "Axis_Customers_Suppliers"."Customer_country_ISO3",
                    "Axis_Customers_Suppliers"."Customer_country",
                    "Axis_Customers_Suppliers"."Customer_city",
                    "Axis_Customers_Suppliers"."Customer_zipcode",
                    "Axis_Customers_Suppliers"."Selling_payment_term_days",
                    "Axis_Customers_Suppliers"."Selling_payment_term_type"
                   FROM report."Axis_Customers_Suppliers"

                  WHERE (("Axis_Customers_Suppliers"."Site"::text, "Axis_Customers_Suppliers"."Customer_code"::text) IN ( SELECT transports."Site",
                            transports.to_code
                           FROM transports))
                ), 
--	retrieve 16 fields from "Axis_Customers_Suppliers" in the CTE, "customers_suppliers3"
--	condition/logic : retrieve records when "Site" and "Customer_code" of "Axis_Customers_Suppliers" is equal to
--	"Site" and "Carrier_code" from the CTE,	"transports"		
		customers_suppliers3 AS 
				(
                 SELECT "Axis_Customers_Suppliers"."Site",
                    "Axis_Customers_Suppliers"."Customer_global",
                    "Axis_Customers_Suppliers"."Customer_code",
                    "Axis_Customers_Suppliers"."Customer_name",
                    "Axis_Customers_Suppliers"."Customer_account_manager",
                    "Axis_Customers_Suppliers"."Customer_interco",
                    "Axis_Customers_Suppliers"."Customer_incoterm",
                    "Axis_Customers_Suppliers"."Customer_incoterm_location",
                    "Axis_Customers_Suppliers"."Customer_incoterm_via",
                    "Axis_Customers_Suppliers"."Customer_continent",
                    "Axis_Customers_Suppliers"."Customer_country_ISO3",
                    "Axis_Customers_Suppliers"."Customer_country",
                    "Axis_Customers_Suppliers"."Customer_city",
                    "Axis_Customers_Suppliers"."Customer_zipcode",
                    "Axis_Customers_Suppliers"."Selling_payment_term_days",
                    "Axis_Customers_Suppliers"."Selling_payment_term_type"
                   FROM report."Axis_Customers_Suppliers"

                  WHERE (("Axis_Customers_Suppliers"."Site"::text, "Axis_Customers_Suppliers"."Customer_code"::text) IN ( SELECT transports."Site",
                            transports."Carrier_code"
                           FROM transports))
                ), 
--	retrieve 22 field from the table "T03_Suppliers" in the CTE, "t03_suppliers"
--	condition/logic : retrieve records where "Site" and "Supplier_code" in "T03_Suppliers" is equal to 
--	"Supplier_code" and "from_code" from the CTE, "transports"		
		t03_suppliers AS 
				(
                 SELECT "T03_Suppliers"."Supplier_code",
                    "T03_Suppliers"."Supplier_name",
                    "T03_Suppliers"."Country_ISO3_C05",
                    "T03_Suppliers"."QCD_category",
                    "T03_Suppliers"."Global_supplier",
                    "T03_Suppliers"."Site",
                    "T03_Suppliers"."Import_date",
                    "T03_Suppliers"."Address1",
                    "T03_Suppliers"."Address2",
                    "T03_Suppliers"."Address3",
                    "T03_Suppliers"."Address4",
                    "T03_Suppliers"."City",
                    "T03_Suppliers"."ZipCode",
                    "T03_Suppliers"."Incoterm",
                    "T03_Suppliers"."Incoterm_location",
                    "T03_Suppliers"."Incoterm_via",
                    "T03_Suppliers"."Account_manager",
                    "T03_Suppliers"."Min_order_value",
                    "T03_Suppliers"."Min_order_qty",
                    "T03_Suppliers"."Payment_term_days",
                    "T03_Suppliers"."Payment_term_type",
                    "T03_Suppliers"."Supplier_revision_level"
                   FROM dw."T03_Suppliers"
                  WHERE (("T03_Suppliers"."Site"::text, "T03_Suppliers"."Supplier_code"::text) IN ( SELECT transports."Site",
                            transports.from_code
                           FROM transports))
                ), 
--	retrieve 5 fields from the CTE above, "Receptions_data" and store them in the CTE "receptions_data" below (beware of the 'case sensitive naming' 
--	as "receptions_data" != "Receptions_data")	
--	condition/logic : retrieve rows where "Site" , "Supplier_code" and "Period_date" from CTE, "Receptions_data" is equal "to_code" , "from_code"  
--	"Period_date" in CTE, "transports"		
		receptions_data AS 
				(
                 SELECT "Receptions_data"."Period_date",
                    "Receptions_data"."Site",
                    "Receptions_data"."Supplier_code",
                    "Receptions_data"."Reception_value_EUR",
                    "Receptions_data"."Reception_qty"
                   FROM "Receptions_data"

                  WHERE (("Receptions_data"."Site"::text, "Receptions_data"."Supplier_code"::text, "Receptions_data"."Period_date") IN ( SELECT transports.to_code,
                            transports.from_code,
                            transports."Period_date"
                           FROM transports))
                )
--	retrieve 5 fields from the CTE, "customers_suppliers"
--  	6 fields from the CTE, "t03_suppliers", 
--	4 fields from the CTE, "customers_suppliers2" 
--	1 field from the CTE, "customers_suppliers3"
--	2 field from the CTE, "receptions_data" 
--	28 fields from the CTE, "transports"
         SELECT customers_suppliers."Customer_name" AS "Supplier_name",
            customers_suppliers."Customer_incoterm"::text AS "Supplier_incoterm",
            customers_suppliers."Customer_interco" AS "Supplier_interco",
            customers_suppliers."Customer_country_ISO3" AS "Supplier_country",
            customers_suppliers."Customer_continent" AS "Supplier_continent",
            t03_suppliers."Address1" AS "Supplier_Address1",
            t03_suppliers."Address2" AS "Supplier_Address2",
            t03_suppliers."Address3" AS "Supplier_Address3",
            t03_suppliers."Address4" AS "Supplier_Address4",
            t03_suppliers."City" AS "Supplier_City",
            t03_suppliers."ZipCode" AS "Supplier_ZipCode",
            customers_suppliers2."Customer_name",
            customers_suppliers2."Customer_country_ISO3" AS "Customer_country",
            customers_suppliers2."Customer_continent",
            customers_suppliers3."Customer_name" AS "Carrier_name",
            receptions_data."Reception_value_EUR",
            receptions_data."Reception_qty",
            transports."Period_date",
            transports."Site",
            transports."Carrier_code",
            transports.from_code,
            transports."Origin",
            transports.to_code,
            transports."Destination",
            transports."ETD_date",
            transports."ATD_date",
            transports."ETA_date",
            transports."ATA_date",
            transports."TD_delay_days",
            transports."TA_delay_days",
            transports."E_transit_days",
            transports."A_transit_days",
            transports."Shipment_type",
            transports."Premium_freight",
            transports."Costing_unit",
            transports."Units_shipped",
            transports."Invoice_amount_CUR",
            transports."Invoice_amount_EUR",
            transports."Transport_cost_CUR",
            transports."Transport_cost_EUR",
            transports."Tax_duty_cost_EUR",
            transports."Payer_code",
            transports."Total_cost_CUR",
            transports."Total_cost_EUR",
            transports.on_time_prop
           FROM transports
--	join CTEs and functions or views or tables
             LEFT JOIN report."Axis_Customers_Suppliers" customers_suppliers ON transports."Site"::text = customers_suppliers."Site"::text 
			 AND transports.from_code::text = customers_suppliers."Customer_code"::text
             LEFT JOIN dw."T03_Suppliers" t03_suppliers ON transports."Site"::text = t03_suppliers."Site"::text 
			 AND transports.from_code::text = t03_suppliers."Supplier_code"::text
             LEFT JOIN report."Axis_Customers_Suppliers" customers_suppliers2 ON transports."Site"::text = customers_suppliers2."Site"::text 
			 AND transports.to_code::text = customers_suppliers2."Customer_code"::text
             LEFT JOIN report."Axis_Customers_Suppliers" customers_suppliers3 ON transports."Site"::text = customers_suppliers3."Site"::text 
			 AND transports."Carrier_code"::text = customers_suppliers3."Customer_code"::text
             LEFT JOIN "Receptions_data" receptions_data ON transports.to_code::text = receptions_data."Site"::text 
			 AND transports.from_code::text = receptions_data."Supplier_code"::text AND transports."Period_date" = receptions_data."Period_date"
)
--	retrieve 48 fields from the CTE, "Transports_data" 
 SELECT "Transports_data"."Supplier_name",
    "Transports_data"."Supplier_incoterm",
    "Transports_data"."Supplier_interco",
    "Transports_data"."Supplier_country",
    "Transports_data"."Supplier_continent",
    "Transports_data"."Supplier_Address1",
    "Transports_data"."Supplier_Address2",
    "Transports_data"."Supplier_Address3",
    "Transports_data"."Supplier_Address4",
    "Transports_data"."Supplier_City",
    "Transports_data"."Supplier_ZipCode",
    "Transports_data"."Customer_name",
    "Transports_data"."Customer_country",
    "Transports_data"."Customer_continent",
    "Transports_data"."Carrier_name",
    "Transports_data"."Reception_value_EUR",
    "Transports_data"."Reception_qty",
    "Transports_data"."Period_date",
    "Transports_data"."Site",
    "Transports_data"."Carrier_code",
    "Transports_data".from_code,
    "Transports_data"."Origin",
    "Transports_data".to_code,
    "Transports_data"."Destination",
    "Transports_data"."ETD_date",
    "Transports_data"."ATD_date",
    "Transports_data"."ETA_date",
    "Transports_data"."ATA_date",
    "Transports_data"."TD_delay_days",
    "Transports_data"."TA_delay_days",
    "Transports_data"."E_transit_days",
    "Transports_data"."A_transit_days",
    "Transports_data"."Shipment_type",
    "Transports_data"."Premium_freight",
    "Transports_data"."Costing_unit",
    "Transports_data"."Units_shipped",
    "Transports_data"."Invoice_amount_CUR",
    "Transports_data"."Invoice_amount_EUR",
    "Transports_data"."Transport_cost_CUR",
    "Transports_data"."Transport_cost_EUR",
    "Transports_data"."Tax_duty_cost_EUR",
    "Transports_data"."Payer_code",
    "Transports_data"."Total_cost_CUR",
    "Transports_data"."Total_cost_EUR",
    "Transports_data".on_time_prop,
    (((("Transports_data"."Supplier_name"::text || ' > '::text) || "Transports_data"."Customer_name"::text) || ' ( '::text) || "Transports_data"."Supplier_incoterm") || ' )'::text AS "Flow_name",
    ("Transports_data"."Supplier_country"::text || ' > '::text) || "Transports_data"."Customer_country"::text AS "Flow_country",
    ("Transports_data"."Supplier_continent"::text || ' > '::text) || "Transports_data"."Customer_continent"::text AS "Flow_continent"
   FROM "Transports_data";

ALTER TABLE tableau."LO-003_Transports"
  OWNER TO avocarbon;
COMMENT ON VIEW tableau."LO-003_Transports"
  IS 'Get the different names for Receptions.Supplier_code linked with report."Axis_Customers_Suppliers" --- Customer_Supplier : from_code / Customer_Supplier2 : to_code / Customer_Supplier3 : Carrier_code.
  Then get various information for the Supplier and Customer';
