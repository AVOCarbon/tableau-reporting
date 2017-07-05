-- View: tableau."FI-006_Inventory"

-- DROP VIEW tableau."FI-006_Inventory";

--Crée la vue tableau."FI-006_Inventory"
CREATE OR REPLACE VIEW tableau."FI-006_Inventory" AS 
--recupère l'union des 2 première requêtes
 WITH inventory AS (
		 --recupère 13 champs de la fonction report.get_fi006 ainsi que l'obsolete = 'N'
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
           FROM report.get_fi006('2015-01-01'::date::timestamp without time zone, 'now'::text::date::timestamp without time zone, 32) get_fi006("Period_date", "Site", "Internal_reference", "Inventory_quantity", "Inventory_location", "Inventory_unitprice", "Inventory_value_gross_CUR", "Inventory_value_gross_EUR", "Inventory_value_net_CUR", "ratePerEur", "Inventory_value_net_EUR", "Inventory_obsolete", "Inventory_lastmovement")
        UNION ALL
		--recupère 13 champs de la fonction report.get_fi006 ainsi que l'obsolete = 'Y'
         SELECT 'Y'::text AS obsolete,
		    --recupère la valeur obsolete l'inventory_value
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
           FROM report.get_fi006('2015-01-01'::date::timestamp without time zone, 'now'::text::date::timestamp without time zone, 32) get_fi006("Period_date", "Site", "Internal_reference", "Inventory_quantity", "Inventory_location", "Inventory_unitprice", "Inventory_value_gross_CUR", "Inventory_value_gross_EUR", "Inventory_value_net_CUR", "ratePerEur", "Inventory_value_net_EUR", "Inventory_obsolete", "Inventory_lastmovement")
	--condition : la valeur de la Inventory_value_gross_EUR - Inventory_value_net_EUR doit être supérieur à 0
          WHERE (get_fi006."Inventory_value_gross_EUR" - get_fi006."Inventory_value_net_EUR") > 0::numeric
        ), 
       --recupère 3 champs de la vue Axis_Reference dans la sous requête axis_reference		
		axis_reference AS (
         SELECT "Axis_Reference"."Sc_inventory_type",
            "Axis_Reference"."Site",
            "Axis_Reference"."Reference_internal"
           FROM report."Axis_Reference"
	--condition : recupère uniquement les enregistrements ou le Site de la Axis_Reference 
	--est égal à celle de la première sous requête inventory
	--ainsi que la Reference_internal de la Axis_Reference est égal à la Internal_reference 
	--de la première sous requête inventory
          WHERE (("Axis_Reference"."Site"::text, "Axis_Reference"."Reference_internal"::text) IN ( SELECT inventory_1."Site",
                    inventory_1."Internal_reference"
                   FROM inventory inventory_1))
        )
--recupère 14 champs de la sous requête inventory et 1 champ de la sous requête axis_reference
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
     --jointure des sous requêtes
     JOIN axis_reference ON inventory."Site"::text = axis_reference."Site"::text AND inventory."Internal_reference"::text = axis_reference."Reference_internal"::text;

ALTER TABLE tableau."FI-006_Inventory"
  OWNER TO avocarbon;
COMMENT ON VIEW tableau."FI-006_Inventory"
  IS 'Create as obsolete, value_EUR from get_fi006 and get all. Get Sc_inventory_type from Axis_Reference';
