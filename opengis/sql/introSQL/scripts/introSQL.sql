Lab 3: Postgre SQL

Postgis: host (Artemis), username/password: deburt, port: 5432, database: deburt


/* Check uniqueness of field*/

SELECT COUNT(DISTINCT gisjoin), COUNT(gisjoin) FROM tables1940

/* Left out Join tables1940 to tracts1940*/

SELECT*
FROM tracts1940 AS a LEFT OUTER JOIN tables1940 as b
ON a.gisjoin =b.gisjoin

SELECT*
FROM tracts1940 AS a LEFT OUTER JOIN tables1940 AS b
ON a.gisjoin = b.gisjoin

/* Check how many are tracts1940 unmatched to table 1940*/

SELECT*
FROM tracts1940 AS a LEFT OUTER JOIN tables1940 AS b
ON a.gisjoin = b.gisjoin
WHERE a.gisjoin IS NULL

/* Check how many tables1940 are unmatched to tracts1940*/

SELECT*
FROM tracts1940 AS a RIGHT OUTER JOIN tables19440 AS b
ON a.gisjoin = b.gisjoin
WHERE b.gisjoin IS NULL

/* Customize the Fields we want to join -- a.* means to get all of the columns from table a, which is tracts1940 */

SELECT a.*, b.poptotal, b.white, b.medgrossrent
FROM tracts1940 AS a LEFT OUTER JOIN AS b
ON a.gisjoin = b.gisjoin

/* Order by Median Gross Rent descending */

SELECT a.*, b.poptotal, b.white, b.medgrossrent
FROM tracts1940 AS a LEFT OUTER JOIN tables1940 AS b
ON a.gisjoin = b.gisjoin
ORDER BY medgrossrent DESC

/* Order by Median Gross Rent > 0 and descending */

SELECT a.*, b.poptotal, b.white, b.medgrossrent
FROM tracts1940 AS a LEFT OUTER JOIN tables1940 AS b
ON a.gisjoin = b.gisjoin
WHERE medgrossrent > 0
ORDER BY medgrossrent DESC

/* Helpful Reminders *.
 
/* Modifying the SELECT line’s list of columns changes which columns you’ll get */
/* Adding a WHERE clause changes which rows/records/features you’ll get  */
/* The order of a selection query’s parts thus far goes: */
		 /*  SELECT  */
		 /*. FROM  (optional JOIN … ON … )*/
		 /*  WHERE  */
		 /*  ORDER BY.  */

 /* CREATE VIEW is a slection query that appears in most respects like a table: like a virtual layer in a GIS -- pulling from other data tables that store actual data  */

CREATE VIEW tracts1940pop AS
SELECT a.*, b.poptotal, b.white, b.medgrossrent
FROM tracts1940 AS a LEFT OUTER JOIN tables1940 AS b
ON a.gisjoin = b.gisjoin
ORDER BY medgrossrent DESC

/* DISTANCE AND DIRECTION */

/* Calculate distance from CBD */

SELECT *,
DEGREES(ST_AZIMUTH(
(SELECT ST_TRANSFORM(geom, 3395) FROM cbd),
ST_CENTROID(ST_TRANSFORM(geom, 3395)))) AS dir 
FROM join1940

/* Calcualte distance and direction from CBD */

SELECT *,
ST_DISTANCE(
ST_CENTROID(GEOGRAPHY(ST_TRANSFORM(geom, 4326))),
(SELECT GEOGRAPHY(ST_TRANSFORM(geom, 4326) )FROM cbd)) AS dist,
DEGREES(ST_AZIMUTH(
(SELECT ST_TRANSFORM(geom, 3395) FROM cbd),
ST_CENTROID(ST_TRANSFORM(geom, 3395)))) AS dir 
FROM join1940

/* Create view of tracts1940 with dist and direction from cbd calculated */

CREATE VIEW tracts1940_disdir2 AS
SELECT *,
ST_DISTANCE(
ST_CENTROID(GEOGRAPHY(ST_TRANSFORM(geom, 4326))),
(SELECT GEOGRAPHY(ST_TRANSFORM(geom, 4326) )FROM cbd)) AS dist,
DEGREES(ST_AZIMUTH(
(SELECT ST_TRANSFORM(geom, 3395) FROM cbd),
ST_CENTROID(ST_TRANSFORM(geom, 3395)))) AS dir 
FROM tracts1940

/* Select new version of cbd with proper projection */

SELECT id, ST_TRANSFORM(geom, 3528) AS geom
FROM cbd

/* Save properly projected cbd as a permanent table */

CREATE TABLE cbd5328 AS
SELECT id, st_transform(geom,5328) AS geom2
FROM cbd

/* FIXING GEOMETRY/TABLES */

/* Add Primary Key */

ALTER TABLE cbd5328 ADD PRIMARY KEY (id)

/* Updating geometry */

SELECT populate_geometry_columns('public.cbd5328'::regclass) /*1 means it works*/

/* To create a spatial index, simply go to the "info" tab and select "create it" if the page says "No spatial index defined"

/* See characteristics of Geometry */
	
SELECT *,
St_astext(geom2),
St_srid(geom2),
Geometrytype(geom2),
St_dimension(geom2),
St_numgeometries(geom2),
St_numpoints(geom2),
St_isvalid(geom2)
FROM cbd5328

/* BUFFERS */

/* Buffer 5km from cbd5328 */

SELECT id, ST_BUFFER(geom2, 5000) AS geom
FROM cbd5328

/* Create View of Buffer */

CREATE TABLE cbd5km AS
SELECT id, ST_BUFFER(geom2, 5000) AS buffzone
FROM cbd5328

/* Update geometry */

SELECT populate_geometry_columns('public.cbd5km'::regclass) /*1 means it works*/

/* See characteristicsof Geometry */

SELECT *,
St_astext(geom),
St_srid(geom),
Geometrytype(geom),
St_dimension(geom),
St_numgeometries(geom),
St_numpoints(geom),
St_isvalid(geom)
FROM cbd5km

/* Select all tracts that are w/in 5km of cbd by adding intersection*/

SELECT *
FROM join1940
WHERE ST_INTERSECTS(geom, (SELECT geom FROM cbd5km))

/* Try query with buffer calculation */

SELECT *
FROM join1940
WHERE ST_INTERSECTS(geom,(SELECT ST_BUFFER(geom2, 5000) from cbd5328))


/* Create table from intersect query with buffer*/

CREATE TABLE cbd1940 AS
SELECT *
FROM join1940
WHERE ST_INTERSECTS(geom,(SELECT ST_BUFFER(geom2, 5000) from cbd5328))

/* Update geometry */

SELECT populate_geometry_columns('public.cbd5km'::regclass) /*1 means it works*/

/* AGGREGATE FUNCTIONS */

/* Find mean, min, max, and total (tracts) of rent from tracts*/

SELECT COUNT(id) AS countID, 
MIN(medgrossrent) as minRent, 
AVG(medgrossrent) as avgRent, 
MAX(medgrossrent) as maxRent
FROM cbd1940

/* Aggregate function for geometries*/

CREATE VIEW cbdUnion AS
SELECT 1 as id, 
COUNT(id) AS countID, 
MIN(medgrossrent) as minRent, 
AVG(medgrossrent) as avgRent, 
MAX(medgrossrent) as maxRent, 
ST_UNION(geom) as geom
FROM cbd1940


/* Aggregate and reproject*/

CREATE VIEW cbdUnion2 AS
SELECT 1 as id, 
COUNT(id) AS countID, 
MIN(medgrossrent) as minRent, 
AVG(medgrossrent) as avgRent, 
MAX(medgrossrent) as maxRent, 
ST_UNION(ST_TRANSFORM(geom, 3528))::geometry(multipolygon, 3528) as geom
FROM cbd1940

/* Drop Column */
ALTER TABLE x
DROP COLUMN xx;

/* Resilience Academy in Dar Es Salaam */

/* Sizing big data sets */

SELECT *
FROM data_set
LIMIT 100

/* Add columns to to existing tables */

ALTER TABLE table_name ADD COLUMN column_name data_type

/* Add a geometry column */

SELECT addgeometrycolumn(‘public’, ‘table_name’, ‘column_name’, srid, ‘geometry_type’, 2)

/* Calculate or recalculate values in an existing table column */

UPDATE table_name
SET column_name = formula_or_expression

/* Update the values in one table based on information in a different table *?
	/* Use a form of UPDATE that includes a join to another table */

UPDATE first_table
SET column_name = formula_or_expression
FROM another_table
WHERE join_criteria /* attribute join (table1field = table2field) 
							/* spatial join ST_INTERSECTS(table1geom, table2geom) */


/* Calculate or re-calculate values on a sub-set of rows in a table */

UPDATE table_name
SET column_name = formula_or_expression
WHERE selection_condition. /* st_contains, st_intersects, wt_within */


/* Spatial overlay functions can be accomplished similarly to field calculations */
	/* st_intersects() gives a true or false answer */
	/* st_intersection gives you a new geometry--the result of overlaying two features 		where they intersect */

	/* table a should be the smaller features, table b the larger featues */
	/* 1) speed is optimized by excluding ones that only intersect on boundary -- 		st_intersects and NOT st_touches */
	/* 2) also by CASEZ statement which only changes geoms that are actually cut */

SELECT a.column_name, b.column_name,
CASE
WHEN ST_CoveredBy (a.geom, b.geom)
THEN ST_Multi (a.geom)
ELSE
	ST_Multi( ST_INTERSECTION(a.geom,b.geom)
FROM first_table AS a
	INNER JOIN second_table AS b
		ON (ST_INTERSECTS(a.geom, b.geom)
			AND NOT ST_TOUCHES(a.geom, b.geom) ;



