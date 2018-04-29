    library(igraph)
    
    getwd()
    
    normalize_vector <- function(x) {
      minx = min(x)
      print(minx)
      maxx = max(x)
      print(maxx)
      x <- (x - minx)/(maxx - minx)
    }
    
    get_graph <- function() {
      graph <- read.graph("C:\\Users\\akhil\\AppData\\Local\\lxss\\home\\akhiludathu\\Social-Networks-Anomaly-Detection\\dataset\\facebook_combined.txt", format="edgelist", directed=FALSE)
    
      dataset <- read.csv("C:\\Users\\akhil\\AppData\\Local\\lxss\\home\\akhiludathu\\Social-Networks-Anomaly-Detection\\dataset\\fb-features.txt", header = FALSE, sep = ' ')
      num_features = ncol(dataset)
      V <- vcount(graph)
      E <- ecount(graph)
    
      features <- list()
      for(i in 1:V) {
        flag = 1
        for(j in 1:num_features) {
          if(dataset[i,j] == 1) {
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
    
      ends_graph <- ends(graph, E(graph))
      for(i in 1:ecount(graph)) {
         E(graph)[i]$weight <- length(intersect(features[[ends_graph[i,1]]],features[[ends_graph[i,2]]]))
       }
      graph
    }
    
    get_outlierness_EDPL <- function(g) {
      V <- vcount(g)
      E <- ecount(g)
    
      ego_vertexsize <- ego_size(g, 1)
    
      ego_graph <- make_ego_graph(g, 1)
    
      ego_edgesize = rep(0, V)
      for (i in 1:V) {
        ego_edgesize[i] <- ecount(ego_graph[[i]])
      }
    
    
      #plot(ego_vertexsize, ego_edgesize, type = "o", xlab = "Vertex Size", ylab = "Edge Size")
      C = 1
      alpha = 1.37
      outlierness = rep(0, V)
      for(i in 1:V) {
        outlierness[i] <- (max(ego_edgesize[i], C*(ego_vertexsize[i]**alpha)) / min(ego_edgesize[i], C*(ego_vertexsize[i]**alpha))) * (log10(abs(ego_edgesize[i] - C*(ego_vertexsize[i]**alpha)) + 1))
      }
      outlierness <- normalize_vector(outlierness)
      outlierness
    }
    
    get_outlierness_EWPL <- function(g) {
      V <- vcount(g)
      E <- ecount(g)
    
      ego_graph <- make_ego_graph(g, 1)
    
      ego_edgesize = rep(0, V)
      for (i in 1:V) {
        ego_edgesize[i] <- ecount(ego_graph[[i]])
      }
    
      ego_weight = rep(0, V)
      for(i in 1:V) {
        ego_weight[i] <- sum(E(ego_graph[[i]])$weight) + 1
      }
    
      C = 1
      beta = 1.15
      outlierness = rep(0, V)
      for(i in 1:V) {
        outlierness[i] <- (max(ego_weight[i], C*(ego_edgesize[i]**beta)) / min(ego_weight[i], C*(ego_edgesize[i]**beta))) * (log10(abs(ego_weight[i] - C*(ego_edgesize[i]**beta)) + 1))
      }
      outlierness <- normalize_vector(outlierness)
      outlierness
    }
    
    get_outlierness_ELWPL <- function(g) {
      V <- vcount(g)
      E <- ecount(g)
    
      ego_graph <- make_ego_graph(g, 1)
    
    
      ego_eigen_value = rep(0, V)
      for(i in 1:V) {
      A <- as_adjacency_matrix(ego_graph[[i]], attr="weight")
        ego_eigen_value[i] <- eigen(A)$values[1] + 1
      }
    
      ego_weight = rep(0, V)
      for(i in 1:V) {
        ego_weight[i] <- sum(E(ego_graph[[i]])$weight) + 1
      }
    
      C = 1
      gamma = 0.75
      outlierness = rep(0, V)
      for(i in 1:V) {
      outlierness[i] <- (max(ego_eigen_value[i], C*(ego_weight[i]**gamma)) / min(ego_eigen_value[i], C*(ego_weight[i]**gamma))) * (log10(abs(ego_eigen_value[i] - C*(ego_weight[i]**gamma)) + 1))
      }
      outlierness <- normalize_vector(outlierness)
      outlierness
    }
    
    graph = get_graph()
    outlierness_EDPL <- get_outlierness_EDPL(graph)
    outlierness_EWPL <- get_outlierness_EWPL(graph)
    outlierness_ELWPL <- get_outlierness_ELWPL(graph)
    outlierness <- (outlierness_EDPL + outlierness_EWPL + outlierness_ELWPL)/3
    par(mar = rep(2, 4))
    plot(outlierness_EDPL, type = "h", main = "Density based outlier score")
    plot(outlierness_EWPL, type = "h", main = "Weight based outlier score")
    plot(outlierness_ELWPL, type = "h", main = "Dominant pair outlier score")
    
    print(outlierness)
    
    cnt <- 0
    for(i in 1:vcount(graph)) {
      if (outlierness[i] >= 0.05*(max(outlierness)-min(outlierness))) {
        print (c(outlierness[i], as.integer(i)))
        cnt <- cnt + 1;
      }
    }
    
    print(min(outlierness))
    print(max(outlierness))
    print(cnt)
