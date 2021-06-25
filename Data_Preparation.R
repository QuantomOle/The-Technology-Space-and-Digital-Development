#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%
#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%
# Spatial inequalities
# 2021-06-21
# Prepare data for network creation
# Ole Teutloff
#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%
#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%

#%#%#%#%#%#%#%#%#%#%
# Loading packages
#%#%#%#%#%#%#%#%#%#%
library(tidyverse)    # numerous data wrangling packages
library(data.table)   # quick data loading
library(lubridate)    # Working with dates

# Useful commands
'%!in%' <- function(x,y)!('%in%'(x,y)) # opposite of %in% command
options(stringsAsFactors = FALSE)

#%#%#%#%#%#%#%#%#%#%
# Load data
#%#%#%#%#%#%#%#%#%#%

# Read the huge data frame using the data.table package
df <- fread("/Users/oleteutloff/Desktop/Data/Stack_overflow/2018-08-13 Contributions.csv")

# Filter those rows that actually have tags
df <- df %>% filter(tags != "")

# keep only relevant columns
df <- df %>% dplyr::select(id, creation_date, Country, tags)

# extract year from date
df$year <- format(as.Date(df$creation_date),"%Y")

# Limit to 2017 (for now)
df <- df %>% filter(year == 2017)

# exclude duplicate ids: there 132 ids that are not unique. I exclude them
df <- df %>% distinct()
# Still duplicates remaining
test <- as.data.frame(table(df$id))
ids_duplicate <- test %>% filter(Freq > 1) %>% select(Var1)
df <- df %>% filter(id %!in% ids_duplicate$Var1)

#### Extract and manipulate tags ###
# transform tags from string into list of individual tags
df$tags_list <- list(strsplit(df$tags,"\\|"))

# Break the list into one large vector
tags <- unlist(df$tags_list)

# Add the number of tech-tags per post to the post dataframe
df$number_tags <- sapply(df$tags_list,length)

# Turn df into a data frame (it used to be a 'data.table')
df <- data.frame(df)

# Use the broken-up tag list and the number of categories per firm to create one large panel dataframe
df.expanded <- df[rep(row.names(df), df$number_tags),]
df.expanded$tags <- tags

### Exclude all tags that do not appear in our wikipedia matching table ###

df_wiki <- fread("/Users/oleteutloff/Desktop/Data/wikipedia_matching/wiki_match.csv")
df_wiki <- df_wiki %>% filter(Wikipedia != "")

df.expanded <- df.expanded %>% filter(tags %in% df_wiki$tag)

### create adjacency matrix - NOT QUITE WHAT WE ARE DOING ###

df_matrix <- df.expanded %>% dplyr::select(tags,id) 
df_matrix$value <- 1
wrkb_mtrx <- spread(head(df_matrix,100), tags, value, fill = 0) # solve the memory ERROR!

rownames(wrkb_mtrx) <- wrkb_mtrx$id
wrkb_mtrx <- wrkb_mtrx %>% dplyr::select(-id)







