#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%
#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%
# Spatial inequalities
# 2021-07-02
# Build technology space network and prepare visualization
# Ole Teutloff
#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%
#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%

#%#%#%#%#%#%#%#%#%#%
# Loading packages
#%#%#%#%#%#%#%#%#%#%
library(tidyverse)    # numerous data wrangling packages
library(data.table)   # quick data loading

library(igraph)       # Network package
library(network)      # Network package
library(ggnetwork)    # Plotting networks

library(RColorBrewer) # Nice colours for plots
library(ggpubr)       # Arrange multiple plots

# Useful commands
'%!in%' <- function(x,y)!('%in%'(x,y)) # opposite of %in% command
options(stringsAsFactors = FALSE)


#%#%#%#%#%#%#%#%#%#%
# Load data directly from github
#%#%#%#%#%#%#%#%#%#%

node_info <- read.csv("https://raw.githubusercontent.com/QuantomOle/The-Technology-Space-and-Digital-Development/main/data/tag_first_appearance.csv")

# unclear why this is not working at the moment. Data is not importated correctly. Seems the data structures is changes to different encoding while upload or something like this
#edge_list <- read.csv("https://raw.githubusercontent.com/QuantomOle/The-Technology-Space-and-Digital-Development/main/data/edge_list.csv", fileEncoding="UTF-16LE")

edge_list <- read.csv("/Users/oleteutloff/Desktop/Data/edge_list.csv")




#%#%#%#%#%#%#%#%#%#%
# Create Network
#%#%#%#%#%#%#%#%#%#%

# select relevant variables only
edge_list <- edge_list %>% select(tag1,tag2,lift)

# Create network
coocNet<-network(edge_list,
                 matrix.type='edgelist',
                 directed=F,
                 ignore.eval=FALSE,  # confusingly, this tells it to include edge weights
                 names.eval=c("lift")  # names for the edge weights
)


#%#%#%#%#%#%#%#%#%#%
# Add information to the nodes
#%#%#%#%#%#%#%#%#%#%








#%#%#%#%#%#%#%#%#%#%
# Export for use in Gephi
#%#%#%#%#%#%#%#%#%#%

write_graph(coocNet, "/Users/oleteutloff/Desktop/Data/cooc_network.graphml", format = "graphml")


