# -*- coding: utf-8 -*-
import csv
from operator import itemgetter
import networkx as nx
from networkx.algorithms import community 
import pandas as pd
import os

#%% 
#https://programminghistorian.org/en/lessons/exploring-and-analyzing-network-data-with-python
os.getcwd()

print(os.getcwd())

#%% 
os.chdir("C:\\Users\\patrick\\OneDrive\\Documentos\\GitHub\\survival")
print(os.getcwd())

#%% 
'------------------------------------------------------------'
'---             PIB municipal atualizado                 ---'
'------------------------------------------------------------'

#with open('quakers_nodelist.csv', 'r') as nodecsv: 
#    nodereader = csv.reader(nodecsv) 
#    nodes = [n for n in nodereader][1:]

nodes = pd.read_excel('network petro.xlsx',sheet_name='net') 


#%% 

node_names = [n[0] for n in nodes] 

#%% 

#with open('quakers_edgelist.csv', 'r') as edgecsv: 
#    edgereader = csv.reader(edgecsv) 
#    edges = [tuple(e) for e in edgereader][1:] 

edges = pd.read_excel('network petro.xlsx',sheet_name='id') 


#%% 
print(len(node_names))

print(len(edges))


#%% 

G = nx.Graph()
G.add_nodes_from(node_names)
G.add_edges_from(edges)


#%% 

print(nx.info(G))

#%% 

hist_sig_dict = {}
gender_dict = {}
birth_dict = {}
death_dict = {}
id_dict = {}

#%% 

for node in nodes: # Loop through the list, one row at a time
    hist_sig_dict[node[0]] = node[1]
    gender_dict[node[0]] = node[2]
    birth_dict[node[0]] = node[3]
    death_dict[node[0]] = node[4]
    id_dict[node[0]] = node[5]

#%% 

nx.set_node_attributes(G, hist_sig_dict, 'historical_significance')

nx.set_node_attributes(G, gender_dict, 'gender')

nx.set_node_attributes(G, birth_dict, 'birth_year')

nx.set_node_attributes(G, death_dict, 'death_year')

nx.set_node_attributes(G, id_dict, 'sdfb_id')
#%% 

for n in G.nodes(): # Loop through every node, in our data "n" will be the name of the person
    print(n, G.nodes[n]['birth_year']) # 
    
#%%

density = nx.density(G)
print("Network density:", density)

#%% 

fell_whitehead_path = nx.shortest_path(G, source="Margaret Fell", target="George Whitehead")

print("Shortest path between Fell and Whitehead:", fell_whitehead_path)

#%% 
print("Length of that path:", len(fell_whitehead_path)-1)
#%% 

# If your Graph has more than one component, this will return False:
print(nx.is_connected(G))

#%% 

# Next, use nx.connected_components to get the list of components,
# then use the max() command to find the largest one:
components = nx.connected_components(G)
largest_component = max(components, key=len)


#%% 

subgraph = G.subgraph(largest_component)
diameter = nx.diameter(subgraph)
print("Network diameter of largest component:", diameter)


#%% 

triadic_closure = nx.transitivity(G)
print("Triadic closure:", triadic_closure)

#%% 

degree_dict = dict(G.degree(G.nodes()))
nx.set_node_attributes(G, degree_dict, 'degree')

print(G.nodes['William Penn'])

#%% 

sorted_degree = sorted(degree_dict.items(), key=itemgetter(1), reverse=True)
  

#%% 

print("Top 20 nodes by degree:")
for d in sorted_degree[:20]:
    print(d)
    
#%% 

sorted_degree = sorted(degree_dict.items(), key=itemgetter(1), reverse=True)

#%% 
# Assign each to an attribute in your network
betweenness_dict = nx.betweenness_centrality(G) # Run betweenness centrality
eigenvector_dict = nx.eigenvector_centrality(G) # Run eigenvector centrality
#%% 

nx.set_node_attributes(G, betweenness_dict, 'betweenness')
nx.set_node_attributes(G, eigenvector_dict, 'eigenvector')
sorted_betweenness = sorted(betweenness_dict.items(), key=itemgetter(1), reverse=True)

#%% 
print("Top 20 nodes by betweenness centrality:")
for b in sorted_betweenness[:20]:
    print(b)
#%% 

#First get the top 20 nodes by betweenness as a list
top_betweenness = sorted_betweenness[:20]

#%% 

#Then find and print their degree
for tb in top_betweenness: 
    degree = degree_dict[tb[0]] # Use degree_dict to access a node's degree, see footnote 2
    print("Name:", tb[0], "| Betweenness Centrality:", tb[1], "| Degree:", degree)
    
#%% 

communities = community.greedy_modularity_communities(G)

#%% 

for i in range(0,len(communities)): 
    print("Comunidade :", communities[i])
    
#%% 

modularity_dict = {} # Create a blank dictionary
for i,c in enumerate(communities): # Loop through the list of communities, keeping track of the number for the community
    for name in c: # Loop through each person in a community
        modularity_dict[name] = i # Create an entry in the dictionary for the person, where the value is which group they belong to.

# Now you can add modularity information like we did the other metrics
nx.set_node_attributes(G, modularity_dict, 'modularity')

#%% 

# First get a list of just the nodes in that class
class0 = [n for n in G.nodes() if G.nodes[n]['modularity'] == 0]

# Then create a dictionary of the eigenvector centralities of those nodes
class0_eigenvector = {n:G.nodes[n]['eigenvector'] for n in class0}

#%% 

# Then sort that dictionary and print the first 5 results
class0_sorted_by_eigenvector = sorted(class0_eigenvector.items(), key=itemgetter(1), reverse=True)
    
#%% 

print("Modularity Class 0 Sorted by Eigenvector Centrality:")
for node in class0_sorted_by_eigenvector[:5]:
    print("Name:", node[0], "| Eigenvector Centrality:", node[1])
    
    
#%% 

for i,c in enumerate(communities): # Loop through the list of communities
    if len(c) > 2: # Filter out modularity classes with 2 or fewer nodes
        print('Class '+str(i)+':', list(c)) # Print out the classes and their members
        
#%% 

modularity_dict = {} # Create a blank dictionary


for i,c in enumerate(communities): # Loop through the list of communities, keeping track of the number for the community
    for name in c: # Loop through each person in a community
        modularity_dict[name] = i # Create an entry in the dictionary for the person, where the value is which group they belong to.
        
#%% 

print(modularity_dict )
#%% 

import plotly.graph_objects as go

import networkx as nx

G = nx.random_geometric_graph(200, 0.125)

#%% 

edge_x = []
edge_y = []
for edge in G.edges():
    x0, y0 = G.nodes[edge[0]]['pos']
    x1, y1 = G.nodes[edge[1]]['pos']
    edge_x.append(x0)
    edge_x.append(x1)
    edge_x.append(None)
    edge_y.append(y0)
    edge_y.append(y1)
    edge_y.append(None)

edge_trace = go.Scatter(
    x=edge_x, y=edge_y,
    line=dict(width=0.5, color='#888'),
    hoverinfo='none',
    mode='lines')

node_x = []
node_y = []
for node in G.nodes():
    x, y = G.nodes[node]['pos']
    node_x.append(x)
    node_y.append(y)

node_trace = go.Scatter(
    x=node_x, y=node_y,
    mode='markers',
    hoverinfo='text',
    marker=dict(
        showscale=True,
        # colorscale options
        #'Greys' | 'YlGnBu' | 'Greens' | 'YlOrRd' | 'Bluered' | 'RdBu' |
        #'Reds' | 'Blues' | 'Picnic' | 'Rainbow' | 'Portland' | 'Jet' |
        #'Hot' | 'Blackbody' | 'Earth' | 'Electric' | 'Viridis' |
        colorscale='YlGnBu',
        reversescale=True,
        color=[],
        size=10,
        colorbar=dict(
            thickness=15,
            title='Node Connections',
            xanchor='left',
            titleside='right'
        ),
        line_width=2))

#%% 

node_adjacencies = []
node_text = []
for node, adjacencies in enumerate(G.adjacency()):
    node_adjacencies.append(len(adjacencies[1]))
    node_text.append('# of connections: '+str(len(adjacencies[1])))

node_trace.marker.color = node_adjacencies
node_trace.text = node_text

#%% 

#  https://plotly.com/python/network-graphs/

fig = go.Figure(data=[edge_trace, node_trace],
             layout=go.Layout(
                title='<br>Network graph made with Python',
                titlefont_size=16,
                showlegend=False,
                hovermode='closest',
                margin=dict(b=20,l=5,r=5,t=40),
                annotations=[ dict(
                    text="Python code: <a href='https://plotly.com/ipython-notebooks/network-graphs/'> https://plotly.com/ipython-notebooks/network-graphs/</a>",
                    showarrow=False,
                    xref="paper", yref="paper",
                    x=0.005, y=-0.002 ) ],
                xaxis=dict(showgrid=False, zeroline=False, showticklabels=False),
                yaxis=dict(showgrid=False, zeroline=False, showticklabels=False))
                )

#%% 

fig.show()

#%% 

fig.write_image("fig1.png")
fig.write_image("fig1.jpeg")

#%% 


#https://plotly.com/python/interactive-html-export/
#https://towardsdatascience.com/python-interactive-network-visualization-using-networkx-plotly-and-dash-e44749161ed7
#https://plotly.com/python/network-graphs/

#%% 


#%% 


#%% 
