


```SQL
SELECT *, st_distance(st_centroid(st_transform(geometry, 4326)), (SELECT st_transform(geometry, 4326) from input1), TRUE) as  [% @FieldNamePrefix %]Dist
FROM input2
```
