-- View: tableau."L0-001_Receptions"

-- DROP VIEW tableau."L0-001_Receptions";

--Crée la vue tableau."L0-001_Receptions"
CREATE OR REPLACE VIEW tableau."L0-001_Receptions" AS 
--recupère 18 champs de la fonction report.get_lo001 dans la sous requête receptions
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
           FROM report.get_lo001('2015-01-01'::date::timestamp without time zone, 'now'::text::date::timestamp without time zone, 32) get_lo001("Period_date", "Site", "Supplier_code", "Internal_reference", "Shipment_number", "PO_number", "Quantity", "Movement_value_EUR", "Movement_value_CUR", "Reception_price_EUR", "Reception_price_CUR", "Variance_refprice_EUR", "Variance_refprice_CUR", "Variance_value@refprice_EUR", "Variance_value@refprice_CUR", "Purchasing_currency", "Movement_date", "Price_change")
        ), 
--recupère 52 champs de la vue Axis_RefSupplier	dans la sous requête refsupplier
		refsupplier AS (
         SELECT
				--stock dans Supplier2 le Supplier_name de la Axis_RefSupplier si le Supplier_global de la Axis_RefSupplier est égal à '(Other)' ou est null, sinon stock le Supplier_global
                CASE
                    WHEN "Axis_RefSupplier"."Supplier_global"::text = '(Other)'::text OR "Axis_RefSupplier"."Supplier_global"::text = ''::text THEN "Axis_RefSupplier"."Supplier_name"
                    ELSE "Axis_RefSupplier"."Supplier_global"
                END AS "Supplier2",
            "Axis_RefSupplier"."Site",
            "Axis_RefSupplier"."Reference",
            "Axis_RefSupplier"."Reference_internal",
            "Axis_RefSupplier"."Reference_supplier",
            "Axis_RefSupplier"."Reference_description",
            "Axis_RefSupplier"."Reference_workshop",
            "Axis_RefSupplier"."Reference_line",
            "Axis_RefSupplier"."Reference_segment",
            "Axis_RefSupplier"."Reference_purchasingcode",
            "Axis_RefSupplier"."Reference_purchasingfamily",
            "Axis_RefSupplier"."Reference_purchasingsubcode",
            "Axis_RefSupplier"."Reference_purchasingsubname",
            "Axis_RefSupplier"."Reference_interco",
            "Axis_RefSupplier"."Reference_trading",
            "Axis_RefSupplier"."Cogs_rm",
            "Axis_RefSupplier"."Cogs_dl",
            "Axis_RefSupplier"."Cogs_voh",
            "Axis_RefSupplier"."Supplier_global",
            "Axis_RefSupplier"."Supplier_code",
            "Axis_RefSupplier"."Supplier_name",
            "Axis_RefSupplier"."Supplier_Product",
            "Axis_RefSupplier"."Flow_name",
            "Axis_RefSupplier"."Flow_country",
            "Axis_RefSupplier"."Flow_continent",
            "Axis_RefSupplier"."Supplier_account_manager",
            "Axis_RefSupplier"."Supplier_interco",
            "Axis_RefSupplier"."Supplier_incoterm",
            "Axis_RefSupplier"."Supplier_incoterm_location",
            "Axis_RefSupplier"."Supplier_incoterm_via",
            "Axis_RefSupplier"."Supplier_continent",
            "Axis_RefSupplier"."Supplier_country",
            "Axis_RefSupplier"."Supplier_city",
            "Axis_RefSupplier"."Supplier_zipcode",
            "Axis_RefSupplier"."Purchasing_unit",
            "Axis_RefSupplier"."Purchasing_price",
            "Axis_RefSupplier"."Purchasing_currency",
            "Axis_RefSupplier"."Purchasing_payment_term_days",
            "Axis_RefSupplier"."Purchasing_payment_term_type",
            "Axis_RefSupplier"."Purchasing_consigned",
            "Axis_RefSupplier"."Purchasing_grossweight",
            "Axis_RefSupplier"."Purchasing_grosscube",
            "Axis_RefSupplier"."Purchasing_eco_order_qty",
            "Axis_RefSupplier"."Purchasing_pack_order_qty",
            "Axis_RefSupplier"."Purchasing_moq",
            "Axis_RefSupplier"."Purchasing_mov",
            "Axis_RefSupplier"."Purchasing_leadtime_days",
            "Axis_RefSupplier"."Reference_netweight",
            "Axis_RefSupplier"."Sc_storage_unit",
            "Axis_RefSupplier"."Sc_production_unit",
            "Axis_RefSupplier"."Sc_inventory_status",
            "Axis_RefSupplier"."Sc_inventory_price"
           FROM report."Axis_RefSupplier"
		   --condition : récupère uniquement les enregistrements ou le site de la Axis_RefSupplier est égal à celle de la première sous requête receptions ainsi que la reference_internal et le supplier_code
          WHERE (("Axis_RefSupplier"."Site"::text, "Axis_RefSupplier"."Reference_internal"::text, "Axis_RefSupplier"."Supplier_code"::text) IN ( SELECT receptions_1."Site",
                    receptions_1."Internal_reference",
                    receptions_1."Supplier_code"
                   FROM receptions receptions_1))
        )
 SELECT 
 --récupère 18 champs de la sous requête receptions ainsi que 48 champs de la sous requête refsupplier
 receptions."Period_date",
    receptions."Site",
    receptions."Supplier_code",
    receptions."Internal_reference",
    receptions."Shipment_number",
    receptions."PO_number",
    receptions."Quantity",
    receptions."Movement_value_CUR",
    receptions."Movement_value_EUR",
    receptions."Reception_price_EUR",
    receptions."Reception_price_CUR",
    receptions."Variance_refprice_EUR",
    receptions."Variance_refprice_CUR",
    receptions."Variance_value@refprice_EUR",
    receptions."Variance_value@refprice_CUR",
    receptions."Purchasing_currency",
    receptions."Movement_date",
    receptions."Price_change",
    refsupplier."Reference",
    refsupplier."Reference_supplier",
    refsupplier."Reference_description",
    refsupplier."Reference_workshop",
    refsupplier."Reference_line",
    refsupplier."Reference_segment",
    refsupplier."Reference_purchasingcode",
    refsupplier."Reference_purchasingfamily",
    refsupplier."Reference_purchasingsubcode",
    refsupplier."Reference_purchasingsubname",
    refsupplier."Reference_interco",
    refsupplier."Reference_trading",
    refsupplier."Cogs_rm",
    refsupplier."Cogs_dl",
    refsupplier."Cogs_voh",
    refsupplier."Supplier_global",
    refsupplier."Supplier_name",
    refsupplier."Supplier_Product",
    refsupplier."Flow_name",
    refsupplier."Flow_country",
    refsupplier."Flow_continent",
    refsupplier."Supplier_account_manager",
    refsupplier."Supplier_interco",
    refsupplier."Supplier_incoterm",
    refsupplier."Supplier_incoterm_location",
    refsupplier."Supplier_incoterm_via",
    refsupplier."Supplier_continent",
    refsupplier."Supplier_country",
    refsupplier."Supplier_city",
    refsupplier."Supplier_zipcode",
    refsupplier."Purchasing_unit",
    refsupplier."Purchasing_price",
    refsupplier."Purchasing_payment_term_days",
    refsupplier."Purchasing_payment_term_type",
    refsupplier."Purchasing_consigned",
    refsupplier."Purchasing_grossweight",
    refsupplier."Purchasing_grosscube",
    refsupplier."Purchasing_eco_order_qty",
    refsupplier."Purchasing_pack_order_qty",
    refsupplier."Purchasing_moq",
    refsupplier."Purchasing_mov",
    refsupplier."Purchasing_leadtime_days",
    refsupplier."Reference_netweight",
    refsupplier."Sc_storage_unit",
    refsupplier."Sc_production_unit",
    refsupplier."Sc_inventory_status",
    refsupplier."Sc_inventory_price",
    refsupplier."Supplier2"
   FROM receptions
   --jointure des sous requêtes
     LEFT JOIN refsupplier ON receptions."Site"::text = refsupplier."Site"::text AND receptions."Internal_reference"::text = refsupplier."Reference_internal"::text AND receptions."Supplier_code"::text = refsupplier."Supplier_code"::text;

ALTER TABLE tableau."L0-001_Receptions"
  OWNER TO avocarbon;
COMMENT ON VIEW tableau."L0-001_Receptions"
  IS 'Get all from Reception, get all from RefSupplier. Join RefSupplier on Reception';
