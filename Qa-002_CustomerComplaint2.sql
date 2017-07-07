-- View: tableau."Qa-002_CustomerComplaint2"

-- DROP VIEW tableau."Qa-002_CustomerComplaint2";

--	Create view tableau."Qa-002_CustomerComplaint2"
CREATE OR REPLACE VIEW tableau."Qa-002_CustomerComplaint2" AS 
--	1st CTE: "complaint"
--	retrieve from CTE, "complaint" 5 fields from function report."get_qa002" 
WITH complaint AS 
 (
         SELECT get_qa002."Site",
            get_qa002."Period_date",
--	retrieve the month of the complaint
            to_char(get_qa002."Period_date", 'Mon'::text) AS mon,
--	retrieve the year of the complaint
            date_part('year'::text, get_qa002."Period_date") AS yyyy,
--	sum get_qa002."Qty_defective_for_PPM" 
            sum(get_qa002."Qty_defective_for_PPM") AS "Qty_defective_for_PPM_month"
           FROM report.get_qa002('2015-01-01'::date::timestamp without time zone, 'now'::text::date::timestamp without time zone, 32) get_qa002("Period_date", "Site", "Customer_code", "Internal_reference", "Internal_claim_ID", "Customer_claim_ID", "Qty_defective_for_PPM", "Claim_status", "Claim_type", "Recurring", "Date_of_claim", "Date_of_1st_reply", "Date_of_action_plan", "Date_of_closing", "Days_to_reply", "Days_to_action_plan", "Days_to_closing", "CNQ_in_currency")
--	group by "Site", "Period_date" and "mon"
          GROUP BY get_qa002."Site", get_qa002."Period_date", to_char(get_qa002."Period_date", 'Mon'::text)
--	order by "mon", "Period_date" and "Site"
          ORDER BY to_char(get_qa002."Period_date", 'Mon'::text), get_qa002."Period_date", get_qa002."Site"
), 
--	2nd CTE: "sales"
--	retrieve 4 fields from the function report."get_sa001" 		
sales AS 
(
         SELECT get_sa001."Site",
--	retrieve the  month of the sales
            to_char(get_sa001."Selling_date", 'Mon'::text) AS mon,
--	retrieve year of the sales
            date_part('year'::text, get_sa001."Selling_date") AS yyyy,
--	sum "value_in_EUR" of the sales
            sum(get_sa001."Value_in_EUR") AS "Value_in_EUR_Per_Month"
           FROM report.get_sa001('2015-01-01'::date::timestamp without time zone, 'now'::text::date::timestamp without time zone, 32) 
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
--	condition : where get_sa001."Site",  get_sa001."Selling_date" year and month have values
--				in "Site", "mon" and "yyyy" of the CTE, "complaint"
          WHERE ((get_sa001."Site"::text, to_char(get_sa001."Selling_date", 'Mon'::text), date_part('year'::text, get_sa001."Selling_date")) IN ( SELECT complaint_1."Site",
                    complaint_1.mon,
                    complaint_1.yyyy
                   FROM complaint complaint_1))
--	group by "Site", "mon" and "year" 
          GROUP BY get_sa001."Site", to_char(get_sa001."Selling_date", 'Mon'::text), date_part('year'::text, get_sa001."Selling_date")
--	order by "year", "Site" and "mon"
          ORDER BY date_part('year'::text, get_sa001."Selling_date"), get_sa001."Site", to_char(get_sa001."Selling_date", 'Mon'::text)
)
--retrieve 5 fields from CTE, "complaint" and one field from CTE, "sales"
SELECT complaint."Site",
    complaint."Period_date",
    complaint.mon,
    complaint.yyyy,
    complaint."Qty_defective_for_PPM_month",
    sales."Value_in_EUR_Per_Month",
--	"Qty_defective_for_PPM_month" divided by "value_in_EUR_Per_Month", all multiplied by 1000000 to get monthly PPM
    complaint."Qty_defective_for_PPM_month" / sales."Value_in_EUR_Per_Month" * 1000000::numeric AS "Monthly_PPM"
FROM complaint
--	join CTE
LEFT JOIN sales USING ("Site", mon, yyyy);

ALTER TABLE tableau."Qa-002_CustomerComplaint2"
  OWNER TO avocarbon;
COMMENT ON VIEW tableau."Qa-002_CustomerComplaint2"
  IS 'Create Qty_defective_for_PPM_month, create Value_in_EUR_Per_Month. Select the formula to calculate the Monthly PPM as well as the month year and Site so we have a distinct PPM per month and site';
