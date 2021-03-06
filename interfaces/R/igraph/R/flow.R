
#   IGraph R package
#   Copyright (C) 2006-2012  Gabor Csardi <csardi.gabor@gmail.com>
#   334 Harvard street, Cambridge, MA 02139 USA
#   
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#   
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc.,  51 Franklin Street, Fifth Floor, Boston, MA
#   02110-1301 USA
#
###################################################################

graph.mincut <- function(graph, source=NULL, target=NULL, capacity=NULL,
                         value.only=TRUE) {

  if (!is.igraph(graph)) {
    stop("Not a graph object")
  }
  if (is.null(capacity)) {
    if ("capacity" %in% list.edge.attributes(graph)) {
      capacity <- E(graph)$capacity
    }
  }
  if (is.null(source) && !is.null(target) ||
      is.null(target) && !is.null(source)) {
    stop("Please give both source and target or neither")
  }
  if (!is.null(capacity)) {
    capacity <- as.numeric(capacity)
  }

  value.only <- as.logical(value.only)
  on.exit( .Call("R_igraph_finalizer", PACKAGE="igraph") )
  if (is.null(target) && is.null(source)) {
    if (value.only) {
      res <- .Call("R_igraph_mincut_value", graph, capacity,
                   PACKAGE="igraph")
    } else {
      res <- .Call("R_igraph_mincut", graph, capacity,
                   PACKAGE="igraph")
      res$cut <- res$cut + 1
      res$partition1 <- res$partition1 + 1
      res$partition2 <- res$partition2 + 1
      res
    }
  } else {
    if (value.only) {
      res <- .Call("R_igraph_st_mincut_value", graph,
                   as.igraph.vs(graph, source)-1,
                   as.igraph.vs(graph, target)-1, capacity,
                   PACKAGE="igraph")
    } else {
      stop("Calculating minimum s-t cuts is not implemented yet")
    }
  }
  res
}

vertex.connectivity <- function(graph, source=NULL, target=NULL, checks=TRUE) {

  if (!is.igraph(graph)) {
    stop("Not a graph object")
  }

  if (is.null(source) && is.null(target)) {
    on.exit( .Call("R_igraph_finalizer", PACKAGE="igraph") )
    .Call("R_igraph_vertex_connectivity", graph, as.logical(checks),
          PACKAGE="igraph")
  } else if (!is.null(source) && !is.null(target)) {
    on.exit( .Call("R_igraph_finalizer", PACKAGE="igraph") )
    .Call("R_igraph_st_vertex_connectivity", graph, as.igraph.vs(graph, source)-1,
          as.igraph.vs(graph, target)-1,
          PACKAGE="igraph")
  } else {
    stop("either give both source and target or neither")
  }
}

edge.connectivity <- function(graph, source=NULL, target=NULL, checks=TRUE) {

  if (!is.igraph(graph)) {
    stop("Not a graph object")
  }

  if (is.null(source) && is.null(target)) {    
    on.exit( .Call("R_igraph_finalizer", PACKAGE="igraph") )
    .Call("R_igraph_edge_connectivity", graph, as.logical(checks),
          PACKAGE="igraph")
  } else if (!is.null(source) && !is.null(target)) {
    on.exit( .Call("R_igraph_finalizer", PACKAGE="igraph") )
    .Call("R_igraph_st_edge_connectivity", graph,
          as.igraph.vs(graph, source)-1, as.igraph.vs(graph, target)-1,
          PACKAGE="igraph")
  } else {
    stop("either give both source and target or neither")
  }
}

edge.disjoint.paths <- function(graph, source, target) {

  if (!is.igraph(graph)) {
    stop("Not a graph object")
  }

  on.exit( .Call("R_igraph_finalizer", PACKAGE="igraph") )
  .Call("R_igraph_edge_disjoint_paths", graph,
        as.igraph.vs(graph, source)-1, as.igraph.vs(graph, target)-1,
        PACKAGE="igraph")
}

vertex.disjoint.paths <- function(graph, source=NULL, target=NULL) {

  if (!is.igraph(graph)) {
    stop("Not a graph object")
  }

  on.exit( .Call("R_igraph_finalizer", PACKAGE="igraph") )
  .Call("R_igraph_vertex_disjoint_paths", graph, as.igraph.vs(graph, source)-1,
        as.igraph.vs(graph, target)-1,
        PACKAGE="igraph")
}

graph.adhesion <- function(graph, checks=TRUE) {

  if (!is.igraph(graph)) {
    stop("Not a graph object")
  }
  
  on.exit( .Call("R_igraph_finalizer", PACKAGE="igraph") )
  .Call("R_igraph_adhesion", graph, as.logical(checks),
        PACKAGE="igraph")
}

graph.cohesion <- function(graph, checks=TRUE) {

  if (!is.igraph(graph)) {
    stop("Not a graph object")
  }

  on.exit( .Call("R_igraph_finalizer", PACKAGE="igraph") )
  .Call("R_igraph_cohesion", graph, as.logical(checks),
        PACKAGE="igraph")
}

