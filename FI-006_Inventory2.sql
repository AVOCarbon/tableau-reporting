-- View: tableau."FI-006_Inventory2"

-- DROP VIEW tableau."FI-006_Inventory2";

--Crée la vue tableau."FI-006_Inventory2"
CREATE OR REPLACE VIEW tableau."FI-006_Inventory2" AS 
--recupère 3 champs de la fonction report.get_fi006 dans la sous requête inventory
 WITH inventory AS (
         SELECT get_fi006."Site",
            get_fi006."Period_date",
			--somme des Inventory_value_net_EUR
            sum(get_fi006."Inventory_value_net_EUR") AS "Value_net_Per_month"
           FROM report.get_fi006('2015-01-01'::date::timestamp without time zone, (((date_trunc('month'::text, now())::date - 1)::text)::date)::timestamp without time zone, 32) get_fi006("Period_date", "Site", "Internal_reference", "Inventory_quantity", "Inventory_location", "Inventory_unitprice", "Inventory_value_gross_CUR", "ratePerEur", "Inventory_value_gross_EUR", "Inventory_value_net_CUR", "Inventory_value_net_EUR", "Inventory_obsolete", "Inventory_lastmovement")
		  --groupée par Period_date, Site
          GROUP BY get_fi006."Period_date", get_fi006."Site"
		  --ordonnée par Site, Period_date
          ORDER BY get_fi006."Site", get_fi006."Period_date"
        ), sales AS (
         SELECT get_sa001."Site",
            get_sa001."Period_date",
			--somme des Value_in_EUR du mois 
            sum(get_sa001."Value_in_EUR") AS "Value_in_EUR_first_month",
			--somme des Value_in_EUR de la ligne suivante (mois + 1)
            lead(sum(get_sa001."Value_in_EUR")) OVER (PARTITION BY get_sa001."Site" ORDER BY get_sa001."Site", get_sa001."Period_date") AS "Value_in_EUR_second_month",
			--somme des Value_in_EUR de la 2ème ligne suivante (mois + 2)
            lead(sum(get_sa001."Value_in_EUR"), 2) OVER (PARTITION BY get_sa001."Site" ORDER BY get_sa001."Site", get_sa001."Period_date") AS "Value_in_EUR_third_month"
           FROM report.get_sa001('2015-01-01'::date::timestamp without time zone, (((date_trunc('month'::text, now())::date - 1)::text)::date)::timestamp without time zone, 32) get_sa001("Period_date", "Site", "Customer_code", "Internal_reference", "InvoiceNumber", "Value_in_currency", "Value_in_EUR", "Value_Budget_in_EUR", "Selling_price_CUR", "Selling_price_EUR", "Currency_code", "Selling_quantity", "Variance_price_CUR", "Variance_price_EUR", "Variance_value_CUR", "Variance_value_EUR", "Selling_date")
		  --condition : recupère uniquement les enregistrements ou le Site de la get_sa001 est égal à celle de la première sous requête inventory ainsi que le Period_date
          WHERE ((get_sa001."Site"::text, get_sa001."Period_date") IN ( SELECT inventory_1."Site",
                    inventory_1."Period_date"
                   FROM inventory inventory_1))
		  --groupée par Period_date, Site
          GROUP BY get_sa001."Period_date", get_sa001."Site"
		  --ordonée par Site, Period_date
          ORDER BY get_sa001."Site", get_sa001."Period_date"
        )
--recupère 3 champs de la sous requête inventory et 4 champs de la sous requête sales
 SELECT inventory."Site",
    inventory."Period_date",
    inventory."Value_net_Per_month",
    sales."Value_in_EUR_first_month",
    sales."Value_in_EUR_second_month",
    sales."Value_in_EUR_third_month",
	    --stock dans Days_of_Stock la somme des Value_in_EUR sur 3 mois si aucune est null divisé par la somme des jours de la période de 3 mois
		-- sinon si le dernier mois est null, la somme des Value_in_EUR sur 2 mois divisé par la somme des jours de la période de 2 mois 
		-- sinon si les deux derniers mois sont null, la Value_in_EUR sur 1 mois divisé par le nombre de jours du mois
        CASE
            WHEN sales."Value_in_EUR_first_month" IS NOT NULL AND sales."Value_in_EUR_second_month" IS NOT NULL AND sales."Value_in_EUR_third_month" IS NOT NULL THEN inventory."Value_net_Per_month"::double precision / ((sales."Value_in_EUR_first_month" + sales."Value_in_EUR_second_month" + sales."Value_in_EUR_third_month")::double precision / date_part('day'::text, sales."Period_date" + '1 mon'::interval * 3::double precision - sales."Period_date"))
            WHEN sales."Value_in_EUR_first_month" IS NOT NULL AND sales."Value_in_EUR_second_month" IS NOT NULL AND sales."Value_in_EUR_third_month" IS NULL THEN inventory."Value_net_Per_month"::double precision / ((sales."Value_in_EUR_first_month" + sales."Value_in_EUR_second_month")::double precision / date_part('day'::text, sales."Period_date" + '1 mon'::interval * 2::double precision - sales."Period_date"))
            WHEN sales."Value_in_EUR_first_month" IS NOT NULL AND sales."Value_in_EUR_second_month" IS NULL AND sales."Value_in_EUR_third_month" IS NULL THEN inventory."Value_net_Per_month"::double precision / (sales."Value_in_EUR_first_month"::double precision / date_part('day'::text, sales."Period_date" + '1 mon'::interval * 1::double precision - sales."Period_date"))
            ELSE NULL::double precision
        END AS "Days_of_Stock"
   FROM inventory
     --jointure des sous requêtes
     LEFT JOIN sales ON inventory."Site"::text = sales."Site"::text AND inventory."Period_date" = sales."Period_date";

ALTER TABLE tableau."FI-006_Inventory2"
  OWNER TO avocarbon;
COMMENT ON VIEW tableau."FI-006_Inventory2"
  IS 'Get net month value from fi006 and value EUR from sa001, create an adverage of value EUR per day (using 3 months if not null, else 2 or 1), devide month value by value EUR per day to get Days of stock';
