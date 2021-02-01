#devtools::install_github("briatte/ggnet")
#install.packages("tidyverse")
#https://www.jessesadler.com/post/network-analysis-with-r/

library(devtools)
library(ggnet)
library(network)
library(sna)
library(ggplot2)
library(GGally)
library(tidyverse)

edge_list <- tibble(from = c(1, 2, 2, 3, 4), to = c(2, 3, 4, 2, 1))
node_list <- tibble(id = 1:4)

edge_list
node_list



# C:\Users\patrick\OneDrive\Documentos\GitHub\survival\netscix2016
#ls()
# getwd()
# Creating edge and node lists

setwd("C:/Users/patrick/OneDrive/Documentos/GitHub/survival/netscix2016")

letters<- read_csv("correspondence-data-1585.csv")

letters


sources <- letters %>% distinct(source) %>% rename(label = source)

destinations <- letters %>% distinct(destination) %>% rename(label = destination)

# Use full join to create a dataframe with a column with the unique locations.

nodes <- full_join(sources, destinations, by = "label")

nodes


nodes <- nodes %>% rowid_to_column("id")
nodes


# Edge list

per_route <- letters %>% group_by(source, destination) %>% summarise(weight = n()) %>% ungroup()

edges <- per_route %>% left_join(nodes, by = c("source" = "label")) %>% rename(from = id)
edges <- edges %>% left_join(nodes, by = c("destination" = "label")) %>% rename(to = id)
edges <- select(edges, from, to, weight)
edges

# Creating network objects
library(network)

routes_network <- network(edges, vertex.attr = nodes, matrix.type = "edgelist", ignore.eval = FALSE)


class(routes_network)
plot(routes_network, vertex.cex = 3)
plot(routes_network, vertex.cex = 3, mode = "circle")


#igraph
detach(package:network)
rm(routes_network)
library(igraph)

routes_igraph <- graph_from_data_frame(d = edges, vertices = nodes, directed = TRUE)
plot(routes_igraph, edge.arrow.size = 0.2)
plot(routes_igraph, layout = layout_with_graphopt, edge.arrow.size = 0.2)


# tidygraph and ggraph
#to bring network analysis into the tidyverse workflow. 
#install.packages("ggraph")

library(tidygraph)
library(ggraph)

routes_tidy <- tbl_graph(nodes = nodes, edges = edges, directed = TRUE)

routes_igraph_tidy <- as_tbl_graph(routes_igraph)

class(routes_tidy)

class(routes_igraph_tidy)

routes_tidy %>% activate(edges) %>% arrange(desc(weight))

ggraph(routes_tidy, layout = "graphopt") + geom_node_point() +
  geom_edge_link(aes(width = weight), alpha = 0.8) + 
  scale_edge_width(range = c(0.2, 2)) +
  geom_node_text(aes(label = label), repel = TRUE) +
  labs(edge_width = "Letters") + theme_graph()



# Interactive network graphs with visNetwork and networkD3
#install.packages("visNetwork")
#install.packages("networkD3")


library(visNetwork)
library(networkD3)

visNetwork(nodes, edges)

edges <- mutate(edges, width = weight/5 + 1)


visNetwork(nodes, edges) %>% visIgraphLayout(layout = "layout_with_fr") %>% visEdges(arrows = "middle")

# networkD3

nodes_d3 <- mutate(nodes, id = id - 1)
edges_d3 <- mutate(edges, from = from - 1, to = to - 1)

forceNetwork(Links = edges_d3, Nodes = nodes_d3, Source = "from", Target = "to", 
             NodeID = "label", Group = "id", Value = "weight", 
             opacity = 1, fontSize = 16, zoom = TRUE)



sankeyNetwork(Links = edges_d3, Nodes = nodes_d3, Source = "from", Target = "to", 
              NodeID = "label", Value = "weight", fontSize = 16, unit = "Letter(s)")
