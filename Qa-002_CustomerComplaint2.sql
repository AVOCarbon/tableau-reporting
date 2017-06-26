-- View: tableau."Qa-002_CustomerComplaint2"

-- DROP VIEW tableau."Qa-002_CustomerComplaint2";

--Crée la vue tableau."Qa-002_CustomerComplaint2"
CREATE OR REPLACE VIEW tableau."Qa-002_CustomerComplaint2" AS 
--recupère dans complaint 5 champs de la fonction report.get_qa002 dans la sous requête complaint
 WITH complaint AS (
         SELECT get_qa002."Site",
            get_qa002."Period_date",
			--recupère le mois 
            to_char(get_qa002."Period_date", 'Mon'::text) AS mon,
			--recupère l'année
            date_part('year'::text, get_qa002."Period_date") AS yyyy,
			--somme des Qty_defective_for_PPM de la get_qa002
            sum(get_qa002."Qty_defective_for_PPM") AS "Qty_defective_for_PPM_month"
           FROM report.get_qa002('2015-01-01'::date::timestamp without time zone, 'now'::text::date::timestamp without time zone, 32) get_qa002("Period_date", "Site", "Customer_code", "Internal_reference", "Internal_claim_ID", "Customer_claim_ID", "Qty_defective_for_PPM", "Claim_status", "Claim_type", "Recurring", "Date_of_claim", "Date_of_1st_reply", "Date_of_action_plan", "Date_of_closing", "Days_to_reply", "Days_to_action_plan", "Days_to_closing", "CNQ_in_currency")
		  --groupe par Site, Period_date, mon
          GROUP BY get_qa002."Site", get_qa002."Period_date", to_char(get_qa002."Period_date", 'Mon'::text)
		  --ordonée par mon, Period_date, Site
          ORDER BY to_char(get_qa002."Period_date", 'Mon'::text), get_qa002."Period_date", get_qa002."Site"
        ), 
--recupère 4 champs de la fonction report.get_sa001 dans la sous requête sales		
		sales AS (
         SELECT get_sa001."Site",
		    --recupère le mois
            to_char(get_sa001."Selling_date", 'Mon'::text) AS mon,
			--recupère l'année
            date_part('year'::text, get_sa001."Selling_date") AS yyyy,
			--somme des value_in_EUR de la get_sa001
            sum(get_sa001."Value_in_EUR") AS "Value_in_EUR_Per_Month"
           FROM report.get_sa001('2015-01-01'::date::timestamp without time zone, 'now'::text::date::timestamp without time zone, 32) get_sa001("Period_date", "Site", "Customer_code", "Internal_reference", "InvoiceNumber", "Value_in_currency", "Value_in_EUR", "Value_Budget_in_EUR", "Selling_price_CUR", "Selling_price_EUR", "Currency_code", "Selling_quantity", "Variance_price_CUR", "Variance_price_EUR", "Variance_value_CUR", "Variance_value_EUR", "Selling_date")
		  --condition : recupère uniquement les enregistrements ou le Site de la get_sa001 est égal à celle de la première sous requête complaint ainsi que le mois et l'année
          WHERE ((get_sa001."Site"::text, to_char(get_sa001."Selling_date", 'Mon'::text), date_part('year'::text, get_sa001."Selling_date")) IN ( SELECT complaint_1."Site",
                    complaint_1.mon,
                    complaint_1.yyyy
                   FROM complaint complaint_1))
		  --groupe par Site, mon, year 
          GROUP BY get_sa001."Site", to_char(get_sa001."Selling_date", 'Mon'::text), date_part('year'::text, get_sa001."Selling_date")
		  --ordonnée par year, Site, mon
          ORDER BY date_part('year'::text, get_sa001."Selling_date"), get_sa001."Site", to_char(get_sa001."Selling_date", 'Mon'::text)
        )
--recupère 5 champs de la sous requête complaint ainsi que 1 champ de la sous requête sales
 SELECT complaint."Site",
    complaint."Period_date",
    complaint.mon,
    complaint.yyyy,
    complaint."Qty_defective_for_PPM_month",
    sales."Value_in_EUR_Per_Month",
	--Qty_defective_for_PPM_month divisé par la value_in_EUR_Per_Month multiplier par 1000000 pour obtenir le PPM mensuel
    complaint."Qty_defective_for_PPM_month" / sales."Value_in_EUR_Per_Month" * 1000000::numeric AS "Monthly_PPM"
   FROM complaint
     --jointure des sous requêtes
     LEFT JOIN sales USING ("Site", mon, yyyy);

ALTER TABLE tableau."Qa-002_CustomerComplaint2"
  OWNER TO avocarbon;
COMMENT ON VIEW tableau."Qa-002_CustomerComplaint2"
  IS 'Create Qty_defective_for_PPM_month, create Value_in_EUR_Per_Month. Select the formula to calculate the Monthly PPM as well as the month year and Site so we have a distinct PPM per month and site';
