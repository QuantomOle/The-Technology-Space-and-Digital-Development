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
# Changing year of appearance form long to wide for easier visualization
#%#%#%#%#%#%#%#%#%#%

node_info$value <- 1
node_info$year <- node_info$year_appeared

node_info <- node_info %>% arrange(year) %>% pivot_wider(names_from = year, values_from = value) %>% mutate_at(vars(starts_with("20")), ~replace(., is.na(.), 0))

#%#%#%#%#%#%#%#%#%#%
# Changing lift threshold for connection
#%#%#%#%#%#%#%#%#%#%

# We could try a minimum lift of 10 or something derived from the distribution to get a more sparse network and clearer structure
#edge_list <- edge_list %>% filter(lift > 10)

#%#%#%#%#%#%#%#%#%#%
# Create Network
#%#%#%#%#%#%#%#%#%#%

# Creating dedicated dataframes for nodes and edges including node attributes and optional edge weights
nodes <- node_info
edges <- edge_list %>% select(tag1,tag2,co_occurance_count,lift) #%>% rename(weight=lift) # the renaming makes a huge difference because suddenly R uses the lift as edge weights in the network construction

# Creating the network
coocNet <- graph_from_data_frame(d=edges, vertices=nodes, directed=FALSE)
class(coocNet)

# transform to minimal spanning tree
coocNet <- mst(coocNet)


#%#%#%#%#%#%#%#%#%#%
# Run community detection (Louvain) and betweenness centrality 
#%#%#%#%#%#%#%#%#%#%

# Running community detection with&without lift as weight parameter
clusterlouvain <- cluster_louvain(coocNet) # without weight
clusterlouvain_2 <- cluster_louvain(coocNet, weights=edge_list$lift) # use lift as weight - many more communities

# Assign community membership as an attribute
V(coocNet)$louvain_community <- membership(clusterlouvain)
V(coocNet)$louvain_community_lift <- membership(clusterlouvain_2)

# Calculating and assigning betweenness centrality - THIS CAN TAKE A WHILE - comment out if not needed
b_centrality <- betweenness(coocNet)
V(coocNet)$b_centrality <- b_centrality

#%#%#%#%#%#%#%#%#%#%
# Export for use in Gephi
#%#%#%#%#%#%#%#%#%#%

# Set your path via setting your working directory (setwd()) or choose any other path where to save the network
path = paste(getwd(),"/cooc_network_MST.graphml", sep="")

write_graph(coocNet, path, format = "graphml")


