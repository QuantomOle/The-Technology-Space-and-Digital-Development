#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%
#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%
# Spatial inequalities
# 2021-08-05
# Build technology space network 2.0 - comparing lift and proximity (testing approach of Hidalgo)
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
# Load data (full edge list too big for Github)
#%#%#%#%#%#%#%#%#%#%

edge_list <- fread("/Users/oleteutloff/Desktop/Data/edge_list_full.csv")

#%#%#%#%#%#%#%#%#%#%
# Compare distributions of proximity and lift 
#%#%#%#%#%#%#%#%#%#%

### density plots ###

# proximity
ggplot(edge_list, aes(x=proximity)) + 
  geom_density() +
  scale_x_log10(
    breaks = scales::trans_breaks("log10", function(x) 10^x),
    labels = scales::trans_format("log10", scales::math_format(10^.x))
  )

# lift
ggplot(edge_list, aes(x=lift)) + 
  geom_density() +
  scale_x_log10(
    breaks = scales::trans_breaks("log10", function(x) 10^x),
    labels = scales::trans_format("log10", scales::math_format(10^.x))
  )

### cumulative distribution: Y = number of links, X = proximity or lift ###

# proximity
ggplot(edge_list %>% 
         arrange(desc(proximity)) %>% 
         mutate(rn = row_number())) + 
  geom_step(aes(x=proximity, y=rn))  +
  scale_x_log10(
    breaks = scales::trans_breaks("log10", function(x) 10^x),
    labels = scales::trans_format("log10", scales::math_format(10^.x))) +
  scale_y_log10(
    breaks = scales::trans_breaks("log10", function(x) 10^x),
    labels = scales::trans_format("log10", scales::math_format(10^.x))) + 
  labs(x = "proximity threshold", y = "links")

# lift
ggplot(edge_list %>% 
         arrange(desc(lift)) %>% 
         mutate(rn = row_number())) + 
  geom_step(aes(x=lift, y=rn))  +
  scale_x_log10(
    breaks = scales::trans_breaks("log10", function(x) 10^x),
    labels = scales::trans_format("log10", scales::math_format(10^.x))) +
  scale_y_log10(
    breaks = scales::trans_breaks("log10", function(x) 10^x),
    labels = scales::trans_format("log10", scales::math_format(10^.x))) + 
  labs(x = "lift threshold", y = "links")


#%#%#%#%#%#%#%#%#%#%
# heatmap of proximity and lift 
#%#%#%#%#%#%#%#%#%#%

## Without clustering
library(viridis)

# proximity
ggplot(data = edge_list, aes(x=tag1, y=tag2, fill=proximity)) + geom_raster() #+scale_fill_viridis(discrete=FALSE)

# lift
ggplot(data = edge_list, aes(x=tag1, y=tag2, fill=lift)) + geom_raster()


## With Clustering ##
library(pheatmap)

# proximity #

# create matrix
data_subset <- edge_list %>% select(tag1,tag2,proximity)

#proximity_matrix <- data_subset %>% pivot_wider(names_from = tag2, values_from = proximity, values_fill = 0)

proximity_matrix <- data_subset %>% pivot_wider(names_from = tag2, values_from = proximity)

proximity_matrix[is.na(proximity_matrix)] <- 0

#proximity_matrix <- as.matrix(proximity_matrix, rownames=tag1)

# create heatmap using pheatmap
pheatmap(as.matrix(proximity_matrix[1:100,1:100], rownames=tag1),RColorBrewer::brewer.pal(3,"Reds"))


# Problem! tag1 != tag2 - unclear why this is the case
length(unique(edge_list$tag12))
length(unique(edge_list$tag2))

# lift #










#%#%#%#%#%#%#%#%#%#%
# Maximum Spanning Tree 
#%#%#%#%#%#%#%#%#%#%

node_info <- fread("https://raw.githubusercontent.com/QuantomOle/The-Technology-Space-and-Digital-Development/main/data/node_info.csv")

### Proximity ###

# Creating dedicated dataframes for nodes and edges including node attributes and optional edge weights
nodes <- node_info
edges <- edge_list %>% select(tag1,tag2,co_occurance_count,proximity) %>% rename(weight=proximity) # the renaming makes a huge difference because suddenly R uses the lift as edge weights in the network construction

# Creating the network
coocNet <- graph_from_data_frame(d=edges, vertices=nodes, directed=FALSE)
class(coocNet)

# transform to Maximum spanning tree - DOES NOT WORK in R
library(NetworkToolbox)

coocNet_MaST <- MaST(edges, normal = FALSE)



### Lift ###





#%#%#%#%#%#%#%#%#%#%
# Network visaulization for testing purpose
#%#%#%#%#%#%#%#%#%#%



