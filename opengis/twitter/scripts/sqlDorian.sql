/* SQL for analysis of Tweets related to Hurricane Dorian */

/* Add a projected coordinate system */
INSERT into spatial_ref_sys (srid, auth_name, auth_srid, proj4text, srtext) values ( 9102004, 'esri', 102004, '+proj=lcc +lat_1=33 +lat_2=45 +lat_0=39 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs ', 'PROJCS["USA_Contiguous_Lambert_Conformal_Conic",GEOGCS["GCS_North_American_1983",DATUM["North_American_Datum_1983",SPHEROID["GRS_1980",6378137,298.257222101]],PRIMEM["Greenwich",0],UNIT["Degree",0.017453292519943295]],PROJECTION["Lambert_Conformal_Conic_2SP"],PARAMETER["False_Easting",0],PARAMETER["False_Northing",0],PARAMETER["Central_Meridian",-96],PARAMETER["Standard_Parallel_1",33],PARAMETER["Standard_Parallel_2",45],PARAMETER["Latitude_Of_Origin",39],UNIT["Meter",1],AUTHORITY["EPSG","102004"]]');

/* Add geometry column to twitter data */
ALTER TABLE dorian ADD COLUMN geom geometry;
ALTER TABLE november ADD COLUMN geom geometry;

/* Create points for twitter data, reproject, and populate geometry columns */
UPDATE dorian
SET geom = ST_TRANSFORM( ST_SETSRID( ST_MAKEPOINT(lng, lat), 4326), 102004);
SELECT populate_geometry_columns('dorian'::regclass);

UPDATE november
SET geom = ST_TRANSFORM( ST_SETSRID( ST_MAKEPOINT(lng, lat), 4326), 102004);
SELECT populate_geometry_columns('november'::regclass);

/* Counties should be imported from R with the correct geometry type but no srid */
/* Set SRID for the counties data */
/* select srid -- if set then look for select populate geom columns (if not then have to do to query to set them */
ALTER TABLE counties
ALTER COLUMN geometry TYPE geometry(MultiPolygon,102004) 
USING ST_SetSRID(geometry,102004);

/* update geometry of counties */
/* for some reason -- the Query above projects it into the map in WGS 84 (visually) even though it claims it is 102004, the additional query below seems to clear this error */
UPDATE counties
SET geometry = ST_TRANSFORM( ST_SETSRID( geometry, 4326), 102004);

/* Add a primary key to counties */
ALTER TABLE counties ADD PRIMARY KEY (geoid);

/* Get rid of counties outside of area of interest (east coast) */
DELETE FROM counties
WHERE statefp NOT IN ('54',	'51',	'50',	'47',	'45',	'44',	'42',	'39',	'37',	'36',	'34',	'33',	'29',	'28',	'25',	'24',	'23',	'22',	'21',	'18',	'17',	'13',	'12',	'11',	'10',	'09',	'05',	'01');

/* Count number of each type of tweet by county */
/* add geoid column to tweet tables to count by */
ALTER TABLE dorian ADD COLUMN geoid varchar(5);
ALTER TABLE november ADD COLUMN geoid varchar(5);

/* match respective tweet geoid column to county column where they intersect */
UPDATE dorian
SET geoid = counties.geoid
FROM counties
WHERE ST_INTERSECTS(dorian.geom, counties.geometry);

UPDATE november
SET geoid = counties.geoid
FROM counties
WHERE ST_INTERSECTS(november.geom, counties.geometry);

/* Count unique values to find column to count number of tweets by  */
SELECT DISTINCT user_id, status_id
FROM dorian;

/* Create tables with tweet counties grouped by county */
CREATE TABLE dorian_ct AS
SELECT COUNT(user_id), geoid
FROM dorian
GROUP BY geoid;

CREATE TABLE november_ct AS
SELECT COUNT(user_id), geoid
FROM november
GROUP BY geoid;

/* Add columns to for respective tweet counts, set count column to zero so nulls are counted as zeros, and then populate with counts from aggregated twitter counts */
ALTER TABLE counties ADD COLUMN dorian_ct INTEGER;
UPDATE counties
SET dorian_ct = 0;
UPDATE counties
SET dorian_ct = dorian_ct.count
FROM dorian_ct
WHERE dorian_ct.geoid = counties.geoid;

ALTER TABLE counties ADD COLUMN nov_ct INTEGER;
UPDATE counties
SET nov_ct = 0;
UPDATE counties 
SET nov_ct = november_ct.count
FROM november_ct
WHERE november_ct.geoid = counties.geoid;

/* Add column to calculate tweet rate and calculate rate per 10000 people */
ALTER TABLE counties ADD COLUMN dorian_rt REAL;
UPDATE counties 
SET dorian_rt = (dorian_ct/pop) * 10000;

ALTER TABLE counties ADD COLUMN nov_rt REAL;
UPDATE counties 
SET nov_rt = (nov_ct/pop) * 10000;

/* Add column to calculate NDTI */
ALTER TABLE counties ADD COLUMN ndti REAL;
UPDATE counties 
SET ndti = (1.0 * dorian_ct - nov_ct)/(1.0 * dorian_ct + nov_ct)
WHERE (dorian_ct + nov_ct) > 0;

/* Set NDTI Nulls = 0 */
UPDATE counties
SET ndti = 0
WHERE ndti = null;

/* Centroids for heat map */
CREATE TABLE counties_pts AS 
SELECT*, ST_CENTROIDS(geometry)
FROM counties
