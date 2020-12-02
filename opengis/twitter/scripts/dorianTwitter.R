#search geographic twitter data for Hurricane Dorian, by Joseph Holler, 2019
#to search, you first need a twitter API token: https://rtweet.info/articles/auth.html 

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

############# SEARCH TWITTER API ############# 

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


#get tweets without any text filter for the same geographic region in November, searched on November 19, 2019
#the query searches for all verified or unverified tweets, so essentially everything
november <- search_tweets("-filter:verified OR filter:verified", 
                          n=200000, 
                          include_rts=FALSE, 
                          token=twitter_token, 
                          geocode="32,-78,1000mi", 
                          retryonratelimit=TRUE)

############### UPLOAD RESULTS TO POSTGIS DATABASE ###############

#Connectign to Postgres
#Create a con database connection with the dbConnect function.
#Change the database name, user, and password to your own!
con <- dbConnect(RPostgres::Postgres(), 
                 dbname='yourname', 
                 host='yourhost', 
                 user='youruser', 
                 password='yourpassword*') 

#list the database tables, to check if the database is working
dbListTables(con) 

#create a simple table for uploading
dorain <- select(dorain,c("user_id","status_id","text","lat","lng"),starts_with("place"))

#write data to the database
#replace new_table_name with your new table name
#replace dhshh with the data frame you want to upload to the database 
dbWriteTable(con,'dorain',dorian, overwrite=TRUE)
dbWriteTable(con,'november',november, overwrite=TRUE)

#SQL to add geometry column of type point and crs NAD 1983: 
#SELECT AddGeometryColumn ('public','winter','geom',4269,'POINT',2, false);
#SQL to calculate geometry: update winter set geom = st_transform(st_makepoint(lng,lat),4326,4269);

#get a Census API here: https://api.census.gov/data/key_signup.html
#replace the key text 'yourkey' with your own key!
Counties <- get_estimates("county",
                          product="population",
                          output="wide",
                          geometry=TRUE,
                          keep_geo_vars=TRUE, 
                          key="yourkey")

#make all lower-case names for this table
counties <- lownames(Counties)
dbWriteTable(con,'counties',counties, overwrite=TRUE)
#SQL to update geometry column for the new table: select populate_geometry_columns('westcounties'::regclass);

#disconnect from the database
dbDisconnect(con)

############# TEXT / CONTEXTUAL ANALYSIS ############# 

dorian$text <- plain_tweets(dorian$text)

dorianText <- select(dorian,text)
dorianWords <- unnest_tokens(dorianText, word, text)

# how many words do you have including the stop words?
count(dorianWords)

#create list of stop words (useless words) and add "t.co" twitter links to the list
data("stop_words")
stop_words <- stop_words %>% add_row(word="t.co",lexicon = "SMART")

dorianWords <- dorianWords %>%
  anti_join(stop_words) 

# how many words after removing the stop words?
count(dorianWords)

dorianWords %>%
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

dorianWordPairs <- dorianWords %>% select(word) %>%
  mutate(word = removeWords(word, stop_words$word)) %>%
  unnest_tokens(paired_words, word, token = "ngrams", n = 2)

dorianWordPairs <- separate(dorianWordPairs, paired_words, c("word1", "word2"),sep=" ")
dorianWordPairs <- dorianWordPairs %>% count(word1, word2, sort=TRUE)

#graph a word cloud with space indicating association. you may change the filter to filter more or less than pairs with 10 instances
dorianWordPairs %>%
  filter(n >= 30) %>%
  graph_from_data_frame() %>%
  ggraph(layout = "fr") +
  # geom_edge_link(aes(edge_alpha = n, edge_width = n)) +
  geom_node_point(color = "darkslategray4", size = 3) +
  geom_node_text(aes(label = name), vjust = 1.8, size = 3) +
  labs(title = "Word Network: Tweets Hurricane Dorian",
       subtitle = "September 2019 - Text mining twitter data ",
       x = "", y = "") +
  theme_void()




