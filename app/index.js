var WordModel, WordRelModel, app, assets, db, express, importRel, importWords, port, stylus, _;
express = require('express');
stylus = require('stylus');
assets = require('connect-assets');
_ = require('underscore');
db = require('./model');
WordModel = db.WordModel, WordRelModel = db.WordRelModel;
importWords = function(callback) {
  return WordModel.remove({}, function() {
    var arr, file;
    file = require('fs').readFileSync('./data/words', 'utf8');
    arr = _.each(file.split('\n'), function(w) {
      var word;
      if (!w.replace(/\s*/g, '')) {
        return;
      }
      word = new WordModel({
        word: w,
        size: w.length
      });
      return word.save();
    });
    return callback();
  });
};
importRel = function(callback) {
  return WordRelModel.remove({}, function() {
    return WordModel.find({}, function(err, all_words) {
      var g;
      g = _.groupBy(all_words, 'size');
      _.each(g, function(words, size) {
        size = parseInt(size, 10);
        _.each(words, function(w) {
          var related, wordRel;
          related = _.filter(words, function(ww) {
            var flag, k, w1, w2, _ref;
            w1 = w.word;
            w2 = ww.word;
            flag = false;
            for (k = 0, _ref = w1.length - 1; 0 <= _ref ? k <= _ref : k >= _ref; 0 <= _ref ? k++ : k--) {
              if (w1.charAt(k) !== w2.charAt(k)) {
                if (flag) {
                  return false;
                }
                flag = true;
              }
            }
            return true;
          });
          if (related.length !== 0) {
            wordRel = new WordRelModel({
              word: w,
              related: related
            });
            return wordRel.save();
          }
        });
        return console.log('DONE size', size);
      });
      return console.log('----------REL DONE');
    });
  });
};
importRel();
app = express();
app.use(assets());
app.use(express.static(process.cwd() + '/public'));
app.set('view engine', 'jade');
app.get('/', function(req, resp) {
  return resp.render('index');
});
port = process.env.PORT || process.env.VMC_APP_PORT || 3000;
app.listen(port, function() {
  return console.log("Listening on " + port + "\nPress CTRL-C to stop server.");
});