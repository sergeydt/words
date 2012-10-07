var ObjectId, Schema, WordModel, WordSchema, db, mongoose;
mongoose = require('mongoose');
Schema = mongoose.Schema;
ObjectId = Schema.ObjectId;
db = mongoose.createConnection('localhost', 'words');
WordSchema = new Schema({
  word: String,
  size: Number,
  rel_size: {
    type: Number,
    "default": 0
  },
  related: [
    {
      type: Schema.Types.ObjectId,
      ref: 'Word',
      "default": null
    }
  ]
});
WordModel = db.model('Word', WordSchema);
module.exports = {
  WordModel: WordModel
};