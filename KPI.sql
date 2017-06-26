WITH 
--recupère l'union de 8 requêtes dans la sous requête Def_Serie_Seized
Def_Serie_Seized AS (
--pour chaque Site : dans kpi."Def_Serie" il y a un champ pour chaque Site, la valeur peut être null, un '-' ou le nom de celui qui saisie.
-- dans kpi."Def_Serie" il y a également un champ kpiOutput avec comme valeurs A, AT, ATS ou null
--on recupère alors dans un champ Site si la valeur n'est pas null ou un '-' le nom du Site.
--condition : le champ du Site doit être différent de null, '-' et kpiOutput ne doit pas être null
select "serieID", "serieName", "Poitiers" as "Seizer", CASE when "Poitiers" <> '' and "Poitiers" <> '-' Then 'Poitiers' end as Site from kpi."Def_Serie" where "Poitiers" <> '' and "Poitiers" <> '-' and "kpiOutput" <> ''
UNION
select "serieID", "serieName", "Tunisia" as "Seizer", CASE when "Tunisia" <> '' and "Tunisia" <> '-' Then 'Tunisia' end as Site from kpi."Def_Serie" where "Tunisia" <> '' and "Tunisia" <> '-' and "kpiOutput" <> ''
UNION
select "serieID", "serieName", "Germany" as "Seizer", CASE when "Germany" <> '' and "Germany" <> '-' Then 'Germany' end as Site from kpi."Def_Serie" where "Germany" <> '' and "Germany" <> '-' and "kpiOutput" <> ''
UNION
select "serieID", "serieName", "India" as "Seizer", CASE when "India" <> '' and "India" <> '-' Then 'India' end as Site from kpi."Def_Serie" where "India" <> '' and "India" <> '-' and "kpiOutput" <> ''
UNION
select "serieID", "serieName", "Mexico" as "Seizer", CASE when "Mexico" <> '' and "Mexico" <> '-' Then 'Mexico' end as Site from kpi."Def_Serie" where "Mexico" <> '' and "Mexico" <> '-' and "kpiOutput" <> ''
UNION
select "serieID", "serieName", "Korea" as "Seizer", CASE when "Korea" <> '' and "Korea" <> '-' Then 'Korea' end as Site from kpi."Def_Serie" where "Korea" <> '' and "Korea" <> '-' and "kpiOutput" <> ''
UNION
select "serieID", "serieName", "Kunshan" as "Seizer", CASE when "Kunshan" <> '' and "Kunshan" <> '-' Then 'Kunshan' end as Site from kpi."Def_Serie" where "Kunshan" <> '' and "Kunshan" <> '-' and "kpiOutput" <> ''
UNION
select "serieID", "serieName", "Tianjin" as "Seizer", CASE when "Tianjin" <> '' and "Tianjin" <> '-' Then 'Tianjin' end as Site from kpi."Def_Serie" where "Tianjin" <> '' and "Tianjin" <> '-' and "kpiOutput" <> ''),
--recupère l'ensemble des champs de kpi."Dat_Serie_Tableau" ou inputValue n'est pas null, inputDate est inférieur à la date du dernier dimanche et entityName n'est pas égal à 'AVOCarbon'
Dat_Serie_Tableau AS ( 
select * from kpi."Dat_Serie_Tableau" where "inputValue" is not null  and "inputDate" < 
CASE  
--recupère le dernier dimanche (exemple Lundi 26 juin 2017 renvoie Dimanche 25 juin 2017)
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'monday' then current_date - 1 
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'tuesday' then current_date - 2
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'wednesday' then current_date - 3
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'thursday' then current_date - 4
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'friday' then current_date - 5
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'saturday' then current_date - 6
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'sunday' then current_date 
end   
and "entityName" <> 'AVOCarbon'
),
--recupère l'ensemble des champs de kpi."Dat_Serie_Tableau" ou inputValue n'est pas null, inputDate est égal à la date du dernier dimanche et entityName n'est pas égal à 'AVOCarbon'
Dat_Serie_Tableau2 AS ( 
select * from kpi."Dat_Serie_Tableau" where "inputValue" is not null  and "inputDate" = 
CASE  
--recupère le dernier dimanche (exemple Lundi 26 juin 2017 renvoie Dimanche 25 juin 2017)
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'monday' then current_date - 1 
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'tuesday' then current_date - 2
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'wednesday' then current_date - 3
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'thursday' then current_date - 4
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'friday' then current_date - 5
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'saturday' then current_date - 6
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'sunday' then current_date 
end  
 and "entityName" <> 'AVOCarbon'
),
--recupère l'ensemble des champs de kpi."Dat_Serie_Tableau" ou inputValue n'est pas null, inputDate est égal à la date du dimanche de la semaine précedente et entityName n'est pas égal à 'AVOCarbon'
Dat_Serie_Tableau3 AS (
select * from kpi."Dat_Serie_Tableau" where "inputValue" is not null  and "inputDate" =
CASE  
--recupère le dimanche de la semaine précedente (exemple Lundi 26 juin 2017 renvoie Dimanche 18 juin 2017)
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'monday' then current_date - 8 
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'tuesday' then current_date - 9
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'wednesday' then current_date - 10
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'thursday' then current_date - 11
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'friday' then current_date - 12
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'saturday' then current_date - 13
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'sunday' then current_date -7
end   
and "entityName" <> 'AVOCarbon'
)
--recupère 8 champs de la sous requête Def_Serie_Seized et de la sous requête Dat_Serie_Tableau
select 
Def_Serie_Seized."serieID",
Dat_Serie_Tableau ."inputWeek",
--recupère si inputDate de Dat_Serie_Tableau est null la dernier dimanche exemple Lundi 26 juin 2017 renvoie Dimanche 25 juin 2017), sinon la valeur de inputDate
CASE WHEN Dat_Serie_Tableau ."inputDate" is null then CASE  
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'monday' then current_date - 1 
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'tuesday' then current_date - 2
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'wednesday' then current_date - 3
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'thursday' then current_date - 4
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'friday' then current_date - 5
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'saturday' then current_date - 6
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'sunday' then current_date 
end   ELSE Dat_Serie_Tableau ."inputDate" end,
Def_Serie_Seized."serieName",
Def_Serie_Seized.Site,
Dat_Serie_Tableau ."inputValue",
--stock dans seized_or_not 0 si serieID de Dat_Serie_Tableau est null, sinon 1
CASE WHEN Dat_Serie_Tableau."serieID" IS NULL THEN 0 ELSE 1 END AS seized_or_not,
--stock dans Should_be_seized 1 si serieID de Dat_Serie_Tableau est null, sinon 0
CASE WHEN Dat_Serie_Tableau."serieID" IS NULL THEN 1 ELSE 1 END AS Should_be_seized
 from Def_Serie_Seized 
--jointure de la sous requête Def_Serie_Seized et de la sous requête Dat_Serie_Tableau sur serieID, Site de Def_Serie_Seized est égal à l'entityName de Dat_serie_Tableau et typeID = 1 ou null
left join Dat_Serie_Tableau  on Def_Serie_Seized ."serieID" = Dat_Serie_Tableau ."serieID" AND Def_Serie_Seized.Site = Dat_serie_Tableau."entityName" where "typeID" = 1 or "typeID" is null
UNION
--recupère 8 champs de la sous requête Def_Serie_Seized et de la sous requête Dat_Serie_Tableau2
select 
Def_Serie_Seized."serieID",
Dat_Serie_Tableau2 ."inputWeek",
--recupère si inputDate de Dat_Serie_Tableau est null la dernier dimanche exemple Lundi 26 juin 2017 renvoie Dimanche 25 juin 2017), sinon la valeur de inputDate
CASE WHEN Dat_Serie_Tableau2 ."inputDate" is null then 
CASE  
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'monday' then current_date - 1 
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'tuesday' then current_date - 2
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'wednesday' then current_date - 3
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'thursday' then current_date - 4
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'friday' then current_date - 5
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'saturday' then current_date - 6
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'sunday' then current_date 
end   ELSE Dat_Serie_Tableau2 ."inputDate" end,
Def_Serie_Seized."serieName",
Def_Serie_Seized.Site,
Dat_Serie_Tableau2 ."inputValue",
--stock dans seized_or_not 0 si serieID de Dat_Serie_Tableau est null, sinon 1
CASE WHEN Dat_Serie_Tableau2."serieID" IS NULL THEN 0 ELSE 1 END AS seized_or_not,
--stock dans Should_be_seized 1 si serieID de Dat_Serie_Tableau est null, sinon 0
CASE WHEN Dat_Serie_Tableau2."serieID" IS NULL THEN 1 ELSE 1 END AS Should_be_seized
 from Def_Serie_Seized 
--jointure de la sous requête Def_Serie_Seized et de la sous requête Dat_Serie_Tableau2 sur serieID, Site de Def_Serie_Seized est égal à l'entityName de Dat_serie_Tableau2 et typeID = 1 ou null
left join Dat_Serie_Tableau2  on Def_Serie_Seized ."serieID" = Dat_Serie_Tableau2 ."serieID" AND Def_Serie_Seized.Site = Dat_serie_Tableau2."entityName" where "typeID" = 1 or "typeID" is null
UNION 
--recupère 8 champs de la sous requête Def_Serie_Seized et de la sous requête Dat_Serie_Tableau3
select 
Def_Serie_Seized."serieID",
Dat_Serie_Tableau3 ."inputWeek",
--recupère si inputDate de Dat_Serie_Tableau est null le dimanche de la semaine précedente (exemple Lundi 26 juin 2017 renvoie Dimanche 18 juin 2017), sinon la valeur de inputDate
CASE WHEN Dat_Serie_Tableau3 ."inputDate" is null then 
CASE  
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'monday' then current_date - 8
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'tuesday' then current_date - 9
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'wednesday' then current_date - 10
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'thursday' then current_date - 11
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'friday' then current_date - 12
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'saturday' then current_date - 13
WHEN TRIM(TRAILING FROM to_char(current_date, 'day')) = 'sunday' then current_date -7
end    ELSE Dat_Serie_Tableau3 ."inputDate" end,
Def_Serie_Seized."serieName",
Def_Serie_Seized.Site,
Dat_Serie_Tableau3 ."inputValue",
--stock dans seized_or_not 0 si serieID de Dat_Serie_Tableau est null, sinon 1
CASE WHEN Dat_Serie_Tableau3."serieID" IS NULL THEN 0 ELSE 1 END AS seized_or_not,
--stock dans Should_be_seized 1 si serieID de Dat_Serie_Tableau est null, sinon 0
CASE WHEN Dat_Serie_Tableau3."serieID" IS NULL THEN 1 ELSE 1 END AS Should_be_seized
 from Def_Serie_Seized 
 --jointure de la sous requête Def_Serie_Seized et de la sous requête Dat_Serie_Tableau3 sur serieID, Site de Def_Serie_Seized est égal à l'entityName de Dat_serie_Tableau3 et typeID = 1 ou null
left join Dat_Serie_Tableau3  on Def_Serie_Seized ."serieID" = Dat_Serie_Tableau3 ."serieID" AND Def_Serie_Seized.Site = Dat_serie_Tableau3."entityName" where "typeID" = 1 or "typeID" is null
--ordonnée par serieID, inputDate, site
order by "serieID","inputDate","site"
