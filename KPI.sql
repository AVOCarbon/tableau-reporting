--	recupère l'union de 8 requêtes dans la sous requête Def_Serie_Seized
--	In TABLEAU, the query is called "Plants seized"

WITH 
Def_Serie_Seized AS 
-- First CTE : Def_Serie_Seized
--	For every production site : in the table kpi."Def_Serie", there is a field for every site. 
--	There will be a site for "Poitiers" , "Germany" etc ... 
--	The field can have the following values : 
--	'null' , '-' or the name who fill the report (.e.g "Didier Joseph") 
--	In the table kpi."Def_Serie", there is also a field, "kpiOutput" with 
--  the following values: A, AT, ATS or "null"
--	CASE clause: When "Site" is not empty and different of '-' then we put "Site"s name.
--	WHERE clause : When "Site" is not empty and different of '-' and kpiOutput is not empty
	(
	SELECT "serieID",
		   "serieName",
		   "Poitiers" AS "Seizer",
		   CASE
			   WHEN "Poitiers" <> '' AND "Poitiers" <> '-' 
					THEN 'Poitiers'
		   END AS Site
	   FROM kpi."Def_Serie"
	   WHERE "Poitiers" <> ''
		 AND "Poitiers" <> '-'
		 AND "kpiOutput" <> ''
	UNION 
	SELECT "serieID",
			"serieName",
			"Tunisia" AS "Seizer",
			CASE
				WHEN "Tunisia" <> '' AND "Tunisia" <> '-'
					THEN 'Tunisia'
			END AS Site
	   FROM kpi."Def_Serie"
	   WHERE "Tunisia" <> ''
		 AND "Tunisia" <> '-'
		 AND "kpiOutput" <> ''
	UNION 
	SELECT "serieID",
			"serieName",
			"Germany" AS "Seizer",
			CASE
				WHEN "Germany" <> '' AND "Germany" <> '-'
					 THEN 'Germany'
			END AS Site
	   FROM kpi."Def_Serie"
	   WHERE "Germany" <> ''
		 AND "Germany" <> '-'
		 AND "kpiOutput" <> ''
	UNION 
	SELECT "serieID",
					"serieName",
					"India" AS "Seizer",
					CASE
						WHEN "India" <> ''
							 AND "India" <> '-' THEN 'India'
					END AS Site
	   FROM kpi."Def_Serie"
	   WHERE "India" <> ''
		 AND "India" <> '-'
		 AND "kpiOutput" <> ''
	UNION 
	SELECT "serieID",
					"serieName",
					"Mexico" AS "Seizer",
					CASE
						WHEN "Mexico" <> ''
							 AND "Mexico" <> '-' THEN 'Mexico'
					END AS Site
	   FROM kpi."Def_Serie"
	   WHERE "Mexico" <> ''
		 AND "Mexico" <> '-'
		 AND "kpiOutput" <> ''
	UNION 
	SELECT "serieID",
					"serieName",
					"Korea" AS "Seizer",
					CASE
						WHEN "Korea" <> ''
							 AND "Korea" <> '-' THEN 'Korea'
					END AS Site
	   FROM kpi."Def_Serie"
	   WHERE "Korea" <> ''
		 AND "Korea" <> '-'
		 AND "kpiOutput" <> ''
	UNION 
	SELECT "serieID",
					"serieName",
					"Kunshan" AS "Seizer",
					CASE
						WHEN "Kunshan" <> ''
							 AND "Kunshan" <> '-' THEN 'Kunshan'
					END AS Site
	   FROM kpi."Def_Serie"
	   WHERE "Kunshan" <> ''
		 AND "Kunshan" <> '-'
		 AND "kpiOutput" <> ''
	UNION 
	SELECT "serieID",
					"serieName",
					"Tianjin" AS "Seizer",
					CASE
						WHEN "Tianjin" <> ''
							 AND "Tianjin" <> '-' THEN 'Tianjin'
					END AS Site
	   FROM kpi."Def_Serie"
	   WHERE "Tianjin" <> ''
		 AND "Tianjin" <> '-'
		 AND "kpiOutput" <> ''
	), 
-- 2nd CTE : Dat_Serie_Tableau
--	retrieve all fields from  kpi."Dat_Serie_Tableau" 
--	WHERE Clause : field "inputValue" is not null  
--						 and "inputDate" < date of last Sunday 
--						 example : Monday 26th of June 2017 will send Sunday 25th of June 2017)
--						 and field "entityName" different than 'AVOCarbon'
Dat_Serie_Tableau AS 
	(
	  SELECT *
	   FROM kpi."Dat_Serie_Tableau" 
	   WHERE "inputValue" IS NOT NULL
		 AND "inputDate" < CASE 
							   WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'monday' THEN CURRENT_DATE - 1 
							   WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'tuesday' THEN CURRENT_DATE - 2 
							   WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'wednesday' THEN CURRENT_DATE - 3 
							   WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'thursday' THEN CURRENT_DATE - 4 
							   WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'friday' THEN CURRENT_DATE - 5 
							   WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'saturday' THEN CURRENT_DATE - 6 
							   WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'sunday' THEN CURRENT_DATE 
						   END
		 AND "entityName" <> 'AVOCarbon' ), 
--	3rd CTE : Dat_Serie_Tableau2
--	retrieve all fields from kpi."Dat_Serie_Tableau"
--	WHERE Clause : field "inputValue" is not null, 
--					and "inputDate" =  date of last Sunday  
--						 example : Monday 26th of June 2017 will send Sunday 25th of June 2017)
--					and field "entityName" different than 'AVOCarbon'
Dat_Serie_Tableau2 AS
(
SELECT *
   FROM kpi."Dat_Serie_Tableau"
   WHERE "inputValue" IS NOT NULL
     AND "inputDate" = CASE 

                           WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'monday' THEN CURRENT_DATE - 1
                           WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'tuesday' THEN CURRENT_DATE - 2
                           WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'wednesday' THEN CURRENT_DATE - 3
                           WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'thursday' THEN CURRENT_DATE - 4
                           WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'friday' THEN CURRENT_DATE - 5
                           WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'saturday' THEN CURRENT_DATE - 6
                           WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'sunday' THEN CURRENT_DATE
                       END
     AND "entityName" <> 'AVOCarbon' ), 
--	4th CTE : Dat_Serie_Tableau3
--	retrieve all fields from kpi."Dat_Serie_Tableau"
--	WHERE Clause : field "inputValue" is not null, 
--					and "inputDate" =  date of Sunday of the previous week 
--						 example : Monday 26th of June 2017 will send Sunday 18th of June 2017)
--					and field "entityName" different than 'AVOCarbon'	 
Dat_Serie_Tableau3 AS 
(
	  SELECT *
	   FROM kpi."Dat_Serie_Tableau" 
	   WHERE "inputValue" IS NOT NULL
		 AND "inputDate" = CASE

							   WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'monday' THEN CURRENT_DATE - 8 
							   WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'tuesday' THEN CURRENT_DATE - 9 
							   WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'wednesday' THEN CURRENT_DATE - 10 
							   WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'thursday' THEN CURRENT_DATE - 11 
							   WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'friday' THEN CURRENT_DATE - 12 
							   WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'saturday' THEN CURRENT_DATE - 13 
							   WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'sunday' THEN CURRENT_DATE -7 
						   END
		 AND "entityName" <> 'AVOCarbon' 
) 
-- Using the 4 CTEs , we retrieve	
--	8 fields from the CTE, "Def_Serie_Seized" and from the CTE, "Dat_Serie_Tableau"

SELECT Def_Serie_Seized."serieID", 
       Dat_Serie_Tableau ."inputWeek", 
--	CASE Clause : if field Dat_Serie_Tableau."inputDate" is null then we use last sunday 
--					example : Monday 26th of June 2017 will send Sunday 25th of June 2017)
--					else it will put "inputDate"
CASE 
    WHEN Dat_Serie_Tableau ."inputDate" IS NULL THEN CASE 
                                                         WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'monday' THEN CURRENT_DATE - 1 
                                                         WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'tuesday' THEN CURRENT_DATE - 2 
                                                         WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'wednesday' THEN CURRENT_DATE - 3 
                                                         WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'thursday' THEN CURRENT_DATE - 4 
                                                         WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'friday' THEN CURRENT_DATE - 5 
                                                         WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'saturday' THEN CURRENT_DATE - 6 
                                                         WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'sunday' THEN CURRENT_DATE 
                                                     END 
    ELSE Dat_Serie_Tableau ."inputDate" 
        END, 

Def_Serie_Seized."serieName", 
Def_Serie_Seized.Site, 
Dat_Serie_Tableau ."inputValue", 
--	CASE clause : "seized_or_not" equals to 0 if Dat_Serie_Tableau."serieID" is null else 1
--	The 0 or 1 means what the factory has effectively filled or not as KPI 
CASE 
    WHEN Dat_Serie_Tableau."serieID" IS NULL THEN 0 
    ELSE 1 
  END AS seized_or_not, 
--	CASE clause : "Should_be_seized"  equals to 1 if Dat_Serie_Tableau."serieID" is null else 1
--	The 1 or 1 means what the factory must filled 
CASE 
    WHEN Dat_Serie_Tableau."serieID" IS NULL THEN 1 
    ELSE 1 
  END AS Should_be_seized 
FROM Def_Serie_Seized LEFT JOIN Dat_Serie_Tableau 
--	JOIN : CTE "Def_Serie_Seized" and "Dat_Serie_Tableau" 
--			on "serieID", "Site" and Def_Serie_Seized."serieID" equals to Dat_Serie_Tableau ."serieID" 
--			and Def_Serie_Seized."Site" equals  to Dat_serie_Tableau."entityName" 
--		    and Dat_serie_Tableau ."typeID" is equal to 1 or is null
	ON Def_Serie_Seized ."serieID" = Dat_Serie_Tableau ."serieID"
	AND Def_Serie_Seized.Site = Dat_serie_Tableau."entityName"
WHERE "typeID" = 1 OR "typeID" IS NULL
UNION 
--	UNION
--	retrieve 8 rows from the CTE, "Def_Serie_Seized" and CTE, "Dat_Serie_Tableau2"

SELECT Def_Serie_Seized."serieID",
       Dat_Serie_Tableau2 ."inputWeek", 
--	CASE clause: if "inputDate" is null, then last sunday 
--				example : Monday 26th of June 2017 will retrieve Sunday 25th of June 2017) else "inputDate"
CASE
    WHEN Dat_Serie_Tableau2 ."inputDate" IS NULL THEN CASE
                                                          WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'monday' THEN CURRENT_DATE - 1
                                                          WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'tuesday' THEN CURRENT_DATE - 2
                                                          WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'wednesday' THEN CURRENT_DATE - 3
                                                          WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'thursday' THEN CURRENT_DATE - 4
                                                          WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'friday' THEN CURRENT_DATE - 5
                                                          WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'saturday' THEN CURRENT_DATE - 6
                                                          WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'sunday' THEN CURRENT_DATE
                                                      END
    ELSE Dat_Serie_Tableau2 ."inputDate"
    END,
Def_Serie_Seized."serieName",
Def_Serie_Seized.Site,
Dat_Serie_Tableau2 ."inputValue", 
--	CASE clause : stock dans seized_or_not 0 si serieID de Dat_Serie_Tableau est null, sinon 1
--	The 0 or 1 means what the factory has effectively filled or not as KPI 
CASE
    WHEN Dat_Serie_Tableau2."serieID" IS NULL THEN 0
    ELSE 1
 END AS seized_or_not, 
--	CASE clause : if Dat_Serie_Tableau2."serieID" is null then 1 else 1
--	The 1 or 1 means what the factory must filled 
CASE
    WHEN Dat_Serie_Tableau2."serieID" IS NULL THEN 1
    ELSE 1
   END AS Should_be_seized
FROM Def_Serie_Seized 
--	Join of CTE, "Def_Serie_Seized" and CTE, "Dat_Serie_Tableau2" sur serieID, Site de Def_Serie_Seized est égal à 
--	l'entityName de Dat_serie_Tableau2 et typeID = 1 ou null
LEFT JOIN Dat_Serie_Tableau2 ON Def_Serie_Seized ."serieID" = Dat_Serie_Tableau2 ."serieID"
	AND Def_Serie_Seized.Site = Dat_serie_Tableau2."entityName" 
WHERE "typeID" = 1
  OR "typeID" IS NULL 
UNION 
--	retrieve 8 fields from the CTE, "Def_Serie_Seized" and the CTE, "Dat_Serie_Tableau3"
SELECT Def_Serie_Seized."serieID", 
       Dat_Serie_Tableau3 ."inputWeek", 
--	CASE clause: if Dat_Serie_Tableau."inputDate" is null then put Sunday of the last week 
--	(example: Monday 26th June 2017 will put Sunday 18th of June 2017) 
--	else it will put "inputDate"
CASE 
    WHEN Dat_Serie_Tableau3 ."inputDate" IS NULL THEN 
	CASE 
        WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'monday' THEN CURRENT_DATE - 8 
            WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'tuesday' THEN CURRENT_DATE - 9 
            WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'wednesday' THEN CURRENT_DATE - 10 
            WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'thursday' THEN CURRENT_DATE - 11 
            WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'friday' THEN CURRENT_DATE - 12 
            WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'saturday' THEN CURRENT_DATE - 13 
            WHEN TRIM(TRAILING FROM to_char(CURRENT_DATE, 'day')) = 'sunday' THEN CURRENT_DATE -7 
        END 
    ELSE Dat_Serie_Tableau3 ."inputDate" 
END, 
Def_Serie_Seized."serieName", 
Def_Serie_Seized.Site, 
Dat_Serie_Tableau3 ."inputValue", 
--	CASE clause : if Dat_Serie_Tableau3."serieID" is null then else sinon 1
CASE 
    WHEN Dat_Serie_Tableau3."serieID" IS NULL THEN 0 
    ELSE 1  END AS seized_or_not, 
--	CASE clause :if Dat_Serie_Tableau3."serieID" is null then 1 else  ??
CASE 
    WHEN Dat_Serie_Tableau3."serieID" IS NULL THEN 1 
    ELSE 1 
  END AS Should_be_seized 
FROM Def_Serie_Seized 
--	join on CTE, "Def_Serie_Seized" and CTE, "Dat_Serie_Tableau3" on fields  
--	serieID and field Def_Serie_Seized."Site" equals to  Dat_serie_Tableau3."entityName" de Dat_serie_Tableau3 et typeID = 1 ou null
LEFT JOIN Dat_Serie_Tableau3 ON Def_Serie_Seized ."serieID" = Dat_Serie_Tableau3 ."serieID"
AND Def_Serie_Seized.Site = Dat_serie_Tableau3."entityName"
WHERE "typeID" = 1 OR "typeID" IS NULL 
 --	order by serieID, inputDate and site
ORDER BY "serieID",
         "inputDate",
         "site"

