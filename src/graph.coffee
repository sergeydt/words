extractKeys = (obj) ->
  keys = []
  key = undefined
  for key of obj
    Object::hasOwnProperty.call(obj, key) and keys.push(key)
  keys

sorter = (a, b) ->
  parseFloat(a) - parseFloat(b)

findPaths = (map, start, end, infinity) ->
  infinity = infinity or Infinity
  costs = {}
  open = 0: [start]
  predecessors = {}
  keys = undefined
  addToOpen = (cost, vertex) ->
    key = "" + cost
    open[key] = []  unless open[key]
    open[key].push vertex

  costs[start] = 0
  while open
    break  unless (keys = extractKeys(open)).length
    keys.sort sorter
    key = keys[0]
    bucket = open[key]
    node = bucket.shift()
    currentCost = parseFloat(key)
    adjacentNodes = map[node] or {}
    delete open[key]  unless bucket.length
    for vertex of adjacentNodes
      if Object::hasOwnProperty.call(adjacentNodes, vertex)
        cost = adjacentNodes[vertex]
        totalCost = cost + currentCost
        vertexCost = costs[vertex]
        if (vertexCost is `undefined`) or (vertexCost > totalCost)
          costs[vertex] = totalCost
          addToOpen totalCost, vertex
          predecessors[vertex] = node
  if costs[end] is `undefined`
    null
  else
    predecessors

extractShortest = (predecessors, end) ->
  nodes = []
  u = end
  while u
    nodes.push u
    predecessor = predecessors[u]
    u = predecessors[u]
  nodes.reverse()
  nodes

findShortestPath = (map, nodes) ->
  start = nodes.shift()
  end = undefined
  predecessors = undefined
  path = []
  shortest = undefined
  while nodes.length
    end = nodes.shift()
    predecessors = findPaths(map, start, end)
    if predecessors
      shortest = extractShortest(predecessors, end)
      if nodes.length
        path.push.apply path, shortest.slice(0, -1)
      else
        return path.concat(shortest)
    else
      return null
    start = end

toArray = (list, offset) ->
  try
    return Array::slice.call(list, offset)
  catch e
    a = []
    i = offset or 0
    l = list.length

    while i < l
      a.push list[i]
      ++i
    return a

Graph = (@map) ->

Graph::findShortestPath = (start, end) ->
  if Object::toString.call(start) is "[object Array]"
    findShortestPath @map, start
  else if arguments.length is 2
    findShortestPath @map, [start, end]
  else
    findShortestPath @map, toArray(arguments_)

Graph.findShortestPath = (map, start, end) ->
  if Object::toString.call(start) is "[object Array]"
    findShortestPath map, start
  else if arguments_.length is 3
    findShortestPath map, [start, end]
  else
    findShortestPath map, toArray(arguments_, 1)
    
module.exports = Graph        

