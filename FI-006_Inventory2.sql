-- View: tableau."FI-006_Inventory2"

-- DROP VIEW tableau."FI-006_Inventory2";

--	Create view tableau."FI-006_Inventory2"
CREATE OR REPLACE VIEW tableau."FI-006_Inventory2" AS 
--	1st CTE, "inventory"
--	retrieve 3 fields from function report.get_fi006 
 WITH inventory AS 
 (
         SELECT get_fi006."Site",
            get_fi006."Period_date",
--	sum "Inventory_value_net_EUR"
            sum(get_fi006."Inventory_value_net_EUR") AS "Value_net_Per_month"
--	gives the last day of the last month (e.g if we are the 7th of July 2017, it will give the 30th of June 2017			
           FROM report.get_fi006('2015-01-01'::date::timestamp without time zone, (((date_trunc('month'::text, now())::date - 1)::text)::date)::timestamp without time zone, 32) 
		   get_fi006("Period_date", 
					"Site", 
					"Internal_reference", 
					"Inventory_quantity", 
					"Inventory_location", 
					"Inventory_unitprice", 
					"Inventory_value_gross_CUR", 
					"ratePerEur", "Inventory_value_gross_EUR", 
					"Inventory_value_net_CUR", 
					"Inventory_value_net_EUR", 
					"Inventory_obsolete", 
					"Inventory_lastmovement")
--	group by "Period_date" and "Site"
          GROUP BY get_fi006."Period_date", get_fi006."Site"
--	order by "Site" and "Period_date"
          ORDER BY get_fi006."Site", get_fi006."Period_date"
), 
--	2nd CTE, "sales"
--	retrieve 5 rows from function, report."get_sa001"  
sales AS 
(
         SELECT get_sa001."Site",
            get_sa001."Period_date",
--	sum of Value_in_EUR of the 1st month
            sum(get_sa001."Value_in_EUR") AS "Value_in_EUR_first_month",
--	sum of Value_in_EUR of next line (month + 1)
            lead(sum(get_sa001."Value_in_EUR")) 
			OVER (PARTITION BY get_sa001."Site" ORDER BY get_sa001."Site", get_sa001."Period_date") AS "Value_in_EUR_second_month",
--	sum of Value_in_EUR of the 2nd line (month + 2)
            lead(sum(get_sa001."Value_in_EUR"), 2) 
			OVER (PARTITION BY get_sa001."Site" ORDER BY get_sa001."Site", get_sa001."Period_date") AS "Value_in_EUR_third_month"
           FROM report.get_sa001('2015-01-01'::date::timestamp without time zone, (((date_trunc('month'::text, now())::date - 1)::text)::date)::timestamp without time zone, 32) 
		   get_sa001("Period_date", 
						"Site", 
						"Customer_code", 
						"Internal_reference", 
						"InvoiceNumber", 
						"Value_in_currency", 
						"Value_in_EUR", 
						"Value_Budget_in_EUR", 
						"Selling_price_CUR", 
						"Selling_price_EUR", 
						"Currency_code", 
						"Selling_quantity", 
						"Variance_price_CUR", 
						"Variance_price_EUR", 
						"Variance_value_CUR", 
						"Variance_value_EUR", 
						"Selling_date")
--	WHERE clause : retrieve rows where records of get_sa001."Site" and get_sa001."Period_date" 
--	is equal to "site" and "Period_date" of CTE, "inventory"
          WHERE ((get_sa001."Site"::text, get_sa001."Period_date") IN ( SELECT inventory_1."Site",
                    inventory_1."Period_date"
                   FROM inventory inventory_1))
--	group by "Period_date" and "Site"
          GROUP BY get_sa001."Period_date", get_sa001."Site"
--	order by "Site" and "Period_date"
          ORDER BY get_sa001."Site", get_sa001."Period_date"
)
--	retrieve 3 fields from CTE, "inventory" and 4 fields from CTE, "sales"
 SELECT inventory."Site",
    inventory."Period_date",
    inventory."Value_net_Per_month",
    sales."Value_in_EUR_first_month",
    sales."Value_in_EUR_second_month",
    sales."Value_in_EUR_third_month",
        CASE
            WHEN sales."Value_in_EUR_first_month" IS NOT NULL AND sales."Value_in_EUR_second_month" IS NOT NULL AND sales."Value_in_EUR_third_month" IS NOT NULL 
--	("Value_net_Per_month") / [("Value_in_EUR_first_month" + "Value_in_EUR_second_month" + "Value_in_EUR_third_month") / (number of days during the 3 months)]
				THEN inventory."Value_net_Per_month"::double precision / ((sales."Value_in_EUR_first_month" + sales."Value_in_EUR_second_month" + sales."Value_in_EUR_third_month")::double precision / date_part('day'::text, sales."Period_date" + '1 mon'::interval * 3::double precision - sales."Period_date"))
            WHEN sales."Value_in_EUR_first_month" IS NOT NULL AND sales."Value_in_EUR_second_month" IS NOT NULL AND sales."Value_in_EUR_third_month" IS NULL
--	("Value_net_Per_month") / [("Value_in_EUR_first_month" + "Value_in_EUR_second_month") / (number of days during the 2 months)]			
				THEN inventory."Value_net_Per_month"::double precision / ((sales."Value_in_EUR_first_month" + sales."Value_in_EUR_second_month")::double precision / date_part('day'::text, sales."Period_date" + '1 mon'::interval * 2::double precision - sales."Period_date"))
            WHEN sales."Value_in_EUR_first_month" IS NOT NULL AND sales."Value_in_EUR_second_month" IS NULL AND sales."Value_in_EUR_third_month" IS NULL
--	("Value_net_Per_month") / [("Value_in_EUR_first_month") / (number of days during the month)]			
				THEN inventory."Value_net_Per_month"::double precision / (sales."Value_in_EUR_first_month"::double precision / date_part('day'::text, sales."Period_date" + '1 mon'::interval * 1::double precision - sales."Period_date"))
            ELSE NULL::double precision
        END AS "Days_of_Stock"
   FROM inventory
--	join with the 2 CTEs
     LEFT JOIN sales ON inventory."Site"::text = sales."Site"::text AND inventory."Period_date" = sales."Period_date";

ALTER TABLE tableau."FI-006_Inventory2"
  OWNER TO avocarbon;
COMMENT ON VIEW tableau."FI-006_Inventory2"
  IS 'Get net month value from fi006 and value EUR from sa001, create an adverage of value EUR per day (using 3 months if not null, else 2 or 1), devide month value by value EUR per day to get Days of stock';
