
/* Workflow in SQL Queries */

/* General Preparation (Create Spatial Indices for All Inputs) */

/* Populate Geometry Column of OSM polygons */
SELECT populate_geometry_columns('public.planet_osm_polygon'::regclass)

/* Spatial Workflow -- Finding all Residential Zones within .25 mi of PT stops */

/* COUNT ALL RES BUILDINGS and JOIN TO SUBWARDS */

/* COUNT RES BUILDINGS and JOIN TO SUBWARDS */

/* Then COUNT RES BUILDINGS within .25 MI OF PT STOPS and JOIN TO SUBWARDS */

/* Select residential buildings */
CREATE TABLE res_osm_polygon AS
SELECT osm_id, building, ST_TRANSFORM(way, 32737) as geom 
FROM planet_osm_polygon
WHERE building = 'residential'

CREATE TABLE res_osm_point AS
SELECT osm_id, building, ST_TRANSFORM(way, 32737) as geom 
FROM planet_osm_point 
WHERE building = 'residential'

/* The polygons have duplicates, so they will need to be deleted before creating a primary key */
SELECT osm_id, COUNT( osm_id )
FROM res_osm_polygon
GROUP BY osm_id
HAVING COUNT( osm_id )> 1
ORDER BY osm_id;
SELECT osm_id, COUNT( osm_id )
FROM res_osm_point
GROUP BY osm_id
HAVING COUNT( osm_id )> 1
ORDER BY osm_id;

/* Populate respective geometry columns and Add primary key*/
SELECT populate_geometry_columns('public.res_osm_polygon'::regclass);
ALTER TABLE res_osm_polygon ADD PRIMARY KEY (osm_id)

SELECT populate_geometry_columns('public.res_osm_point'::regclass);
ALTER TABLE res_osm_point ADD PRIMARY KEY (osm_id)

/* Get rid of residential points that were also counted as residential polygons */
/* Create column*/
ALTER TABLE res_osm_point ADD COLUMN duplicate INTEGER;
UPDATE res_osm_point
SET duplicate = 1
FROM res_osm_polygon
WHERE ST_INTERSECTS(res_osm_point.geom, res_osm_polygon.geom)

/* Delete the points that overlap the polygons */
DELETE FROM res_osm_point
WHERE duplicate = 1

/* Convert residential polygons to centroids and union with residential points */
CREATE TABLE res_union AS
SELECT osm_id, building, ST_CENTROID(geom) AS geom
FROM res_osm_polygon
UNION 
SELECT osm_id, building, geom 
FROM res_osm_point

/* Populate geometry column, Add primary key, Create spatial index */
SELECT populate_geometry_columns('public.res_union'::regclass);
ALTER TABLE res_union ADD PRIMARY KEY (osm_id)

/* Count how many residential buildings are in each subward */
CREATE TABLE subwards_join AS
SELECT
ds_subwards.fid as fid, ds_subwards.ward_name as ward_name, ds_subwards.geom as geom1,
COUNT(osm_id) as total_ct
FROM ds_subwards 
JOIN res_union 
ON ST_Intersects(ds_subwards.geom, res_union.geom)
GROUP BY ds_subwards.fid, ds_subwards.ward_name

/* Populate geometry column, Add primary key, Create spatial index */
SELECT populate_geometry_columns('public.subwards_join'::regclass);
ALTER TABLE subwards_join ADD PRIMARY KEY (fid)

/* SELECT residential buildings within .25mi (402.336m) Buffer of stops */
/* Add Dar Es Salaam Public Tranpsortation Stops from WFS into postgres database */

/* Create a column of buildings that are within a .25 mi of BUFFER stop points */
ALTER TABLE res_union ADD COLUMN res_access INTEGER;
UPDATE res_union
SET res_access = 1
FROM ds_stops
WHERE ST_DWITHIN(res_union.geom, ds_stops.geom, 402.33)

/* Create a table where only the tracts within the buffer zone are included */
CREATE TABLE res_within_stopzone AS
SELECT *
FROM res_union
WHERE res_access = 1

/* Populate geometry column, Add primary key, Create spatial index */
SELECT populate_geometry_columns('public.res_within_stopzone'::regclass);
ALTER TABLE res_within_stopzone ADD PRIMARY KEY (osm_id)

/* Join the res_access column to the subwards containing total res building counts, count # of buildings with access */
CREATE TABLE subwards_final AS
SELECT a.fid, a.geom1, a.total_ct,
COUNT(b.res_access) as stops_access
FROM subwards_join a
JOIN res_within_stopzone b
ON ST_Intersects(a.geom1, b.geom)
GROUP BY a.fid

/* Populate geometry column, Add primary key, Create spatial index */
SELECT populate_geometry_columns('public.subwards_final'::regclass);
ALTER TABLE subwards_final ADD PRIMARY KEY (fid)

/* Calculate Percentages */
ALTER TABLE subwards_final ADD COLUMN pct_access DOUBLE PRECISION;
UPDATE subwards_final
SET pct_access = (stops_access * 1.0/total_ct) * 1000;



