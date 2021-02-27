#remove(nodes_d3,per_route) 
rm(list = ls()) 
library(igraph) 
library(dplyr)
library(tidyverse)

# Modificando local da biblioteca

netpat  <- read.csv("~/GitHub/survival/redes/network petro topografia.csv", sep=";")
tratam  <- read.csv("~/GitHub/survival/redes/network petro.csv", encoding="UTF-8", sep=";")
#trats2  <- trats %>% filter(PETRO_PETRO==1) %>% select(c("ArquivoXML"))

table(netpat$PETRO_PETRO)
table(netpat$PETRO_LATTES)
table(netpat$CENPES_LATTES)
table(netpat$PETRO_LAB)
table(netpat$ANP_LATTES)
table(netpat$ANP_ANP)

#petro2 <- inner_join( trats2 , petro , by = "ArquivoXML")

petro_petro   <- netpat %>% filter(PETRO_PETRO==1) 
petro_lattes  <- netpat %>% filter(PETRO_LATTES==1) 
cenpes_lattes <- netpat %>% filter(CENPES_LATTES==1) 
petro_lab     <- netpat %>% filter(PETRO_PETRO==1) 
anp_lattes    <- netpat %>% filter(ANP_LATTES==1) 
anp_anp       <- netpat %>% filter(ANP_ANP==1) 




names(petro_petro)

fonte   <- petro_petro %>% distinct(ArquivoXML) %>% rename(label = ArquivoXML)
destino <- petro_petro %>% distinct(`NRO.ID.CNPQ`) %>% rename(label = `NRO.ID.CNPQ`)


# Use full join to create a dataframe with a column with the unique locations.

nos <- full_join(fonte, destino, by = "label")
nos


nos <- nos %>% rowid_to_column("id")
nos


#--------------------------------------------------#
#---                  Edge list                 ---#
#--------------------------------------------------#

per_rota <- petro_lapetro %>% group_by(ArquivoXML,`NRO.ID.CNPQ`) %>% summarise(weight = n()) %>% ungroup()

edges <- per_rota %>% left_join(nos, by = c("ArquivoXML" = "label")) %>% rename(from = id)
edges <- edges %>% left_join(nos, by = c("ArquivoXML" = "label")) %>% rename(to = id)
edges <- select(edges, from, to, weight)
edges

# Creating network objects
#install.packages("network")
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




