# FOSS4G Conference Article Review

## **Database transformation, cadastre automatic data processing in qgis and implementation in web GIS**

Ostadabbas, Weippert, and Behr identify the value of using open-source tools to automatically process land parcel data and 
visualize the data transparently. The study emerged as a technoligical solution to a German law that requires municipalities to 
publish the standard value of land based on land use categories. The authors point out that the agencies tasked with acquiring, 
processing, and publishing these data are often unable to performs these tasks due to insufficient technologies and skillsets. 
The authors provide a comprehensive and open source methodology to automate the determination of standard land values and 
visualization of the data according to European standards. The original data processing to determine and visualize land values 
was carried out in a proprietary GIS. The study aims to open up and mechanize these processes by migrating “the process completely 
from the proprietary GIS to an Open Source GIS (QGIS), database (PostgreeSQL) and Web GIS (QgIS server and Lizmap as Web client) 
to be financially independent and to adapt possibly the tools to specific requirements by programming individual plugins” (p. 176). 
They outline a four-step process. The first requires importing the cadastral data into a PostgreSQL database. Then the cadastral 
data is restructured with a query-based language to prepare the layers by a unique identifier, geometry, land value, and address. 
After being prepared in PostGis, the data is labelled and symbologized with a python script. To make the final cadastral maps 
publicly available, the authors published the map on a QGIS web server and used another open source software, Lizmap, to enable 
queries and pop-ups on the web map. The authors argue their methodology is "an example of how Open Source technology can help to 
improve and fasten up processes of implementing, aggregating, categorizing and symbolzing geo data for effective mapping" (p. 178).

This study provides a strong case for the ability of open source tools to improve accessibility and efficiency of data management 
in administrative environments. Not only do the authors provide a reproducible methodology with source code, but they also automate 
the processes previously performed in proprietary GIS. As a result, the calculation of land values and public web mapping processes 
becomes not only more accessible but also more efficient. This may benefit government offices at the local scale by allowing them to 
perform these operations internally or at a lower cost. It could also further democratize the cadastre valuation, as citizens have 
access to the data and could hypothetically take part in the valuation process. Despite the positive aspects of this study, the authors 
do not provide a clear answer as to *how* reproducible this study. This is may stem from the lack of standardization of cadastral data 
both across and within countries and municipalities. Thus, an attempt to employ the same methods with different parcel data could
prove more complicated than simply modifying the parameters within the source code. Furthermore, some of the relevant geo data that 
could be used to further specify cadastre valuations and standard value zones might not be publicly available in certain areas. 
Regardless of these potential barriers, this study still employs free and open source softwares in a manner that improves and demo-
cratizes similar methods applied with proprietary software. 

Ostadabbas, H., Weippert, F., & F.J. Behr. (2019). Database transformation, cadastre automatic data processing in QGIS and 
implementation in web GIS. *ISPRS--The International Archives of Photogrammetry, Remote Sensing and Spatial information 
Sciences, Volume XLII-4/W14, 175-178*.
https://doi.org/10.5194/isprs-archives-XLII-4-W14-175-2019 
