###########################################
#Title: Bring stackoverflow daten in shape to construct network
        #Concept: 
                  # 1 load in data
                  # 2 calculate co-occurance matrix
                  # 3 export data to perform baclboning in Python
#Author: Alexandra Rottenkolber based on code from Ole Teutloff 
#Date: 02.07.2022
###########################################

library(mongolite)
library(tidyverse)
library(sys)
library(dplyr)

# Specify path to .env file
readRenviron("/Users/alexandrarottenkolber/Documents/05_Spatial_Inequalities/Alexandra/.env")
connection_string = Sys.getenv("CONNECTION_STRING")

# Create connection to database
CT_data = mongo(db="stackoverflow", collection="country_tags_2018", url=connection_string)
SO_data = mongo(db="stackoverflow", collection="stackoverflow", url=connection_string)

# Collect the data from the database
# include columns by setting them to true
# there are several filtering options available. See mongolite documentation for details

#data_country_tags <- SO_data$find(fields = '{"Country": true, "tags" : true, "count" : true}')
data_SO <- SO_data$find(fields = '{"id": true, "Country": true, "tags" : true}')




df <- as.data.frame(data)
typeof(df)

dataFrame <- data %>% 
  as_tibble()
typeof(dataFrame)

colnames(data)

data %>% filter("_id" == "61b778e8fc9434398d505a28")

data 

#df <- do.call(rbind.data.frame, data)

