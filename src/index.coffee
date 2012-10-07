express = require 'express'
stylus = require 'stylus'
assets = require 'connect-assets'
_ = require 'underscore'
db = require './model'

{WordModel} = db

Graph = require './graph'




importWords = (callback)->
  WordModel.remove {}, ->
    file = require('fs').readFileSync('./data/words', 'utf8')
    arr = _.each file.split('\n'), (w)-> 
      return if !w.replace(/\s*/g, '') or w.length < 3
      word = new WordModel
        word: w
        size: w.length
      word.save()  
    callback()



importRel = (SIZE, callback)->
#  WordRelModel.remove {}, ->
    WordModel.find {}, (err, all_words)->
      g = _.groupBy all_words, 'size'
      _.each g, (words, size)->
        size = parseInt size, 10
        return if size < 3
        
        return if size isnt SIZE
        
        console.log 'START size', size
        _.each words, (w)->
          related = _.filter words, (ww)-> 
            w1 = w.word
            w2 = ww.word
            return off if w1 is w2
            flag = off
            for k in [0..w1.length-1]
              if w1.charAt(k) isnt w2.charAt(k)
                return off if flag
                flag = true
            return on
#            console.log 'related', related
          w.rel_size = related.length
          w.related = related
          w.save()
        console.log 'DONE size', size    
      console.log '----------REL DONE'      

#importWords ->
#  importRel 4


#map =
#  a:
#    b: 3
#    c: 1

#  b:
#    a: 2
#    c: 1

#  c:
#    a: 4
#    b: 1

#graph = new Graph map
#z = graph.findShortestPath "a", "b"
#console.log 'here', z#.findShortestPath 



WordModel.find({size: 4, rel_size: {$gt: 0}}).populate('related').exec (err, all_words)->
  map = {}
  _.each all_words, (w)->
    o = {}
    _.each w.related, (r)->
      o[r._id] = 1
    map[w._id] = o
#  console.log 'map', map  
  graph = new Graph map
#  console.log 'Graph', graph
  s1 = 'муха'
  s2 = 'слон'
  w1 = _.find all_words, (w)-> w.word is s1
  w2 = _.find all_words, (w)-> w.word is s2
  z = graph.findShortestPath w1._id, w2._id
  
  
  x =  _.map z, (id)->
    word = _.find all_words, (w)->
      w._id is id
    word?.word  
  
  console.log 'z',z
  console.log 'x',x
  
  
  
  
#  words = _.map all_words, (w)-> new Word w
#  _.each words, (w)->
#    w.related = _.map w.related, (w)-> 
#      found = _.find all_words, (ww)->
#        console.log 'here', ww._id is w._id
#        ww._id is w._id
#      console.log 'found', found  
#      new Word found
#  return      
#      
#  
#  s1 = 'муха'
#  s2 = 'слон'
#  w1 = _.find(words, (w)-> w.word is s1)
#  w2 = _.find(words, (w)-> w.word is s2)
#  
#  visited = []
#  
#  w1.s = 0
#  iter = (wi)->
#    {s} = wi
#    # FIXME: difference by key1
#    r = _.difference wi.related, visited
##    console.log 'iter', {related: wi.related, visited}
#    _.each r, (w)->
#      w.s = Math.min w.s, s + 1
#      console.log 'iter', w.word, w.s
#    visited.push wi
#    
    
    
#  iter w1  
  
#  console.log 'here', w1
    
    
  
  
#  console.log 'done', w1, w   2



app = express()
# Add Connect Assets
app.use assets()
# Set the public folder as static assets
app.use express.static(process.cwd() + '/public')
# Set View Engine
app.set 'view engine', 'jade'
# Get root_path return index view
app.get '/', (req, resp) -> 
  resp.render 'index'
# Define Port
port = process.env.PORT or process.env.VMC_APP_PORT or 3000
# Start Server
app.listen port, -> console.log "Listening on #{port}\nPress CTRL-C to stop server."
