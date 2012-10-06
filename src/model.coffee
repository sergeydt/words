mongoose = require 'mongoose'
{Schema} = mongoose
{ObjectId} = Schema

db = mongoose.createConnection 'localhost', 'words'

WordSchema = new Schema 
  word: String
  size: Number
  rel_size: {type: Number, default: 0}
  related: [{ type: Schema.Types.ObjectId, ref: 'Word', default: null }]
WordModel = db.model 'Word', WordSchema
  

module.exports = {WordModel}


