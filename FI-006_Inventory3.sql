-- View: tableau."FI-006_Inventory3"

-- DROP VIEW tableau."FI-006_Inventory3";

--Crée la vue tableau."FI-006_Inventory3"
CREATE OR REPLACE VIEW tableau."FI-006_Inventory3" AS 
--recupère l'union des 6 requêtes ci-dessous dans la sous requête inventory
 WITH inventory AS (
		  --recupère 9 champs de la fonction report.get_fi006 ainsi que l'obsolete = 'N' et N-1 = 'Y'
         SELECT 
			--le stock n'est pas obsolete
			'N'::text AS obsolete,
			--la première date entrée en paramètre sous Tableau
            'Y'::text AS "N-1",
            get_fi006."Site",
            get_fi006."Inventory_location",
            get_fi006."Period_date",
            get_fi006."Inventory_value_gross_EUR",
			--valeur non obsolete
            get_fi006."Inventory_value_net_EUR" AS "value_EUR",
            get_fi006."Internal_reference",
            get_fi006."ratePerEur",
            get_fi006."Inventory_value_gross_CUR",
			--valeur non obsolete
            get_fi006."Inventory_value_net_CUR" AS "value_CUR"
           FROM report.get_fi006('2015-01-01'::date::timestamp without time zone, 'now'::text::date::timestamp without time zone, 32) get_fi006("Period_date", "Site", "Internal_reference", "Inventory_quantity", "Inventory_location", "Inventory_unitprice", "Inventory_value_gross_CUR", "ratePerEur", "Inventory_value_gross_EUR", "Inventory_value_net_CUR", "Inventory_value_net_EUR", "Inventory_obsolete", "Inventory_lastmovement")
        UNION ALL
		 --recupère 9 champs de la fonction report.get_fi006 ainsi que l'obsolete = 'Y' et N-1 = 'Y'
         SELECT 
			--le stock est obsolete
			'Y'::text AS obsolete,
			--la première date entrée en paramètre sous Tableau
            'Y'::text AS "N-1",
            get_fi006."Site",
            get_fi006."Inventory_location",
            get_fi006."Period_date",
            get_fi006."Inventory_value_gross_EUR",
			--valeur obsolete 
            get_fi006."Inventory_value_gross_EUR" - get_fi006."Inventory_value_net_EUR" AS "value_EUR",
            get_fi006."Internal_reference",
            get_fi006."ratePerEur",
            get_fi006."Inventory_value_gross_CUR",
			--valeur obsolete
            get_fi006."Inventory_value_gross_CUR" - get_fi006."Inventory_value_net_CUR" AS "value_CUR"
           FROM report.get_fi006('2015-01-01'::date::timestamp without time zone, 'now'::text::date::timestamp without time zone, 32) get_fi006("Period_date", "Site", "Internal_reference", "Inventory_quantity", "Inventory_location", "Inventory_unitprice", "Inventory_value_gross_CUR", "ratePerEur", "Inventory_value_gross_EUR", "Inventory_value_net_CUR", "Inventory_value_net_EUR", "Inventory_obsolete", "Inventory_lastmovement")
		  --condition : recupère uniquement les enregistrements ou Inventory_value_gross_EUR" - get_fi006."Inventory_value_net_EUR est supérieur à 0 
		  --et get_fi006."Inventory_value_gross_CUR" - get_fi006."Inventory_value_net_CUR" est supérieur à 0
          WHERE (get_fi006."Inventory_value_gross_EUR" - get_fi006."Inventory_value_net_EUR") > 0::numeric AND (get_fi006."Inventory_value_gross_CUR" - get_fi006."Inventory_value_net_CUR") > 0::numeric
        UNION ALL
		 --recupère 9 champs de la fonction report.get_fi006 ainsi que l'obsolete = 'N' et N-1 = 'N'
         SELECT 
			--le stock n'est pas obsolete
			'N'::text AS obsolete,
			--la deuxième date entrée en paramètre sous Tableau
            'N'::text AS "N-1",
            get_fi006."Site",
            get_fi006."Inventory_location",
            get_fi006."Period_date",
            get_fi006."Inventory_value_gross_EUR",
			--valeur non obsolete
            get_fi006."Inventory_value_net_EUR" AS "value_EUR",
            get_fi006."Internal_reference",
            get_fi006."ratePerEur",
            get_fi006."Inventory_value_gross_CUR",
			--valeur non obsolete
            get_fi006."Inventory_value_net_CUR" AS "value_CUR"
           FROM report.get_fi006('2015-01-01'::date::timestamp without time zone, 'now'::text::date::timestamp without time zone, 32) get_fi006("Period_date", "Site", "Internal_reference", "Inventory_quantity", "Inventory_location", "Inventory_unitprice", "Inventory_value_gross_CUR", "ratePerEur", "Inventory_value_gross_EUR", "Inventory_value_net_CUR", "Inventory_value_net_EUR", "Inventory_obsolete", "Inventory_lastmovement")
        UNION ALL
		 --recupère 9 champs de la fonction report.get_fi006 ainsi que l'obsolete = 'Y' et N-1 = 'N'
         SELECT 
		    --le stock est obsolete
			'Y'::text AS obsolete,
			--la deuxième date entrée en paramètre sous Tableau
            'N'::text AS "N-1",
            get_fi006."Site",
            get_fi006."Inventory_location",
            get_fi006."Period_date",
            get_fi006."Inventory_value_gross_EUR",
			--valeur obsolete 
            get_fi006."Inventory_value_gross_EUR" - get_fi006."Inventory_value_net_EUR" AS "value_EUR",
            get_fi006."Internal_reference",
            get_fi006."ratePerEur",
            get_fi006."Inventory_value_gross_CUR",
			--valeur obsolete 
            get_fi006."Inventory_value_gross_CUR" - get_fi006."Inventory_value_net_CUR" AS "value_CUR"
           FROM report.get_fi006('2015-01-01'::date::timestamp without time zone, 'now'::text::date::timestamp without time zone, 32) get_fi006("Period_date", "Site", "Internal_reference", "Inventory_quantity", "Inventory_location", "Inventory_unitprice", "Inventory_value_gross_CUR", "ratePerEur", "Inventory_value_gross_EUR", "Inventory_value_net_CUR", "Inventory_value_net_EUR", "Inventory_obsolete", "Inventory_lastmovement")
          --condition : recupère uniquement les enregistrements ou Inventory_value_gross_EUR" - get_fi006."Inventory_value_net_EUR est supérieur à 0 
		  --et get_fi006."Inventory_value_gross_CUR" - get_fi006."Inventory_value_net_CUR" est supérieur à 0
		  WHERE (get_fi006."Inventory_value_gross_EUR" - get_fi006."Inventory_value_net_EUR") > 0::numeric AND (get_fi006."Inventory_value_gross_CUR" - get_fi006."Inventory_value_net_CUR") > 0::numeric
        UNION ALL
		 --recupère 9 champs de la fonction report.get_fi006 ainsi que l'obsolete = 'N' et N-1 = 'Exchange'
         SELECT 
		    --le stock n'est pas obsolete
		    'N'::text AS obsolete,
			--utilisée pour calculer l'exchange
            'Exchange'::text AS "N-1",
            get_fi006."Site",
            get_fi006."Inventory_location",
            get_fi006."Period_date",
            get_fi006."Inventory_value_gross_EUR",
			--valeur non obsolete
            get_fi006."Inventory_value_net_EUR" AS "value_EUR",
            get_fi006."Internal_reference",
            get_fi006."ratePerEur",
            get_fi006."Inventory_value_gross_CUR",
			--valeur non obsolete
            get_fi006."Inventory_value_net_CUR" AS "value_CUR"
           FROM report.get_fi006('2015-01-01'::date::timestamp without time zone, 'now'::text::date::timestamp without time zone, 32) get_fi006("Period_date", "Site", "Internal_reference", "Inventory_quantity", "Inventory_location", "Inventory_unitprice", "Inventory_value_gross_CUR", "ratePerEur", "Inventory_value_gross_EUR", "Inventory_value_net_CUR", "Inventory_value_net_EUR", "Inventory_obsolete", "Inventory_lastmovement")
        UNION ALL
		 --recupère 9 champs de la fonction report.get_fi006 ainsi que l'obsolete = 'Y' et N-1 = 'Exchange'
         SELECT 
		    --le stock est obsolete
		    'Y'::text AS obsolete,
			--utilisée pour calculer l'exchange
            'Exchange'::text AS "N-1",
            get_fi006."Site",
            get_fi006."Inventory_location",
            get_fi006."Period_date",
            get_fi006."Inventory_value_gross_EUR",
			--valeur obsolete 
            get_fi006."Inventory_value_gross_EUR" - get_fi006."Inventory_value_net_EUR" AS "value_EUR",
            get_fi006."Internal_reference",
            get_fi006."ratePerEur",
            get_fi006."Inventory_value_gross_CUR",
			--valeur obsolete 
            get_fi006."Inventory_value_gross_CUR" - get_fi006."Inventory_value_net_CUR" AS "value_CUR"
           FROM report.get_fi006('2015-01-01'::date::timestamp without time zone, 'now'::text::date::timestamp without time zone, 32) get_fi006("Period_date", "Site", "Internal_reference", "Inventory_quantity", "Inventory_location", "Inventory_unitprice", "Inventory_value_gross_CUR", "ratePerEur", "Inventory_value_gross_EUR", "Inventory_value_net_CUR", "Inventory_value_net_EUR", "Inventory_obsolete", "Inventory_lastmovement")
          --condition : recupère uniquement les enregistrements ou Inventory_value_gross_EUR" - get_fi006."Inventory_value_net_EUR est supérieur à 0 
		  --et get_fi006."Inventory_value_gross_CUR" - get_fi006."Inventory_value_net_CUR" est supérieur à 0
		  WHERE (get_fi006."Inventory_value_gross_EUR" - get_fi006."Inventory_value_net_EUR") > 0::numeric AND (get_fi006."Inventory_value_gross_CUR" - get_fi006."Inventory_value_net_CUR") > 0::numeric
        ), 
		--recupère 3 champs de la vue Axis_Reference dans la sous requête axis_reference
		axis_reference AS (
         SELECT "Axis_Reference"."Sc_inventory_type",
            "Axis_Reference"."Site",
            "Axis_Reference"."Reference_internal"
           FROM report."Axis_Reference"
		  --condition : recupère uniquement les enregistrements ou le Site de Axis_Reference est égal à celle de la première sous requête inventory
		  -- ainsi que la Reference_internal de Axis_Reference est égal à l'Internal_reference de la première sous requête inventory
          WHERE (("Axis_Reference"."Site"::text, "Axis_Reference"."Reference_internal"::text) IN ( SELECT inventory_1."Site",
                    inventory_1."Internal_reference"
                   FROM inventory inventory_1))
        )
--recupère 8 champs de la sous requête inventory ainsi que 1 champ de la sous requête axis_reference
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
     --jointure des sous requêtes
     JOIN axis_reference ON inventory."Site"::text = axis_reference."Site"::text AND inventory."Internal_reference"::text = axis_reference."Reference_internal"::text;

ALTER TABLE tableau."FI-006_Inventory3"
  OWNER TO avocarbon;
COMMENT ON VIEW tableau."FI-006_Inventory3"
  IS 'Get Obsolete and non obsolete values, make 3 copies to be able to make a waterfall graph and table';
