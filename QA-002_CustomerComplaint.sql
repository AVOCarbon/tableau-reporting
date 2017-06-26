-- View: tableau."QA-002_CustomerComplaint"

-- DROP VIEW tableau."QA-002_CustomerComplaint";

--Crée la vue tableau."QA-002_CustomerComplaint"
CREATE OR REPLACE VIEW tableau."QA-002_CustomerComplaint" AS 
--recupère 19 champs de la fonction report.get_qa002 dans la sous requête complaint 
 WITH complaint AS (
         SELECT get_qa002."Period_date",
            get_qa002."Site",
            get_qa002."Customer_code",
            get_qa002."Internal_reference",
            get_qa002."Internal_claim_ID",
            get_qa002."Customer_claim_ID",
            get_qa002."Qty_defective_for_PPM",
            get_qa002."Claim_status",
            get_qa002."Claim_type",
            get_qa002."Recurring",
            get_qa002."Date_of_claim",
            get_qa002."Date_of_1st_reply",
            get_qa002."Date_of_action_plan",
            get_qa002."Date_of_closing",
            get_qa002."Days_to_reply",
            get_qa002."Days_to_action_plan",
            get_qa002."Days_to_closing",
            get_qa002."CNQ_in_currency",
			    --stock dans "Not closed" 1 si Date_of_closing de la get_qa002 est null, sinon 0
                CASE
                    WHEN get_qa002."Date_of_closing" IS NULL THEN 1
                    ELSE 0
                END AS "Not closed"
           FROM report.get_qa002('2015-01-01'::date::timestamp without time zone, '2017-04-25'::date::timestamp without time zone, 32) get_qa002("Period_date", "Site", "Customer_code", "Internal_reference", "Internal_claim_ID", "Customer_claim_ID", "Qty_defective_for_PPM", "Claim_status", "Claim_type", "Recurring", "Date_of_claim", "Date_of_1st_reply", "Date_of_action_plan", "Date_of_closing", "Days_to_reply", "Days_to_action_plan", "Days_to_closing", "CNQ_in_currency")
		  --ordonnée par Period_date
          ORDER BY get_qa002."Period_date"
        ), 
--recupère 3 champs de la vue Axis_Customers_Suppliers dans la sous requête customer		
		customer AS (
         SELECT "Axis_Customers_Suppliers"."Site",
            "Axis_Customers_Suppliers"."Customer_code",
            "Axis_Customers_Suppliers"."Customer_name"
           FROM report."Axis_Customers_Suppliers"
		  --condition : recupère uniquement les enregistrements ou le Site de la Axis_Customers_Suppliers est égal à celle de la première sous requête complaint ainsi que le Customer_code
          WHERE (("Axis_Customers_Suppliers"."Site"::text, "Axis_Customers_Suppliers"."Customer_code"::text) IN ( SELECT complaint_1."Site",
                    complaint_1."Customer_code"
                   FROM complaint complaint_1))
        )
--recupère 19 champs de la sous requête complaint et 1 champ de la sous requête customer
 SELECT complaint."Period_date",
    complaint."Site",
    complaint."Customer_code",
    complaint."Internal_reference",
    complaint."Internal_claim_ID",
    complaint."Customer_claim_ID",
    complaint."Qty_defective_for_PPM",
    complaint."Claim_status",
    complaint."Claim_type",
    complaint."Recurring",
    complaint."Date_of_claim",
    complaint."Date_of_1st_reply",
    complaint."Date_of_action_plan",
    complaint."Date_of_closing",
    complaint."Days_to_reply",
    complaint."Days_to_action_plan",
    complaint."Days_to_closing",
    complaint."CNQ_in_currency",
    complaint."Not closed",
    customer."Customer_name"
   FROM complaint
     --jointure des sous requêtes
     LEFT JOIN customer ON complaint."Site"::text = customer."Site"::text AND complaint."Customer_code"::text = customer."Customer_code"::text;

ALTER TABLE tableau."QA-002_CustomerComplaint"
  OWNER TO avocarbon;
COMMENT ON VIEW tableau."QA-002_CustomerComplaint"
  IS 'Get all from Complaint, Customer_name from Customer. Join Customer on Complaint';
