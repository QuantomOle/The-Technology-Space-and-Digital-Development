#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%
#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%
# Spatial inequalities
# 2021-07-02
# Build technology space network
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

node_info <- fread("https://raw.githubusercontent.com/QuantomOle/The-Technology-Space-and-Digital-Development/main/data/node_info.csv")

edge_list <- fread("https://raw.githubusercontent.com/QuantomOle/The-Technology-Space-and-Digital-Development/main/data/edge_list.csv")

#%#%#%#%#%#%#%#%#%#%
# Create Network
#%#%#%#%#%#%#%#%#%#%

# Creating dedicated dataframes for nodes and edges including node attributes and optional edge weights
nodes <- node_info
edges <- edge_list %>% select(tag1,tag2,co_occurance_count,lift)

# Creating the network
coocNet <- graph_from_data_frame(d=edges, vertices=nodes, directed=FALSE)
class(coocNet)

#%#%#%#%#%#%#%#%#%#%
# Export for use in Gephi
#%#%#%#%#%#%#%#%#%#%

# Set your path via setting your working directory (setwd()) or choose any other path where to save the network
path = paste(getwd(),"/cooc_network.graphml", sep="")

write_graph(coocNet, path, format = "graphml")


