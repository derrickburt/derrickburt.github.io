## load libraries ----------
library(shiny)
library(shinythemes)
library(tidyverse)
library(tidytext)
library(stringr)
library(rgdal)
library(rvest)
library(dplyr)
library(leaflet)
library(geojsonio)
library(ggplot2)
library(RColorBrewer)

## Load Data ----------
### VT Parcel Data from https://geodata.vermont.gov/datasets/vt-data-statewide-standardized-parcel-data-parcel-polygons-1?geometry=-80.362%2C42.481%2C-64.541%2C45.252
### VT County geojson from https://github.com/codeforamerica/click_that_hood/blob/master/public/data/vermont-counties.geojson 
### VT Towns Population data https://en.wikipedia.org/wiki/List_of_towns_in_Vermont 

# load data
vtParcels <- read_csv("parcelsFinal.csv")
vtCounties <- geojson_read("vtCounties.geojson",
                           what = "sp")
vtCounties.copy <- geojson_read("vtCounties.geojson",
                                what = "sp")
vtTowns <- geojson_read("vtTowns.geojson",
                        what = "sp")
vtTowns.copy <- geojson_read("vtTowns.geojson",
                             what = "sp")

# remove outliers from VT parcels
vtParcels.no.outliers <- vtParcels %>% 
    filter(lv.acre > 5 & lv.acre < 11500000)

# group parcel values by category and summarize by median and avg val
vtParcels.cat <- vtParcels %>% 
    group_by(category) %>% 
    summarize(median.val = median(lv.acre),
              mean.val = mean(lv.acre)) %>% 
    mutate_at(vars(starts_with("me")), funs(round(., 2)))

## Prepare Maps -------
# bins
## counties
binsC <- c(19000, 25000, 55000, 75000, 100000, 150000, 230000)
colorsC <- colorBin(palette = "Greens",
                           bins = binsC,
                           domain = vtCounties@data$median.val)

binsT <- c(250, 1000, 10000, 50000, 100000, 250000, 500000, 1000000, Inf)
colorsT <- colorBin(palette = "Greens",
                    bins = binsT,
                    domain = vtTowns@data$median.val)
# maps
map0 <-leaflet() %>% 
    addProviderTiles(providers$CartoDB.Positron) %>% 
    setView(-72, 44, 7)

map1 <- vtCounties %>% 
    leaflet()
    
map2 <- vtTowns %>% 
    leaflet() 
    

## UI -------
# Define UI for application that draws a histogram
ui <- fluidPage(theme = shinytheme("yeti"),
                navbarPage("Exploring Vermont's Land Values",
                           tabPanel("About",
                                    tags$h3(strong("Introduction:")),
                                    p(HTML("This app  allows users to explore Vermont's land values. This study measures land value at the parcel level, which divides land up by individual 
                                            plot ownership for taxation and land use. The 'Methods' panel describes the data and methodology. The 'Summary Statistics' tab allows users to compare 
                                            the distribution of values from a selected county against the distribution of values in the entire state and look at the breakdown of parcel values by 
                                            different use classifications (residential, commerical, etc.). The 'Maps' panel allows users to explore the median parcel price at different geographic scales. 
                                            Verbal descriptions of the results are provided with their accompanying graphics.")),
                                    p(HTML("Using this app, the user should be able to answer the following questions: <br/><br/>
                                             1) How does the distribution of land values in a given county compare to the distribution across the whole state? <br/><br/>
                                                2) On average, how expensive are different categories of real estate in Vermont? <br/><br/>
                                                    3) What are the median parcel values in Vermont's counties and towns? On average, where is the most and least expensive land in Vermont?")),
                                    br(),
                                    br(),
                                    img(src = "parcels.jpg", height = "300", width = "300"),
                                    tags$h6("Source: VCGI",
                                            style = "font-size:8px;")),
                           tabPanel("Methods",
                                    tags$h3(strong("Data:")),
                                    p(HTML("The parcel data for this project comes from the <a href='https://geodata.vermont.gov/datasets/e12195734d38410185b3e4f1f17d7de1_1'>Vermont Center for Geographic Information (VCGI)</a>. The parcel data is updated weekly. The data for this app was downloaded on December 5th, 2020. 
                                            The dataset consists of all parcels in the entire state of Vermont, a total of 336,072 parcels. I removed all parcels that were listed at 0 acres and all parcels valued at $0. There was no explanation for these 0 acre and $0 parcels in the metadata, so I assumed 
                                            they were errors. This left 296,064 parcels for the analysis. The mathematical outliers are parcels valued over $11,115,000/acre - removing them would leave a total of 295,760 parcels. I chose, however, to include these mathematical outliers, because users should be able to see the most 
                                            expensive parcels. This way we can observe the full range of the distribution. The parcel data comes with a few different price values - this analysis uses 'REAL_FLV', the listed real estate value, which accounts for the price of the land as well as the built structures on the parcel.")),
                                    br(),
                                    p(HTML("The geojson file of county data came from <a href='https://github.com/codeforamerica/click_that_hood/blob/master/public/data/vermont-counties.geojson'>Code for America's github</a>. There was no publicly available geojson file of Vermont towns, so I downloaded a shapefile
                                             from <a href='https://geodata.vermont.gov/datasets/0e4a5d2d58ac40bf87cd8aa950138ae8_39'>VCGI's Open Geodata Portal</a> and converted it to a geojson file in R.")),
                                    br(),
                                    img(src = "vcgiClear.png", height = "125", width = "400"),
                                    tags$h6("Source: VCGI",
                                            style = "font-size:8px;"),
                                    br(),
                                    tags$h3(strong("Methods:")),
                                    p(HTML("The 'Summary Statistics' tab has two primary visualizations. The first compares the density of the distribution of parcel values per acre for the whole state against the density of the distribution of a selected county. The data for this visualization has been logarthmically
                                            transformed to control for skew. The second visualization shows users a break-down of the median values (in $/acre) of Vermont parcels based on their category. The data for this represents the true prices (ie. no log transformation), so I use median value instead of the mean to control 
                                            for skew and to give a more accurate representation of the center. The value is measured per acre to control for different sized parcels.")),
                                    br(),
                                    p(HTML("The 'Maps' tab allows users to see the median value of parcels (in $/acre) at the town and county level. To prepare these maps, the data were grouped by their respective geographies, summarized by their median value at 
                                             both scales, and then joined to the town and county geojson files. The value is measured per acre to control for different sized parcels."))),
                           tabPanel("Summary Statistics",
                                    sidebarPanel(tags$h4(strong("Input a County:")),
                                                 selectizeInput(inputId = "inputCounty",
                                                                label = "Choose a County to Compare to State Distribution",
                                                                choices = unique(vtParcels.no.outliers$county)),
                                                 tags$h5(strong("Distribution Summary:")),
                                                 tags$h6("*Note: Unlike the density plot, the values below have not been logarithmically transformed.",
                                                         style = "font-size:8px;"),
                                                 tags$h6("Distribution of State Values ($/acre)"),
                                                 tableOutput(outputId = "table1"),
                                                 tags$h6("Distribution of County Values ($/acre)"),
                                                 tableOutput(outputId = "table2"),
                                                 tags$h6("Difference of County from State (Cty - State)"),
                                                 tableOutput(outputId = "table3"),
                                                 tags$br(),
                                                 tags$br(),
                                                 tags$br(),
                                                 tags$br(),
                                                 tags$h5(strong("Parcel Category Summary:")),
                                                 tags$h6("Distribution of Values by Category:"),
                                                 tableOutput(outputId = "table4")
                                    ),
                                    mainPanel(tags$br(),
                                              plotOutput(outputId = "plot1"),
                                              tags$br(),
                                              tags$h6("The distribution of (log transformed) parcel values in Vermont has a slightly right-skewed distribution that is approaching normal. Chittenden's and Grand Isle's distributions are more left-skewed than the state's, showing larger proportions of higher-value real estate. Addison, Orleans, Windsor, Windham, and Orange have a similar shape but are further left on the graph, indicating higher 
                                                        proprtions of lower value parcels. Bennington, Washington, Rutland, and Lamoille have a higher proportion of middle-range parcel values and smaller proportions of higher range values. Essex and Caledonia have more uniform distributions than the state, 
                                                        with similar amounts of cheap, middle-range, and expensive real estate."),
                                              tags$br(),
                                              tags$br(),
                                              plotOutput(outputId = "plot2"),
                                              tags$br(),
                                              tags$h6("Commercial parcels have, by far, the highest median price at $395,769.23/acre - more than twice as expensive than the median value for any other parcel category. Industrial ($148,322.26/acre), Residential ($145,254.9/acre), and Utiltiy ($109,629.63/acre) parcels 
                                                        are the next most expensive, with similar median parcel values. In the middle are Seasonal ($50,800/acre) and Mobile Home ($54,016.53/acre) parcels. Miscellaneous ($9791.17/acre), Farm ($3,007/acre), and Woodland ($1618/acre) parcels had the least expensive median
                                                        value per acre.")),
                           ),
                           tabPanel("Maps",
                                    tags$h3("Map Median Parcel Values:"),
                                    selectInput(inputId = "inputMap",
                                                label = "Choose a Scale to Map the Data:",
                                                choices = c("County",
                                                            "Town"),
                                                selected = "Choose Scale"),
                                    leafletOutput(outputId = "map1"),
                                    # plotOutput(outputId = "plot3"),
                                    tags$h6("The counties with the highest median parcel values are Chittenden ($225,818.18/acre) and Grand Isle ($159,500/acre). The counties with the lowest median parcel value are Essex ($19,859.8/acre), Orleans ($21,490.57/acre), and Orange ($24,099.15/acre). The towns with the highest 
                                             median parcel values are Burlington ($1,394,750), Winooski ($1,207,161.65), South Burlington ($1,096,239.75). The towns with lowest median parcel values are Lewis ($332.36/acre), Gore ($413.97), Grant ($606.89).")
                                    )
                )
)


## SERVER ------
# Define server logic required to draw a histogram
server <- function(input, output, session) {
    
    output$table1 <- renderTable({
        vtParcels %>% 
            summarize(medianState = median(lv.acre),
                      minState = min(lv.acre),
                      maxState = max(lv.acre))
    })
    
    output$table2 <- renderTable({
        vtParcels %>% 
            filter(county == input$inputCounty) %>% 
            summarize(medianCty = median(lv.acre),
                      minCty = min(lv.acre),
                      maxCty = max(lv.acre))
    })
    
    output$table3 <- renderTable({
        vtParcels%>% 
            filter(county == input$inputCounty) %>% 
            summarize(medianDiff = (median(lv.acre) - 105009.09),
                      minDiff = (min(lv.acre) - 10.12),
                      maxDiff = (max(lv.acre) - 11450000.00))
    })
    
    output$table4 <- renderTable({
        vtParcels %>% 
            group_by(category) %>% 
            summarize(min = min(lv.acre),
                      max = max(lv.acre))
    })

    output$plot1 <- renderPlot({
        options(scipen=10000)
        
        vtParcels %>% 
            ggplot() + 
            geom_density(aes(x = lv.acre,
                             fill = county %in% input$inputCounty),
                         color = "gray",
                         alpha = 0.6) +
            scale_fill_manual(values = c("darkgreen",
                                         "darkseagreen2"),
                              labels = c("All Counties (Total)",
                                         "Selected Counties (Input)")) +
            labs(fill = "Distribution") +
            xlab("Parcel Value (in log10$/Acre) **logarithmic transformation to control for skew**") +
            ylab("Density") +
            ggtitle("Density of All Parcel Values against Density of Input County Values") +
            theme(plot.title = element_text(hjust = 0.5,
                                            size = 15,
                                            face = "bold"),
                  panel.grid.major = element_blank(), 
                  panel.grid.minor = element_blank(),
                  panel.background = element_rect(fill = "transparent", colour = NA),
                  plot.background = element_rect(fill = "transparent", colour = NA)) +
            scale_x_continuous(trans = 'log10')
    })
    
    output$plot2 <- renderPlot({
        vtParcels.cat %>% 
            ggplot(aes(x = reorder(category, median.val),
                       y = median.val)) +
            geom_col(fill = "darkgreen",
                     alpha = 0.8) +
            geom_text(aes(label = median.val),
                      color = "gray25",
                      size = 2,
                      angle = .45,
                      position = position_dodge(width=0.9),
                      hjust = -0.05) +
            xlab("Parcel Category") +
            ylab("Median Parcel Value ($/Acre)") +
            ggtitle("Median Parcel Value by Category") +
            theme(plot.title = element_text(hjust = 0.5,
                                            size = 15,
                                            face = "bold"),
                  panel.grid.major = element_blank(), 
                  panel.grid.minor = element_blank(),
                  panel.background = element_rect(fill = "transparent", colour = NA),
                  plot.background = element_rect(fill = "transparent", colour = NA)) +
            coord_flip()
    })
    
    x <- reactive({input$inputMap})
    
    output$map1 <- renderLeaflet({
        if (x() == "County") {
            map1 %>% 
                addProviderTiles(providers$CartoDB.Positron) %>% 
                addPolygons(fillColor = ~colorsC(median.val),
                            color = "grey",
                            weight = .5,
                            fillOpacity = .8,
                            popup = paste("County Name:",
                                          vtCounties@data$name,
                                          "<br>",
                                          "Median Parcel Value $/Acre:",
                                          vtCounties@data$median.val,
                                          "<br>")) %>% 
                addLegend(pal = colorsC,
                          values = vtCounties@data$median.val,
                          title = "Median Parcel Value ($/Acre)",
                          opacity = .7,
                          position = "bottomright") %>% 
                setView(-72, 44, 7)
        } 
        else {
            map2 %>% 
                addProviderTiles(providers$CartoDB.Positron) %>% 
                addPolygons(fillColor = ~colorsT(median.val),
                            color = "grey",
                            weight = .5,
                            fillOpacity = .8,
                            popup = paste("Town Name:",
                                          vtTowns@data$TOWNNAMEMC,
                                          "<br>",
                                          "Median Parcel Value $/Acre:",
                                          vtTowns@data$median.val,
                                          "<br>")) %>% 
                addLegend(pal = colorsT,
                          values = vtTowns@data$median.val,
                          title = "Median Parcel Value ($/Acre)",
                          opacity = .7,
                          position = "bottomright") %>% 
                setView(-72, 44, 7)
        }
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
