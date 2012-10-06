var ObjectId, Schema, WordModel, WordRelModel, WordRelSchema, WordSchema, db, mongoose;
mongoose = require('mongoose');
Schema = mongoose.Schema;
ObjectId = Schema.ObjectId;
db = mongoose.createConnection('localhost', 'words');
WordSchema = new Schema({
  word: String,
  size: Number
});
WordModel = db.model('Word', WordSchema);
WordRelSchema = new Schema({
  word: [WordSchema],
  related: Array
});
WordRelModel = db.model('WordRel', WordRelSchema);
module.exports = {
  WordModel: WordModel,
  WordRelModel: WordRelModel
};