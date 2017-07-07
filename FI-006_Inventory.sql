--	View: tableau."FI-006_Inventory"

--	DROP VIEW tableau."FI-006_Inventory";

--	Crate view tableau."FI-006_Inventory"

CREATE OR REPLACE VIEW tableau."FI-006_Inventory" AS 
--	1st CTE: "inventory"
 WITH inventory AS 
 (
--	retrieve 13 fields from function, report."get_fi006" 
--	and create one static field, "obsolete" with 'N' in the column
         SELECT 'N'::text AS obsolete,
            get_fi006."Inventory_value_net_EUR" AS "value_EUR",
            get_fi006."Period_date",
            get_fi006."Site",
            get_fi006."Internal_reference",
            get_fi006."Inventory_quantity",
            get_fi006."Inventory_location",
            get_fi006."Inventory_unitprice",
            get_fi006."Inventory_value_gross_CUR",
            get_fi006."Inventory_value_gross_EUR",
            get_fi006."Inventory_value_net_CUR",
            get_fi006."Inventory_value_net_EUR",
            get_fi006."Inventory_obsolete",
            get_fi006."Inventory_lastmovement"
           FROM report.get_fi006('2015-01-01'::date::timestamp without time zone, 'now'::text::date::timestamp without time zone, 32) 
		   get_fi006("Period_date", 
					"Site", 
					"Internal_reference", 
					"Inventory_quantity", 
					"Inventory_location", 
					"Inventory_unitprice", 
					"Inventory_value_gross_CUR", 
					"Inventory_value_gross_EUR", 
					"Inventory_value_net_CUR", 
					"ratePerEur", 
					"Inventory_value_net_EUR", 
					"Inventory_obsolete", 
					"Inventory_lastmovement")
        UNION ALL
--	retrieve 13 fields from function, report."get_fi006" 
--	and create one static field, "obsolete" with 'Y' in the column
         SELECT 'Y'::text AS obsolete,
--	retrieve the obsolete value e.g "Inventory_value_gross_EUR" minus "Inventory_value_net_EUR"
            get_fi006."Inventory_value_gross_EUR" - get_fi006."Inventory_value_net_EUR" AS "value_EUR",
            get_fi006."Period_date",
            get_fi006."Site",
            get_fi006."Internal_reference",
            get_fi006."Inventory_quantity",
            get_fi006."Inventory_location",
            get_fi006."Inventory_unitprice",
            get_fi006."Inventory_value_gross_CUR",
            get_fi006."Inventory_value_gross_EUR",
            get_fi006."Inventory_value_net_CUR",
            get_fi006."Inventory_value_net_EUR",
            get_fi006."Inventory_obsolete",
            get_fi006."Inventory_lastmovement"
           FROM report.get_fi006('2015-01-01'::date::timestamp without time zone, 'now'::text::date::timestamp without time zone, 32) 
		   get_fi006("Period_date", 
		   "Site", 
		   "Internal_reference", 
		   "Inventory_quantity", 
		   "Inventory_location", 
		   "Inventory_unitprice", 
		   "Inventory_value_gross_CUR", 
		   "Inventory_value_gross_EUR", 
		   "Inventory_value_net_CUR", 
		   "ratePerEur", 
		   "Inventory_value_net_EUR", 
		   "Inventory_obsolete", 
		   "Inventory_lastmovement")
--	WHERE clause : value of "Inventory_value_gross_EUR" minus "Inventory_value_net_EUR" > 0
          WHERE (get_fi006."Inventory_value_gross_EUR" - get_fi006."Inventory_value_net_EUR") > 0::numeric
), 
--	2nd CTE : axis_reference
--	retrieve 3 rows from the view, "Axis_Reference" 		
axis_reference AS 
(
         SELECT "Axis_Reference"."Sc_inventory_type",
            "Axis_Reference"."Site",
            "Axis_Reference"."Reference_internal"
           FROM report."Axis_Reference"
--	WHERE Clause : retrieve rows where "Site" and "Reference_internal" from "Axis_Reference" 
--	is in "Site" and "Internal_reference" from the CTE, "inventory"
          WHERE (("Axis_Reference"."Site"::text, "Axis_Reference"."Reference_internal"::text) IN ( SELECT inventory_1."Site",
                    inventory_1."Internal_reference"
                   FROM inventory inventory_1))
)
--	retrieve 14 fields from the CTE, "inventory" and one field from the CTE, "axis_reference"
 SELECT inventory.obsolete,
    inventory."value_EUR",
    inventory."Period_date",
    inventory."Site",
    inventory."Internal_reference",
    inventory."Inventory_quantity",
    inventory."Inventory_location",
    inventory."Inventory_unitprice",
    inventory."Inventory_value_gross_CUR",
    inventory."Inventory_value_gross_EUR",
    inventory."Inventory_value_net_CUR",
    inventory."Inventory_value_net_EUR",
    inventory."Inventory_obsolete",
    inventory."Inventory_lastmovement",
    axis_reference."Sc_inventory_type"
   FROM inventory
--	join on CTE, "axis_reference" and CTE, "inventory"
     JOIN axis_reference 
	 ON inventory."Site"::text = axis_reference."Site"::text AND inventory."Internal_reference"::text = axis_reference."Reference_internal"::text;

ALTER TABLE tableau."FI-006_Inventory"
  OWNER TO avocarbon;
COMMENT ON VIEW tableau."FI-006_Inventory"
  IS 'Create as obsolete, value_EUR from get_fi006 and get all. Get Sc_inventory_type from Axis_Reference';
