var Graph, extractKeys, extractShortest, findPaths, findShortestPath, sorter, toArray;
extractKeys = function(obj) {
  var key, keys;
  keys = [];
  key = void 0;
  for (key in obj) {
    Object.prototype.hasOwnProperty.call(obj, key) && keys.push(key);
  }
  return keys;
};
sorter = function(a, b) {
  return parseFloat(a) - parseFloat(b);
};
findPaths = function(map, start, end, infinity) {
  var addToOpen, adjacentNodes, bucket, cost, costs, currentCost, key, keys, node, open, predecessors, totalCost, vertex, vertexCost;
  infinity = infinity || Infinity;
  costs = {};
  open = {
    0: [start]
  };
  predecessors = {};
  keys = void 0;
  addToOpen = function(cost, vertex) {
    var key;
    key = "" + cost;
    if (!open[key]) {
      open[key] = [];
    }
    return open[key].push(vertex);
  };
  costs[start] = 0;
  while (open) {
    if (!(keys = extractKeys(open)).length) {
      break;
    }
    keys.sort(sorter);
    key = keys[0];
    bucket = open[key];
    node = bucket.shift();
    currentCost = parseFloat(key);
    adjacentNodes = map[node] || {};
    if (!bucket.length) {
      delete open[key];
    }
    for (vertex in adjacentNodes) {
      if (Object.prototype.hasOwnProperty.call(adjacentNodes, vertex)) {
        cost = adjacentNodes[vertex];
        totalCost = cost + currentCost;
        vertexCost = costs[vertex];
        if ((vertexCost === undefined) || (vertexCost > totalCost)) {
          costs[vertex] = totalCost;
          addToOpen(totalCost, vertex);
          predecessors[vertex] = node;
        }
      }
    }
  }
  if (costs[end] === undefined) {
    return null;
  } else {
    return predecessors;
  }
};
extractShortest = function(predecessors, end) {
  var nodes, predecessor, u;
  nodes = [];
  u = end;
  while (u) {
    nodes.push(u);
    predecessor = predecessors[u];
    u = predecessors[u];
  }
  nodes.reverse();
  return nodes;
};
findShortestPath = function(map, nodes) {
  var end, path, predecessors, shortest, start, _results;
  start = nodes.shift();
  end = void 0;
  predecessors = void 0;
  path = [];
  shortest = void 0;
  _results = [];
  while (nodes.length) {
    end = nodes.shift();
    predecessors = findPaths(map, start, end);
    if (predecessors) {
      shortest = extractShortest(predecessors, end);
      if (nodes.length) {
        path.push.apply(path, shortest.slice(0, -1));
      } else {
        return path.concat(shortest);
      }
    } else {
      return null;
    }
    _results.push(start = end);
  }
  return _results;
};
toArray = function(list, offset) {
  var a, i, l;
  try {
    return Array.prototype.slice.call(list, offset);
  } catch (e) {
    a = [];
    i = offset || 0;
    l = list.length;
    while (i < l) {
      a.push(list[i]);
      ++i;
    }
    return a;
  }
};
Graph = function(map) {
  this.map = map;
};
Graph.prototype.findShortestPath = function(start, end) {
  if (Object.prototype.toString.call(start) === "[object Array]") {
    return findShortestPath(this.map, start);
  } else if (arguments.length === 2) {
    return findShortestPath(this.map, [start, end]);
  } else {
    return findShortestPath(this.map, toArray(arguments_));
  }
};
Graph.findShortestPath = function(map, start, end) {
  if (Object.prototype.toString.call(start) === "[object Array]") {
    return findShortestPath(map, start);
  } else if (arguments_.length === 3) {
    return findShortestPath(map, [start, end]);
  } else {
    return findShortestPath(map, toArray(arguments_, 1));
  }
};
module.exports = Graph;