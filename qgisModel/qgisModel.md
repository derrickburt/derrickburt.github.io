
```SQL
CASE

WHEN attribute(concat(@FieldNamePrefix, 'Dir')) <= 22.5 THEN 'N'
WHEN attribute(concat(@FieldNamePrefix, 'Dir'))  >= 337.5 THEN 'N'

WHEN attribute(concat(@FieldNamePrefix, 'Dir')) <= 67.5 and attribute(concat(@FieldNamePrefix, 'Dir')) >= 22.5 THEN 'NE'

WHEN attribute(concat(@FieldNamePrefix, 'Dir')) <= 112.5 and attribute(concat(@FieldNamePrefix, 'Dir')) >= 67.5 THEN 'E'

WHEN attribute(concat(@FieldNamePrefix, 'Dir')) <= 157.5 and attribute(concat(@FieldNamePrefix, 'Dir')) >= 112.5 THEN 'SE'

WHEN attribute(concat(@FieldNamePrefix, 'Dir')) <= 202.5 and attribute(concat(@FieldNamePrefix, 'Dir')) >= 157.5 THEN 'S'

WHEN attribute(concat(@FieldNamePrefix, 'Dir')) <= 247.5 and attribute(concat(@FieldNamePrefix, 'Dir')) >= 202.5 THEN 'SW'

WHEN attribute(concat(@FieldNamePrefix, 'Dir')) <= 292.5 and attribute(concat(@FieldNamePrefix, 'Dir')) >= 247.5 THEN 'W'

WHEN attribute(concat(@FieldNamePrefix, 'Dir')) <= 337.5 and attribute(concat(@FieldNamePrefix, 'Dir')) >= 292.5 THEN 'NW'

END
```

```SQL
SELECT *, st_distance(st_centroid(st_transform(geometry, 4326)), (SELECT st_transform(geometry, 4326) from input1), TRUE) as  [% @FieldNamePrefix %]Dist
FROM input2
```
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
