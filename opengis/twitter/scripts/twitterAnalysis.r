#search and analyze twitter data, by Joseph Holler, 2019
#following tutorial at https://www.earthdatascience.org/courses/earth-analytics/get-data-using-apis/use-twitter-api-r/
#also get advice from the rtweet page: https://rtweet.info/
#to do anything, you first need a twitter API token: https://rtweet.info/articles/auth.html 

#install packages for twitter, census, data management, and mapping
install.packages(c("rtweet","tidycensus","tidytext","maps","RPostgres","igraph","tm", "ggplot2","RColorBrewer","rccmisc","ggraph"))


#initialize the libraries. this must be done each time you load the project
library(rtweet)
library(igraph)
library(dplyr)
library(tidytext)
library(tm)
library(tidyr)
library(ggraph)
library(tidycensus)
library(ggplot2)
library(RPostgres)
library(RColorBrewer)
library(DBI)
library(rccmisc)

help(rtweet) # put a library name or function in the help function to get help on anything!

#set up twitter API information
#this should launch a web browser and ask you to log in to twitter
#replace app, consumer_key, and consumer_secret data with your own developer acct info
twitter_token <- create_token(
  app = "yourapp",  					#replace yourapp with your app name
  consumer_key = "yourkey",  		#replace yourkey with your consumer key
  consumer_secret = "yoursecret",  #replace yoursecret with your consumer secret
  access_token = NULL,
  access_secret = NULL
)

#reference for search_tweets function: https://rtweet.info/reference/search_tweets.html 
#don't add any spaces in between variable name and value. i.e. n=1000 is better than n = 1000
#winterTweets will be a new data frame object holding the Twitter data found by search_tweets function
#the first parameter in quotes is the search string, searching tweet contents and hashtags
#n=10000 asks for 10,000 tweets
#if you want more than 18,000 tweets, change retryonratelimit to TRUE and wait 15 minutes for every batch of 18,000
#include_rts=FALSE excludes retweets.
#token refers to the twitter token you defined above for access to your twitter developer account
#geocode is equal to a string with three parts: longitude, latidude, and distance with the units mi for miles or km for kilometers

#try changing the region and the search parameters to something of your own interest in the past 3-4 days
winterTweets <- search_tweets("freeze OR ice OR snow", n=10000, retryonratelimit=FALSE, include_rts=FALSE, token=twitter_token, geocode="41,-76,200km")


############# TEMPORAL ANALYSIS ############# 

#create temporal data frame & graph it
winterTweetHours <- ts_data(winterTweets, by="hours")
ts_plot(winterTweets, by="hours")



############# FIND ONLY PRECISE GEOGRAPHIES ############# 

#reference for lat_lng function: https://rtweet.info/reference/lat_lng.html
#adds a lat and long field to the data frame, picked out of the fields you indicate in the c() list
#sample function: lat_lng(x, coords = c("coords_coords", "bbox_coords"))

# list unique/distinct place types to check if you got them all
unique(winterTweets$place_type)

# list and count unique place types
# NA results included based on profile locations, not geotagging / geocoding. If you have these, it indicates that you exhausted the more precise tweets in your search parameters
count(winterTweets, place_type)

#this just copied coordinates for those with specific geographies
#do not use geo_coords! Lat/Lng will come out inverted

#convert GPS coordinates into lat and lng columns
winterTweets <- lat_lng(winterTweets,coords=c("coords_coords"))

#select any tweets with lat and lng columns (from GPS) or designated place types of your choosing
winterTweetsGeo <- subset(winterTweets, place_type == 'city'| place_type == 'neighborhood'| place_type == 'poi' | !is.na(lat))

#convert bounding boxes into centroids for lat and lng columns
winterTweetsGeo <- lat_lng(winterTweetsGeo,coords=c("bbox_coords"))



############# NETWORK ANALYSIS ############# 

#create network data frame. Other options for 'edges' in the network include
winterTweetNetwork <- network_graph(winterTweetsGeo, c("quote"))

plot.igraph(winterTweetNetwork)
#Please, this is incredibly ugly... if you finish early return to this function and see if we can modify its parameters to improve aesthetics



############# TEXT / CONTEXTUAL ANALYSIS ############# 

winterTweetsGeo$text <- plain_tweets(winterTweetsGeo$text)

winterText <- select(winterTweetsGeo,text)
winterWords <- unnest_tokens(winterText, word, text)

# how many words do you have including the stop words?
count(winterWords)

#create list of stop words (useless words) and add "t.co" twitter links to the list
data("stop_words")
stop_words <- stop_words %>% add_row(word="t.co",lexicon = "SMART")

winterWords <- winterWords %>%
  anti_join(stop_words) 

# how many words after removing the stop words?
count(winterWords)

winterWords %>%
  count(word, sort = TRUE) %>%
  top_n(15) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(x = word, y = n)) +
  geom_col() +
  xlab(NULL) +
  coord_flip() +
  labs(x = "Count",
       y = "Unique words",
       title = "Count of unique words found in tweets")

winterWordPairs <- winterTweetsGeo %>% select(text) %>%
  mutate(text = removeWords(text, stop_words$word)) %>%
  unnest_tokens(paired_words, text, token = "ngrams", n = 2)

winterWordPairs <- separate(winterWordPairs, paired_words, c("word1", "word2"),sep=" ")
winterWordPairs <- winterWordPairs %>% count(word1, word2, sort=TRUE)

#graph a word cloud with space indicating association. you may change the filter to filter more or less than pairs with 10 instances
winterWordPairs %>%
  filter(n >= 10) %>%
  graph_from_data_frame() %>%
  ggraph(layout = "fr") +
  # geom_edge_link(aes(edge_alpha = n, edge_width = n)) +
  geom_node_point(color = "darkslategray4", size = 3) +
  geom_node_text(aes(label = name), vjust = 1.8, size = 3) +
  labs(title = "Word Network: Tweets during the 2013 Colorado Flood Event",
       subtitle = "September 2013 - Text mining twitter data ",
       x = "", y = "") +
  theme_void()

############# SPATIAL ANALYSIS ############# 

#get a Census API here: https://api.census.gov/data/key_signup.html
#replace the key text 'yourkey' with your own key!
Counties <- get_estimates("county",product="population",output="wide",geometry=TRUE,keep_geo_vars=TRUE, key="yourkey")

#select only the states you want, with FIPS state codes in quotes in the c() list
#Warning: I missed washington DC in this list! It's selecting by FIPS codes
#look up fips codes here: https://en.wikipedia.org/wiki/Federal_Information_Processing_Standard_state_code 
NorthEastCounties <- filter(Counties,STATEFP %in% c("09","25","33","44","54","50","36","42","24","10","34","51","39") )

#map results with GGPlot
#note: cut_interval is an equal interval classification function, while cut_numer is a quantile / equal count function
#you can change the colors, titles, and transparency of points
ggplot() +
  geom_sf(data=NorthEastCounties, aes(fill=cut_number(DENSITY,5)), color="grey")+
  scale_fill_brewer(palette="GnBu")+
  guides(fill=guide_legend(title="Population Density"))+
  geom_point(data = winterTweetsGeo, aes(x=lng,y=lat),
             colour = 'purple', alpha = .5) +
  labs(title = "Tweet Locations During first Winter Weather")+
  theme(plot.title=element_text(hjust=0.5),
        axis.title.x=element_blank(),
        axis.title.y=element_blank())
  


############### UPLOAD RESULTS TO POSTGIS DATABASE ###############

#Connectign to Postgres
#Create a con database connection with the dbConnect function.
#Change the database name, user, and password to your own!
con <- dbConnect(RPostgres::Postgres(), dbname='yourdatabase', host='artemis', user='yourUserName', password='yourPassword') 

#list the database tables, to check if the database is working
dbListTables(con) 

#create a simple table for uploading
winter <- select(winterTweetsGeo,c("user_id","status_id","text","lat","lng"),starts_with("place"))

#write data to the database
#replace new_table_name with your new table name
#replace dhshh with the data frame you want to upload to the database 
dbWriteTable(con,'winter',winter, overwrite=TRUE)

#SQL to add geometry column of type point and crs NAD 1983: 
#SELECT AddGeometryColumn ('public','winter','geom',4269,'POINT',2, false);
#SQL to calculate geometry: update winter set geom = st_transform(st_makepoint(lng,lat),4326,4269);

#make all lower-case names for this table
necounties <- lownames(NorthEastCounties)
dbWriteTable(con,'necounties',necounties, overwrite=TRUE)
#SQL to update geometry column for the new table: select populate_geometry_columns('necounties'::regclass);

#disconnect from the database
dbDisconnect(con)
