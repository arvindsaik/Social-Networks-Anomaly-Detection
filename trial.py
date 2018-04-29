from igraph import *
import pandas as pd
import numpy as np

def get_graph():
  graph = Graph.Read_Ncol("dataset/facebook_combined.txt", directed=False)
  dataset = pd.read_csv("dataset/fb-features.txt", header = None, sep = ' ')
  num_features = len(dataset.columns)
  V = graph.vcount()
  E = graph.ecount()

  features = {}
  for i in range(V):
      features[i] = []
  for i in range(V):
    flag=1
    for j in range(num_features):
      #print i,j
      if dataset[j][i] == 1:
        if flag==1:
          listt =[]
          listt.append(j)
          features[i] = listt
          flag =0
        else:
          listt =[]
          listt =features[i]
          listt.append(j)
          features[i] = listt

    #ends_graph = ends(graph, E(graph))
    ends_graph = graph.es
    #print features
    #print "hi"
  for i in range(graph.ecount()):
    #print features[ends_graph[i].target]
    result1 = features[ends_graph[i].source]
    #print result1
    result2 = features[ends_graph[i].target]
    result1 =  [int(i) for i in result1]
    result2 =  [int(i) for i in result2]
    a =  len(set(result1).intersection(set(result2)))
    graph.es[i]["weight"] =a
  return graph

def get_outlierness_EWPL(g):
    V = g.vcount()
    E = g.ecount()

    # Ego_graph is a list of ego graphs of each node
    ego_graph = []
    for i in range(V):
        ego_graph.append(g.subgraph(g.neighborhood(i)))
    print ego_graph[0].es[0]['weight']


    # ego_edgesize is an integer vector of size V, and stores no.of edges in egonet of each node

    ego_edgesize = []
    for x in ego_graph:
        ego_edgesize.append(x.ecount())

    # ego_weight is an integer vector of size V, and stores the sum of the weight of egonet of each node
    ego_weight = [0]*V
    for i in range(0, V):
      for j in range(0, len(ego_graph[i].es)):
        ego_weight[i] += ego_graph[i].es[j]['weight'] + 1

    C = 1
    beta = 1.15
    #oulierness is calculated according to the Edge Density Power Law of the Oddball Algorithm
    outlierness = [0]*V
    for i in range(0, V):
      outlierness[i] = (max(ego_weight[i], C*(ego_edgesize[i]**beta)) / min(ego_weight[i], C*(ego_edgesize[i]**beta))) * (log10(abs(ego_weight[i] - C*(ego_edgesize[i]**beta)) + 1))

    outlierness = normalize_vector(outlierness)
    return outlierness

graph = get_graph()
#E(graph)$weight
#outlierness_EDPL <- get_outlierness_EDPL(graph)
outlierness_EWPL = get_outlierness_EWPL(graph)
print(outlierness_EWPL)
