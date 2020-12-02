# Web Mapping from QGIS with Leaflet

### Purpose 

This exercise will teach you how to use the qgis2web plugin to create a Leaflet web map from QGIS.

### Software

The following software was used to complete this exercise:

* [QGIS 3.10](https://qgis.org/en/site/forusers/download.html) with [qgis2web plugin](https://github.com/tomchadwin/qgis2web/blob/master/README.md)

### Data

If you would like to follow along using the data from my webmap, download this [geopackage](dsGPKG.gpkg). If you would like to use your own data, the next step will instruct you how to prepare them for the web map.

### Preparing your Data

1) Add all of the desired geographic data to your canvas. Remove anything you don't want to add (you can also do this later, but getting rid of the useless data earlier doesn't hurt).
2) Make sure that any attribute information that you don't want online has been removed. This make you GeoJSON files smaller and make for shorter loading times. There are multiple ways to do this. One way is to go "**Properties**" > "**Fields**" and [select the pencil editor](photos/propertiesFields/png) and drop the unwanted fields using [delete field](photos/deleteField.png). Another way is to go "**Processing Toolbox**" > "**Vector tables**" > ["**Drop Fields**"](photos/dropFields.png) and use the drop fields tool to create a new layer without the unwanted fields.
3) Style all of your points with simple marker.
4) If you would like add a basemap, make sure your project CRS is set to WGS84/EPSG:4326. Although it would make seem that Pseudo Mercator/EPSG:3857 would work, I was unable to get the Leaflet web map to cooperate with this projection for the OSM Standard base map.

### Installing qgis2web

To install qgis2web, navigate to "**Plugins**" > ["**Manage and Install Plugins**"](photos/plugins.png) and search for "qgis2web" and install it.

### Using qgis2web

With all of your data prepared for mapping, navigate to "**Web**" > "**qgis2web**" > ["**Create Web Map**"](photos/plugins.png).

### Leaflet

Make sure that you have selected **Leaflet** as your output map format.

![Leaflet](photos/Leaflet.png)

#### Layers and Groups

Here, you will will be deciding which layers will be visible upon opening the web map, which layers will have popups (and how they will be styled), and which layers will be cluster. If you would like a layer to be invisible on opening with no popups, [uncheck both boxes](photos/noVisnoPop.png). If you would like a layer to be visible and have popups, [check both boxse](photos/VisPop.png) and choose whether you want the attribute names to be in header (above) or inline (next to) format.

#### Appearance 

Here are the parameters I used in my [appearance tab](photos/Appearance.png). Most of the settings I left at their default. I changed the "**Add layers list**" to expanded to show the entire legend. I sent the "**Extent**" to "Canvas extent", and made sure my canvas was set to an appropriate scale before exporting. I set the "**Max Zoom Level**" to 25 and the "**Min Zoom Level**" to 3. I unchecked "**Restrict to extent**" so that users can zoom out as far as the like.

#### Export 

I set the "**Exporter**" to "Export to folder" and left the rest of the settings at their defaults.

### Customize by Editing the .html File

Upon exporting, a folder will be saved in the same location that your .qgz/.qgs filed is saved. You can click on the index.html file to get an initial view of your map. 

#### Attributions in Footing

I added a hyperlinked attribution in bottom corner to share my github page with users. For hyperlinks that I wanted to be opened in a new tab (all but my own), I inserted ```target="_blank"``` after the link to the respective website ```<href=link HERE>```.

Original:
```html
map.attributionControl.setPrefix('<a href="https://github.com/tomchadwin/qgis2web" target="_blank">qgis2web</a> &middot; <a href="https://leafletjs.com" title="A JS library for interactive maps">Leaflet</a> &middot; <a href="https://qgis.org">QGIS</a>');
```

Modification:
```html
map.attributionControl.setPrefix('<a href="https://derrickburt.github.io" >derrickburt</a> &middot; <a href="https://github.com/tomchadwin/qgis2web" target="_blank">qgis2web</a> &middot; <a href="https://leafletjs.com" title="A JS library for interactive maps">Leaflet</a> &middot; <a href="https://qgis.org" target="_blank">>QGIS</a>')
```
I also added an attribution for each individual layer, here's an example for the Subwards layer: 

Original:
```html
        var layer_AllSubwards_1 = new L.geoJson(json_AllSubwards_1, {
            attribution: '',
            interactive: true,
            dataVar: 'json_AllSubwards_1',
            layerName: 'layer_AllSubwards_1',
            pane: 'pane_AllSubwards_1',
            onEachFeature: pop_AllSubwards_1,
            style: style_AllSubwards_1_0,
        });
```

Modification:
```html
        var layer_AllSubwards_1 = new L.geoJson(json_AllSubwards_1, {
            attribution: '<a href="https://www.openstreetmap.org/copyright">© OpenStreetMap contributors, CC-BY-SA</a>',
            interactive: true,
            dataVar: 'json_AllSubwards_1',
            layerName: 'layer_AllSubwards_1',
            pane: 'pane_AllSubwards_1',
            onEachFeature: pop_AllSubwards_1,
            style: style_AllSubwards_1_0,
        });
```

#### Popups 

I edited the the naming of my popups from their attribute names more legible:

Original:
```html
function pop_HomeswithinPTZone_4(feature, layer) {
            var popupContent = '<table>\
                    <tr>\
                        <th scope="row">fid</th>\
                        <td>' + (feature.properties['fid'] !== null ? autolinker.link(feature.properties['fid'].toLocaleString()) : '') + '</td>\
                    </tr>\
                    <tr>\
                        <th scope="row">total_res</th>\
                        <td>' + (feature.properties['total_res'] !== null ? autolinker.link(feature.properties['total_res'].toLocaleString()) : '') + '</td>\
                    </tr>\
                    <tr>\
                        <th scope="row">pct_access</th>\
                        <td>' + (feature.properties['pct_access'] !== null ? autolinker.link(feature.properties['pct_access'].toLocaleString()) : '') + '</td>\
                    </tr>\
                </table>';
            layer.bindPopup(popupContent, {maxHeight: 400});
        }
```

Modification:
```html
function pop_HomeswithinPTZone_4(feature, layer) {
            var popupContent = '<table>\
                    <tr>\
                        <th scope="row">fid</th>\
                        <td>' + (feature.properties['fid'] !== null ? autolinker.link(feature.properties['ID'].toLocaleString()) : '') + '</td>\
                    </tr>\
                    <tr>\
                        <th scope="row">total_res</th>\
                        <td>' + (feature.properties['total_res'] !== null ? autolinker.link(feature.properties['Total Residences'].toLocaleString()) : '') + '</td>\
                    </tr>\
                    <tr>\
                        <th scope="row">pct_access</th>\
                        <td>' + (feature.properties['pct_access'] !== null ? autolinker.link(feature.properties['Pct Residences in Zone'].toLocaleString()) : '') + '</td>\
                    </tr>\
                </table>';
            layer.bindPopup(popupContent, {maxHeight: 400});
        }
```

#### Add a Scale bar

At the bottom of the script add ```L.control.scale().addTo(map);``` just before ```</script```:

```html
L.control.scale().addTo(map);
        </script>
    </body>
</html>
```
