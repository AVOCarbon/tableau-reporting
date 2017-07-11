-- View: tableau."FI-006_Inventory3"

-- DROP VIEW tableau."FI-006_Inventory3";

--	Crée la vue tableau."FI-006_Inventory3"
CREATE OR REPLACE VIEW tableau."FI-006_Inventory3" AS 
--	1st CTE, "inventory"
--	do an UNION ALL of 6 queries
 WITH inventory AS 
 (
--	retrieve 9 fields from function, report."get_fi006" 
         SELECT 
--	stock is not obsolete
			'N'::text AS obsolete,
            'Y'::text AS "N-1",
            get_fi006."Site",
            get_fi006."Inventory_location",
            get_fi006."Period_date",
            get_fi006."Inventory_value_gross_EUR",
--	"Inventory_value_net_EUR" means the value is not obsolete
            get_fi006."Inventory_value_net_EUR" AS "value_EUR",
            get_fi006."Internal_reference",
            get_fi006."ratePerEur",
            get_fi006."Inventory_value_gross_CUR",
--	"Inventory_value_net_CUR" means the value is not obsolete
            get_fi006."Inventory_value_net_CUR" AS "value_CUR"
           FROM report.get_fi006('2015-01-01'::date::timestamp without time zone, 'now'::text::date::timestamp without time zone, 32) 
		   get_fi006("Period_date", 
					"Site", 
					"Internal_reference", 
					"Inventory_quantity", 
					"Inventory_location", 
					"Inventory_unitprice", 
					"Inventory_value_gross_CUR", 
					"ratePerEur", 
					"Inventory_value_gross_EUR", 
					"Inventory_value_net_CUR", 
					"Inventory_value_net_EUR", 
					"Inventory_obsolete", 
					"Inventory_lastmovement")
        UNION ALL
--	retrieve 9 fields from the function, report."get_fi006" ainsi que l'obsolete = 'Y' et N-1 = 'Y'
         SELECT 
--	le stock est obsolete
			'Y'::text AS obsolete,
            'Y'::text AS "N-1",
            get_fi006."Site",
            get_fi006."Inventory_location",
            get_fi006."Period_date",
            get_fi006."Inventory_value_gross_EUR",
--	obsolete value = "Inventory_value_gross_EUR" minus get_fi006."Inventory_value_net_EUR"
            get_fi006."Inventory_value_gross_EUR" - get_fi006."Inventory_value_net_EUR" AS "value_EUR",
            get_fi006."Internal_reference",
            get_fi006."ratePerEur",
            get_fi006."Inventory_value_gross_CUR",
--	obsolete value = "Inventory_value_gross_CUR" minus get_fi006."Inventory_value_net_CUR"
            get_fi006."Inventory_value_gross_CUR" - get_fi006."Inventory_value_net_CUR" AS "value_CUR"
           FROM report.get_fi006('2015-01-01'::date::timestamp without time zone, 'now'::text::date::timestamp without time zone, 32) 
		   get_fi006("Period_date", "Site", "Internal_reference", "Inventory_quantity", "Inventory_location", "Inventory_unitprice", "Inventory_value_gross_CUR", "ratePerEur", "Inventory_value_gross_EUR", "Inventory_value_net_CUR", "Inventory_value_net_EUR", "Inventory_obsolete", "Inventory_lastmovement")
--	WHERE clause : where Inventory_value_gross_EUR" minus get_fi006."Inventory_value_net_EUR > 0 
--	and get_fi006."Inventory_value_gross_CUR" minus get_fi006."Inventory_value_net_CUR" > 0
          WHERE (get_fi006."Inventory_value_gross_EUR" - get_fi006."Inventory_value_net_EUR") > 0::numeric 
		  AND (get_fi006."Inventory_value_gross_CUR" - get_fi006."Inventory_value_net_CUR") > 0::numeric
        UNION ALL
--	retrieve 9 fields of report."get_fi006" and obsolete = 'N' and N-1 = 'N'
         SELECT 
--	stock is not obsolete
			'N'::text AS obsolete,
            'N'::text AS "N-1",
            get_fi006."Site",
            get_fi006."Inventory_location",
            get_fi006."Period_date",
            get_fi006."Inventory_value_gross_EUR",
--	non obsolete value = "Inventory_value_net_EUR"
            get_fi006."Inventory_value_net_EUR" AS "value_EUR",
            get_fi006."Internal_reference",
            get_fi006."ratePerEur",
            get_fi006."Inventory_value_gross_CUR",
--	non obsolete value = "Inventory_value_net_CUR"
            get_fi006."Inventory_value_net_CUR" AS "value_CUR"
           FROM report.get_fi006('2015-01-01'::date::timestamp without time zone, 'now'::text::date::timestamp without time zone, 32) 
		   get_fi006("Period_date", "Site", "Internal_reference", "Inventory_quantity", "Inventory_location", "Inventory_unitprice", "Inventory_value_gross_CUR", "ratePerEur", "Inventory_value_gross_EUR", "Inventory_value_net_CUR", "Inventory_value_net_EUR", "Inventory_obsolete", "Inventory_lastmovement")
        UNION ALL
--	retrieve 9 fields from function report."get_fi006" and obsolete = 'Y' and N-1 = 'N'
         SELECT 
--	stock is obsolete
			'Y'::text AS obsolete,
            'N'::text AS "N-1",
            get_fi006."Site",
            get_fi006."Inventory_location",
            get_fi006."Period_date",
            get_fi006."Inventory_value_gross_EUR",
--	obsolete value = "Inventory_value_gross_EUR" minus get_fi006."Inventory_value_net_EUR"
            get_fi006."Inventory_value_gross_EUR" - get_fi006."Inventory_value_net_EUR" AS "value_EUR",
            get_fi006."Internal_reference",
            get_fi006."ratePerEur",
            get_fi006."Inventory_value_gross_CUR",
--	obsolete value = "Inventory_value_gross_CUR" minus get_fi006."Inventory_value_net_CUR"
            get_fi006."Inventory_value_gross_CUR" - get_fi006."Inventory_value_net_CUR" AS "value_CUR"
           FROM report.get_fi006('2015-01-01'::date::timestamp without time zone, 'now'::text::date::timestamp without time zone, 32) 
		   get_fi006("Period_date", "Site", "Internal_reference", "Inventory_quantity", "Inventory_location", "Inventory_unitprice", "Inventory_value_gross_CUR", "ratePerEur", "Inventory_value_gross_EUR", "Inventory_value_net_CUR", "Inventory_value_net_EUR", "Inventory_obsolete", "Inventory_lastmovement")
--	WHERE clause : retrieve records where "Inventory_value_gross_EUR" minus get_fi006."Inventory_value_net_EUR > 0 
--					and get_fi006."Inventory_value_gross_CUR" minus get_fi006."Inventory_value_net_CUR" > 0
		  WHERE (get_fi006."Inventory_value_gross_EUR" - get_fi006."Inventory_value_net_EUR") > 0::numeric 
		  AND (get_fi006."Inventory_value_gross_CUR" - get_fi006."Inventory_value_net_CUR") > 0::numeric
        UNION ALL
--	retrieve 9 fields from function report."get_fi006" as well as obsolete = 'N' and N-1 = 'Exchange'
         SELECT 
--	stock is not obsolete
		    'N'::text AS obsolete,
            'Exchange'::text AS "N-1",
            get_fi006."Site",
            get_fi006."Inventory_location",
            get_fi006."Period_date",
            get_fi006."Inventory_value_gross_EUR",
--	non obsolete value = "Inventory_value_net_EUR"
            get_fi006."Inventory_value_net_EUR" AS "value_EUR",
            get_fi006."Internal_reference",
            get_fi006."ratePerEur",
            get_fi006."Inventory_value_gross_CUR",
--	non obsolete value = "Inventory_value_gross_CUR"
            get_fi006."Inventory_value_net_CUR" AS "value_CUR"
           FROM report.get_fi006('2015-01-01'::date::timestamp without time zone, 'now'::text::date::timestamp without time zone, 32) 
		   get_fi006("Period_date", "Site", "Internal_reference", "Inventory_quantity", "Inventory_location", "Inventory_unitprice", "Inventory_value_gross_CUR", "ratePerEur", "Inventory_value_gross_EUR", "Inventory_value_net_CUR", "Inventory_value_net_EUR", "Inventory_obsolete", "Inventory_lastmovement")
        UNION ALL
--	retrieve 9 fields from function report.get_fi006 and obsolete = 'Y' and N-1 = 'Exchange'
         SELECT 
--	le stock est obsolete
		    'Y'::text AS obsolete,
            'Exchange'::text AS "N-1",
            get_fi006."Site",
            get_fi006."Inventory_location",
            get_fi006."Period_date",
            get_fi006."Inventory_value_gross_EUR",
--	obsolete value = "Inventory_value_gross_EUR" minus get_fi006."Inventory_value_net_EUR"
            get_fi006."Inventory_value_gross_EUR" - get_fi006."Inventory_value_net_EUR" AS "value_EUR",
            get_fi006."Internal_reference",
            get_fi006."ratePerEur",
            get_fi006."Inventory_value_gross_CUR",
--	obsolete value = get_fi006."Inventory_value_gross_CUR" minus get_fi006."Inventory_value_net_CUR"
            get_fi006."Inventory_value_gross_CUR" - get_fi006."Inventory_value_net_CUR" AS "value_CUR"
           FROM report.get_fi006('2015-01-01'::date::timestamp without time zone, 'now'::text::date::timestamp without time zone, 32) 
		   get_fi006("Period_date", "Site", "Internal_reference", "Inventory_quantity", "Inventory_location", "Inventory_unitprice", "Inventory_value_gross_CUR", "ratePerEur", "Inventory_value_gross_EUR", "Inventory_value_net_CUR", "Inventory_value_net_EUR", "Inventory_obsolete", "Inventory_lastmovement")
--	WHERE clause : retrieve rows where Inventory_value_gross_EUR" minus get_fi006."Inventory_value_net_EUR > 0 
--	and get_fi006."Inventory_value_gross_CUR" minus get_fi006."Inventory_value_net_CUR" > 0
		  WHERE (get_fi006."Inventory_value_gross_EUR" - get_fi006."Inventory_value_net_EUR") > 0::numeric 
		  AND (get_fi006."Inventory_value_gross_CUR" - get_fi006."Inventory_value_net_CUR") > 0::numeric
), 
--	2nd CTE : axis_reference
--	retrieve 3 fields from Axis_Reference 
axis_reference AS 
(
         SELECT "Axis_Reference"."Sc_inventory_type",
            "Axis_Reference"."Site",
            "Axis_Reference"."Reference_internal"
           FROM report."Axis_Reference"
--	condition : recupère uniquement les enregistrements ou le Site de Axis_Reference est égal à celle de la première sous requête inventory
--	ainsi que la Reference_internal de Axis_Reference est égal à l'Internal_reference de la première sous requête inventory
          WHERE (("Axis_Reference"."Site"::text, "Axis_Reference"."Reference_internal"::text) IN ( SELECT inventory_1."Site",
                    inventory_1."Internal_reference"
                   FROM inventory inventory_1))
)
--	retrieve 8 fields from CTE, "inventory" and one field, "axis_reference"
 SELECT inventory."Site",
    inventory."Inventory_location",
    inventory."Period_date",
    inventory."value_EUR",
    inventory."N-1",
    inventory.obsolete,
    axis_reference."Sc_inventory_type",
    inventory."ratePerEur",
    inventory."value_CUR"
   FROM inventory
--	JOIN
     JOIN axis_reference ON inventory."Site"::text = axis_reference."Site"::text AND inventory."Internal_reference"::text = axis_reference."Reference_internal"::text;

ALTER TABLE tableau."FI-006_Inventory3"
  OWNER TO avocarbon;
COMMENT ON VIEW tableau."FI-006_Inventory3"
  IS 'Get Obsolete and non obsolete values, make 3 copies to be able to make a waterfall graph and table';
