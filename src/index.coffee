express = require 'express'
stylus = require 'stylus'
assets = require 'connect-assets'
_ = require 'underscore'
db = require './model'

{WordModel} = db




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


WordModel.find({size: 4, rel_size: {$gt: 0}}).populate('related').exec (err, all_words)->
  
  s1 = 'муха'
  s2 = 'слон'
  w1 = _.find(all_words, (w)-> w.word is s1)
  w2 = _.find(all_words, (w)-> w.word is s2)
  
  visited = []
  
  _.each all_words, (w)-> w.s = null
#  w1.num = 0
  iter = (wi)->
    _.min wi, ()->
    
    
    
  iter [w1]  
  _.each w1.related, (wr)->
    
    
  
  
  console.log 'done', w1, w2

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
