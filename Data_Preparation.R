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
library(arules)       # Association rules (for network links)
library(widyr)        # Super fast functions for long to wide operations

# Useful commands
'%!in%' <- function(x,y)!('%in%'(x,y)) # opposite of %in% command
options(stringsAsFactors = FALSE)

#%#%#%#%#%#%#%#%#%#%
# Load data and simple data cleaning
#%#%#%#%#%#%#%#%#%#%

# Read the huge data frame using the data.table package
df <- fread("/Users/oleteutloff/Desktop/Data/Stack_overflow/2018-08-13 Contributions.csv")

# Filter those rows that actually have tags
df <- df %>% filter(tags != "")

# keep only relevant columns
df <- df %>% dplyr::select(id, creation_date, Country, tags)

# extract year from date
df$year <- format(as.Date(df$creation_date),"%Y")

# Limit to 2017 (for now) - Not necessary anymore
#df <- df %>% filter(year == 2017)

# exclude duplicate ids: there 132 ids that are not unique. I exclude them
df <- df %>% distinct()

# Still duplicates remaining
ids_duplicate <- as.data.frame(table(df$id)) %>% filter(Freq > 1) %>% select(Var1)
df <- df %>% filter(id %!in% ids_duplicate$Var1)


####################################
#### Extract and manipulate tags ###
####################################

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

### Exclude all tags that do not appear in our wikipedia matching table

# final solution when wiki-matching is complete
#df_wiki <- fread("/Users/oleteutloff/Desktop/Data/wikipedia_matching/wiki_match.csv")
#df_wiki <- df_wiki %>% filter(Wikipedia != "")

# df.expanded <- df.expanded %>% filter(tags %in% df_wiki$tag)


# provisional solution - Some how we lose 47 technology tags
df_wiki <- fread("/Users/oleteutloff/Desktop/Data/wikipedia_matching/wiki_provisional.csv")
df.expanded <- df.expanded %>% filter(tags %in% df_wiki$tag)


### Extract in which year a technology appeared for the first time
first_appearance <- df.expanded %>% group_by(tags) %>% summarise(min(year)) %>% rename(year_appeared="min(year)")
# table(first_appearance$`min(year)`) # number of new tags decreases over time. 

# Save this table for use in the network 
write.csv(first_appearance,"/Users/oleteutloff/Desktop/Data/tag_first_appearance.csv", row.names = FALSE)

############################################
### Create tag matrix to calculate lift ###
############################################

# select only necessary columns
df_matrix <- df.expanded %>% dplyr::select(tags,id) 

# delete everything else to free up memory - not strictly necessary
rm(df,df_wiki,df.expanded, ids_duplicate, tags)

## Counting co-occurance using very promising approach from widyr library - It works super fast! Avoids creating super large sparse matrix
cooccurance_count <- widyr::pairwise_count(df_matrix, tags, id) # function from library(widyr)

# Counting total occurance of each tag
single_count <- df_matrix %>% count(tags)

## Merging the two together (twice to have count of item1 and item2)
single_count <- rename(single_count, tag1_count = n)
# merge
cooccurance_count <- cooccurance_count %>% left_join(single_count, by = c("item1" = "tags"))
# rename for clarity
single_count <- rename(single_count, tag2_count = tag1_count)
# merge again to have also count for item 2 
cooccurance_count <- cooccurance_count %>% left_join(single_count, by = c("item2" = "tags"))

# Adding total number of observations
cooccurance_count$total_num_obs <- length(unique(df_matrix$id))

# Renaming remaining columns
cooccurance_count <- rename(cooccurance_count, tag1 = item1, tag2 = item2, co_occurance_count = n)

# Transform integers to doubles - to avoid integer overflow error that introduces NAs
cooccurance_count$tag1_count <- as.double(cooccurance_count$tag1_count)
cooccurance_count$tag2_count <- as.double(cooccurance_count$tag2_count)
cooccurance_count$total_num_obs <- as.double(cooccurance_count$total_num_obs)

# Calculating lift
cooccurance_count$lift <- (cooccurance_count$co_occurance_count*cooccurance_count$total_num_obs)/(cooccurance_count$tag1_count*cooccurance_count$tag2_count)

# keep only connections with lift > 1
cooccurance_count <- cooccurance_count %>% filter(lift > 1)

# removing the duplicates in edge list (because we will build an undirected network)
no_duplicates <- cooccurance_count[!duplicated(t(apply(cooccurance_count, 1, sort))),]

# Check if there are still all tags
data_check <- c(no_duplicates$tag1, no_duplicates$tag2)
length(unique(data_check)) == length(unique(df_matrix$tags))

# Export data to .csv for upload to Github and use to build the technology space network
write.csv(no_duplicates,"/Users/oleteutloff/Desktop/Data/edge_list.csv", row.names = FALSE)


