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
#importRel 5
#importRel 6

  
  
    
    
  
  
#  console.log 'done', w1, w   2



app = express()
# Add Connect Assets
app.use assets()
# Set the public folder as static assets
app.use express.static(process.cwd() + '/public')
# Set View Engine
app.set 'view engine', 'jade'

app.use (req, res, next)-> 
  res.locals 
    result: ''
    w1: req.param('w1')
    w2: req.param('w2')
  next()

# Get root_path return index view
app.get '/', (req, resp) -> 
  resp.render 'index'
  


app.get '/words', (req, res)->
  s1 = req.param('w1')
  s2 = req.param('w2')
  console.log 'words', {s1, s2}
  WordModel.find({size: s1.length, rel_size: {$gt: 0}}).populate('related').exec (err, all_words)->
    map = {}
    _.each all_words, (w)->
      o = {}
      _.each w.related, (r)->
        o[r._id] = 1
      map[w._id] = o
  #  console.log 'map', map  
    graph = new Graph map
  #  console.log 'Graph', graph
    w1 = _.find all_words, (w)-> w.word is s1
    w2 = _.find all_words, (w)-> w.word is s2
    
    if not w1 or not w2
      mess = 'word not found'
      console.log mess, {w1, w2}
      return res.render 'index', {result: mess}
    
    z = graph.findShortestPath w1._id, w2._id

    if not z
      mess = 'path not found'
      console.log 'path not found'
      return res.render 'index', {result: mess}
    
    x =  _.map z, (id)->
      word = _.find all_words, (w)->
        w._id.toString() is id.toString()
      word?.word  
    
    console.log 'z',z
    console.log 'x',x.join(' ')
    return res.render 'index', {result: x}
      
# Define Port
port = process.env.PORT or process.env.VMC_APP_PORT or 3000
# Start Server
app.listen port, -> console.log "Listening on #{port}\nPress CTRL-C to stop server."
