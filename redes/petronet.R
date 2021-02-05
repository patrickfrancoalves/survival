#remove(nodes_d3,per_route) 
#rm(list = ls()) 
library(igraph) 
library(dplyr)
library(tidyverse)

# Modificando local da biblioteca

petro  <- read.csv("~/GitHub/survival/redes/network petro topografia.csv", sep=";")
trats  <- read.csv("~/GitHub/survival/redes/network petro.csv", encoding="UTF-8", sep=";")
trats2 <- trats %>% filter(PETRO_PETRO==1) %>% select(c("ArquivoXML"))

table(trats$PETRO_PETRO)
table(trats$PETRO_LATTES)
table(trats$CENPES_LATTES)
table(trats$PETRO_LAB)
table(trats$ANP_LATTES)
table(trats$ANP_ANP)

petro2 <- inner_join(  trats , petro , by = "ArquivoXML")

petro2 <- inner_join( petro , trats %>% filter(PETRO_PETRO==1) %>% select(c("ArquivoXML")) , by = "ArquivoXML")
petro2 <- inner_join( petro , trats %>% filter(PETRO_PETRO==1) %>% select(c("ArquivoXML")) , by = "ArquivoXML")
petro2 <- inner_join( petro , trats %>% filter(PETRO_PETRO==1) %>% select(c("ArquivoXML")) , by = "ArquivoXML")
petro2 <- inner_join( petro , trats %>% filter(PETRO_PETRO==1) %>% select(c("ArquivoXML")) , by = "ArquivoXML")
petro2 <- inner_join( petro , trats %>% filter(PETRO_PETRO==1) %>% select(c("ArquivoXML")) , by = "ArquivoXML")



#trats[ which(trats$PETRO_PETRO==1),c("ArquivoXML")]



names(trats)

fonte   <- petro %>% distinct(ArquivoXML) %>% rename(label = ArquivoXML)
destino <- petro %>% distinct(ID_CNPQ) %>% rename(label = ID_CNPQ)


# Use full join to create a dataframe with a column with the unique locations.

nos <- full_join(fonte, destino, by = "label")
nos


nos <- nos %>% rowid_to_column("id")
nos


#--------------------------------------------------#
#---                  Edge list                 ---#
#--------------------------------------------------#

per_rota <- petro %>% group_by(ArquivoXML,ID_CNPQ) %>% summarise(weight = n()) %>% ungroup()

edges <- per_rota %>% left_join(nos, by = c("ArquivoXML" = "label")) %>% rename(from = id)
edges <- edges %>% left_join(nos, by = c("ArquivoXML" = "label")) %>% rename(to = id)
edges <- select(edges, from, to, weight)
edges

# Creating network objects
library(network)

routes_network <- network(edges, vertex.attr = nos, matrix.type = "edgelist", ignore.eval = FALSE)


class(routes_network)
plot(routes_network, vertex.cex = 3)
plot(routes_network, vertex.cex = 3, mode = "circle")



#--------------------------------------------------#
#---                Usando igraph               ---#
#--------------------------------------------------#

detach(package:network)
rm(routes_network)
library(igraph)

routes_igraph <- graph_from_data_frame(d = edges, vertices = nos, directed = TRUE)
plot(routes_igraph, edge.arrow.size = 0.2)
plot(routes_igraph, layout = layout_with_graphopt, edge.arrow.size = 0.2)


#--------------------------------------------------#
#---         Usando tidygraph e ggraph          ---#
#---   OBS: network analysis into tidyverse     ---#
#--------------------------------------------------#

library(tidygraph)
library(ggraph)

routes_tidy <- tbl_graph(nodes = nos, edges = edges, directed = TRUE)

routes_igraph_tidy <- as_tbl_graph(routes_igraph)

#class(routes_tidy)

routes_tidy %>% activate(edges) %>% arrange(desc(weight))

ggraph(routes_tidy, layout = "graphopt") + geom_node_point() +
  geom_edge_link(aes(width = weight), alpha = 0.8) + 
  scale_edge_width(range = c(0.2, 2)) +
  geom_node_text(aes(label = label), repel = TRUE) +
  labs(edge_width = "Letters") + theme_graph()




