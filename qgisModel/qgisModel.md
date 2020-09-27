# Distance and Direction Modelling in QGIS

### Purpose

The goal of this lab was to build a model in QGIS that could calculate and visualize the distance and direction of census tracts from the central business district of a city. This can be a useful tool to test geographic theories of [urban growth](https://www.opengeography.org/ch-9-urban-geography.html).

### Data

Data for this exercise was gathered from U.S. Census websites and compiled into a geopackage. The Philadelphia census tract shapefiles were gathered from the Census [Cartographic Boundary Files](https://www.census.gov/geographies/mapping-files/time-series/geo/carto-boundary-file.html). Demographic and Median Gross Rent were gathered from [Fact Finder](https://data.census.gov/cedsci/) and joined to to the shapefile boundaries. Download the data from this [geopackage](data/PhiladelphiaData.gpkg)

### Models 

The follwing two models were created to perform these analyses:

[Model to create CBD as centroid from tracts](models/CBDasCentroidforMacOS.model3)

[Model to calculate distance and direction from CBD](models/DistDirModelforMacOS.model3)

### Original Model

### Updating the Model with SQL Queries

#### First SQL 
```SQL
SELECT *, st_distance(st_centroid(st_transform(geometry, 4326)), (SELECT st_transform(geometry, 4326) from input1), TRUE) as  [% @FieldNamePrefix %]Dist
FROM input2
```

#### Final SQL
```SQL
SELECT dis_dir. *, 

CASE

WHEN [% @FieldNamePrefix %]Dir <= 22.5 THEN 'N'
WHEN [% @FieldNamePrefix %]Dir  >= 337.5 THEN 'N'
WHEN [% @FieldNamePrefix %]Dir <= 67.5 and [% @FieldNamePrefix %]Dir >= 22.5 THEN 'NE'
WHEN [% @FieldNamePrefix %]Dir <= 112.5 and [% @FieldNamePrefix %]Dir >= 67.5 THEN 'E'
WHEN [% @FieldNamePrefix %]Dir <= 157.5 and [% @FieldNamePrefix %]Dir >= 112.5 THEN 'SE'
WHEN [% @FieldNamePrefix %]Dir <= 202.5 and [% @FieldNamePrefix %]Dir >= 157.5 THEN 'S'
WHEN [% @FieldNamePrefix %]Dir <= 247.5 and [% @FieldNamePrefix %]Dir >= 202.5 THEN 'SW'
WHEN [% @FieldNamePrefix %]Dir <= 292.5 and [% @FieldNamePrefix %]Dir>= 247.5 THEN 'W'
WHEN [% @FieldNamePrefix %]Dir <= 337.5 and [% @FieldNamePrefix %]Dir >= 292.5 THEN 'NW'

END as [% @FieldNamePrefix %]CardDir 

FROM(SELECT *,

st_distance(
st_centroid(st_transform(geometry, 4326)), (SELECT st_transform(geometry, 4326) from input1), TRUE) as  [% @FieldNamePrefix %]Dist,

degrees(
azimuth((SELECT st_transform(geometry, 3395) from input1), st_centroid(st_transform(geometry, 3395)))) as  [% @FieldNamePrefix %]Dir

FROM input2) as dis_dir
```
