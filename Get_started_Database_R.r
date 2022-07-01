#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%
# Tutrial of how to get started with data on MongoDB #
# 27-06-2022 | Ole Teutloff
#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%
#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%

library(mongolite)
library(tidyverse)

# Place the .env file in the same folder as the R script
readRenviron(".env")
connection_string = Sys.getenv("CONNECTION_STRING")

# Create connection to database
SO_data = mongo(db="stackoverflow", collection="country_tags_2018", url=connection_string)

# Collect the data from the database
# inlcude columns by setting them to true
# there are several filtering options available. See mongolite documentation for details

data <- SO_data$find(fields = '{"Country": true, "tags" : true, "count" : true}')


# Raw Data
SO_raw = mongo(db="stackoverflow", collection="stackoverflow", url=connection_string)

data <- SO_raw$find(fields = '{"Country": true, "tags" : true, "creation_date" : true, "owner_user_id":true}')



