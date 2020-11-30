# Spatial and Temporal Analysis of Twitter Activity during Hurricane Dorian

### Purpose

The purpose of this exercise is to analyze the geographic and temporal distribution of Tweets in the Eastern United States during Hurricane Dorian. In the process of this, we will cover a number off things. First, we will practice scraping twitter data in R using [rtweet](https://cran.r-project.org/web/packages/rtweet/rtweet.pdf), cleaning it, and visualizing its temporal trends and performing sentiment analysis. Then, we will send the data to a PostGIS database to join it to county level data and count the level of tweets by county. Then, we will visualize the data with a heatmap of raw tweets and a choropleth of the NDTI (Normalized Tweet Difference Index). Finally, we will use GeoDa to perform a spatial hotspot analysis.

### Software

The following softwares were used to complete this exercise:

* [QGIS 3.10](https://qgis.org/en/site/forusers/download.html)
* [PostgreSQL with PGAdmin 4 v4.26](https://www.pgadmin.org/download/pgadmin-4-macos/)
* [RStudio](https://rstudio.com/products/rstudio/download/)
* [GeoDa](https://geodacenter.github.io/download.html)

### Data

Some of the relevant data for this project will be acquired (with explanation) while the scripts are run. Other data, specifically the actualy twitter content, requires a Twitter API (developer account) to use.

You can download the status ID's for the tweets analyzed in this exercise here:
* [Dorian Tweets](data/dorianData.csv)
* [November Tweets](data/novemberData.csv)

### Twitter Content Analysis in R

The first portion of this analysis consists of scraping twitter data into R and performing some analyses of the twitter content. You can download the entire [R script](scripts/dorianTwitter.R) but I will walk through some of the code as well.

<detials><summary markdown="snap">Once you have installed the necesarry packages and loaded them into you library, you can load your API information into R and start scraping twitter data. This requires an API and you can only scrape tweets from the past week.</summary>
```r
#set up twitter API information
#this should launch a web browser and ask you to log in to twitter
#replace app, consumer_key, and consumer_secret data with your own developer acct info
twitter_token <- create_token(
  app = "name",  					
  consumer_key = "key",  	
  consumer_secret = "secret", 
  access_token = "token",
  access_secret = "secret"
)

#get tweets for hurricane Dorian, searched on September 11, 2019
dorian <- search_tweets("dorian OR hurricane OR sharpiegate", 
                        n=200000,
                        include_rts=FALSE, 
                        token=twitter_token, 
                        geocode="32,-78,1000mi", 
                        retryonratelimit=TRUE)
```
</details>
<br/>

census api: https://api.census.gov/data/key_signup.html
