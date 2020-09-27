# Distance and Direction Modelling in QGIS

### Purpose

The goal of this lab was to build a model in QGIS that could calculate and visualize the distance and direction of census tracts from the central business district of a city. Further analyses on the data were also done to understand the demographic structuruingThis can be a useful tool to test geographic theories of [urban growth](https://www.opengeography.org/ch-9-urban-geography.html). In this exercise, I started out by building a test model on data from Chicago census tracts. Once the model was up and running, I tested it's transferability on Philadelphia census tracts and updated it.

### Data

Data for this exercise was gathered from U.S. Census websites and compiled into a geopackage. The Philadelphia census tract shapefiles were gathered from the Census [Cartographic Boundary Files](https://www.census.gov/geographies/mapping-files/time-series/geo/carto-boundary-file.html). Demographic and Median Gross Rent were gathered from [Fact Finder](https://data.census.gov/cedsci/) and joined to to the shapefile boundaries. Download the data from this [geopackage](data/PhiladelphiaData.gpkg)

### Download Models 

The follwing two models were created to perform these analyses:

[Model to create CBD as centroid from tracts](models/CBDasCentroidforMacOS.model3)

[Model to calcualte distance and direction from CBD using Field Calculator algorithms](models/DistDirModelFieldCalculatorMacOS.model3)

[Model to calculate distance and direction from CBD using SQL algorithm](models/DistDirModelSQLMacOS.model3) (preferred model)

### Model to Create CBD from Census Tracts

![model_image](photos/ModelCBD.png)

This model is helpful if you would like to perform the distance and direction calculations with your own set of data. The other two models will find your cities CBD just by using input tracts, but if you would like to get an output feature of your CBD before running the other models, this model will be helpful.

The model takes the census tracts as it input and finds the centroid of each tract's polygon. Then, it takes the mean coordinates of those centroids to find the city center. To get an accurate CBD centroid, the best course of action is to select I number of tracts in the downtown area of the city (I selected 22 tracts in downtown Philadelphia) and run the model using 'selected features only'. This is because a city's central business district is rarely located in the city's geometric center.

### First Distance and Direction Model

![model_image](photos/modelFirst.png)

The first draft of the model incorporates the first model and then uses three field calculator algorthims to calculate:

1. The distance of each tract's centroid from the city center by converting the tracts into centroids and transforming both input's coordinate systems into World Geodetic System 1984 (WGS84, EPSG:4326). This conversion allows for an ellipsoidal calculation that preserves accurate distance. In this model, the distance  is calculated in decimal degrees.
  <details><summary> Code </summary>
  
  ```distance(
  transform(centroid($geometry),layer_property( @inputfeatures2 ,'CRS'),'EPSG:4326'), 

  transform(make_point(  @Mean_coordinate_s__OUTPUT_maxx , @Mean_coordinate_s__OUTPUT_maxy  ),
  layer_property( @citycenter ,'CRS'),'EPSG:4326'))
  ```
  <\details>
2. The direction in degrees of each tract from the city's center by converting the tracts into centroids and transforming both input's coordinate systems into World Mercator (EPSG:54004). This conversion allows for distance to be accurately preserved. 
  <details><summary> Code </summary>
  
  ```
  degrees(azimuth(

  transform( make_point(@Mean_coordinate_s__OUTPUT_maxx ,@Mean_coordinate_s__OUTPUT_maxy),               layer_property( @citycenter, 'CRS'),'EPSG:54004'),

  transform(centroid($geometry),layer_property(@inputfeatures2, 'CRS'), 'EPSG:54004')))
  ```
  
3. The direction into 8 cardinal and intercardinal directions by taking the output from the direction algorithm and using a CASE statement to categorize degree intervals by labelling them N, NE, E, SE, SE... etc.
  <details open>
  <summary> Code </summary>
  
  ```
  CASE

  WHEN attribute(concat(@FieldNamePrefix, 'Dir')) <= 22.5 THEN 'N'
  WHEN attribute(concat(@FieldNamePrefix, 'Dir'))  >= 337.5 THEN 'N'

  WHEN attribute(concat(@FieldNamePrefix, 'Dir')) <= 67.5 and attribute(concat(@FieldNamePrefix,      
  'Dir')) >= 22.5 THEN 'NE'

  WHEN attribute(concat(@FieldNamePrefix, 'Dir')) <= 112.5 and attribute(concat(@FieldNamePrefix,   
  'Dir')) >= 67.5 THEN 'E'

  WHEN attribute(concat(@FieldNamePrefix, 'Dir')) <= 157.5 and attribute(concat(@FieldNamePrefix, '
  Dir')) >= 112.5 THEN 'SE'

  WHEN attribute(concat(@FieldNamePrefix, 'Dir')) <= 202.5 and attribute(concat(@FieldNamePrefix,
  'Dir')) >= 157.5 THEN 'S'

  WHEN attribute(concat(@FieldNamePrefix, 'Dir')) <= 247.5 and attribute(concat(@FieldNamePrefix,  
  'Dir')) >= 202.5 THEN 'SW'

  WHEN attribute(concat(@FieldNamePrefix, 'Dir')) <= 292.5 and attribute(concat(@FieldNamePrefix,
  'Dir')) >= 247.5 THEN 'W'

  WHEN attribute(concat(@FieldNamePrefix, 'Dir')) <= 337.5 and attribute(concat(@FieldNamePrefix,
  'Dir')) >= 292.5 THEN 'NW'

  END
  ```
  <\details>

### Updating the Model with SQL Queries

To update the model, I replaced the field calculator algorithms with an execute sql algorithm. While both models will perform the functions, this centralizes the three calculations into one algorithm which arguably reduces the model's complexity (although SQL queries are perhaps more difficult to correctly perform as they are text-based; there is GUI to guide the user).

#### First SQL 

![model_image](photos/ModelSQL.png)

To familiarize myself with the execute sql algorithim, I began by performing an sql query to calculate the distance from the tracts. Additionally, because the QGIS version for Mac OS uses an older GDAL (2.4.1), I needed to reproject both inputs before transforming them in the SQL query. This enables the SQL to read them in their correct coordinate systems and outputs a distance measurement in meters instead of decimal degrees. If using this model on a Windows OS, the reproject algorithms may be redundant.

<details><summary> Code </summary>
  
```SQL
SELECT *, st_distance(st_centroid(st_transform(geometry, 4326)), (SELECT st_transform(geometry, 4326) from input1), TRUE) as  [% @FieldNamePrefix %]Dist
FROM input2
```
<\details>

#### Final SQL

![model_image](photos/ModelSQL2.png)

To update the SQL version of the model, I added the two direction algorithms to the SQL query. Additionally, I added an 'extract by expression' algorithm that removes unpopulated tracts from the calculation. While I added a vector field inout to the model that allows for a user defined input for the extract expression, it is currently not working. This means, for now, that the user will have to rename their total population field in the attribute table of the census tracts to "Total".

<details><summary> Code </summary>
  
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
<\details>

### Results

#### Maps
##### Distance from CBD

[map_image](photos/DistanceFinal.png)

##### Direction from CBD
[map_image](photos/DirectionFinal.png)

##### Median Gross Rent 
[map_image](photos/MedGrossRe.png)

#### Plots

[Distance from CBD scatter plot](plots/dis_plot.html)

[Direction from CBD polar plot](plots/dir_plot.html)

[Percent white and distance from CBD scatter plot](plots/dist_pctwhite.html)

[Percent black and distance from CBD scatter plot](plots/dist_pctblack.html)
