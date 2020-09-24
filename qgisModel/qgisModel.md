


```SQL
SELECT *, distance(centroid(transform(geometry, 4326)), (SELECT transform(geometry, 4326) from input1), TRUE) as  [% @FieldNamePrefix %]Dist
FROM input2
```
