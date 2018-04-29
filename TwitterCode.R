library(igraph)

normalize_vector <- function(x) {
  minx = min(x)
  print(minx)
  maxx = max(x)
  print(maxx)
  x <- (x - minx)/(maxx - minx)
}

inputFile <- "C:\\Users\\akhil\\AppData\\Local\\lxss\\home\\akhiludathu\\Social-Networks-Anomaly-Detection\\dataset\\78813.txt"
con  <- file(inputFile, open = "r")

dataList <- list()
ecdfList <- list()

nodeNum <- c()
nodeFeature <- c()

while (length(oneLine <- readLines(con, n = 1, warn = FALSE)) > 0) {
    myVector <- (strsplit(oneLine, " "))
    myVector <- c(as.numeric(myVector[[1]]))
    key <- myVector[1][1]
    value <- c()
    for(i in 2:len){
      value <- c(value,myVector[i])
    }
    value <- list(value)
    nodeNum <- c(nodeNum , key)
    nodeFeature <- c(nodeFeature , value)
}
#print(nodeFeature[242])
foo <- nodeFeature
names(foo) <- nodeNum
#print(foo[242])
foo[strtoi("242", base = 0L)]
close(con)

get_graph <- function() {
  #print(nodeNum)
  graph <- read.graph("C:\\Users\\akhil\\AppData\\Local\\lxss\\home\\akhiludathu\\Social-Networks-Anomaly-Detection\\dataset\\twitter_combined.txt", format="edgelist", directed=FALSE)
  
  num_features = 1125
  V <- vcount(graph)
  E <- ecount(graph)
  
  features <- list()
  for(i in 1:242) {
    flag = 1
    for(j in 1:num_features) {
      if(foo[[names(foo)[i]]][j] == 1) {
        if(flag == 1) {
          features[[i]] <- c(j)
          flag = 0
        }
        else {
          features[[i]] <- c(features[[i]], j)
        }
      }
    }
  }
  
  
  graph <- make_ego_graph(graph, 1,78813)
  graph <- graph[[1]]
  ends_graph <- ends(graph, E(graph))
  for(i in 1:ecount(graph)) {
    E(graph)[i]$weight <- length(intersect(features[[ends_graph[i,1]]],features[[ends_graph[i,2]]]))
  }
  graph
  
  
}

graph = get_graph()

