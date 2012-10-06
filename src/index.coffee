express = require 'express'
stylus = require 'stylus'
assets = require 'connect-assets'
_ = require 'underscore'
db = require './model'

{WordModel, WordRelModel} = db



importWords = (callback)->
  WordModel.remove {}, ->
    file = require('fs').readFileSync('./data/words', 'utf8')
    arr = _.each file.split('\n'), (w)-> 
      return unless !!w.replace(/\s*/g, '')
      word = new WordModel
        word: w
        size: w.length
      word.save()  
    callback()

importRel = (callback)->
  WordRelModel.remove {}, ->
    WordModel.find {}, (err, all_words)->
      g = _.groupBy all_words, 'size'
      _.each g, (words, size)->
        size = parseInt size, 10
        _.each words, (w)->
          related = _.filter words, (ww)-> 
            w1 = w.word
            w2 = ww.word
            flag = off
            for k in [0..w1.length-1]
              if w1.charAt(k) isnt w2.charAt(k)
                return off if flag
                flag = true
            return on
          if related.length isnt 0  
            wordRel = new WordRelModel {word: w, related}
            wordRel.save()
        console.log 'DONE size', size    
      console.log '----------REL DONE'      

#importWords ->
importRel()
  

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
