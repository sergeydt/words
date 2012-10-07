var Graph, WordModel, app, assets, db, express, importRel, importWords, port, stylus, _;
express = require('express');
stylus = require('stylus');
assets = require('connect-assets');
_ = require('underscore');
db = require('./model');
WordModel = db.WordModel;
Graph = require('./graph');
importWords = function(callback) {
  return WordModel.remove({}, function() {
    var arr, file;
    file = require('fs').readFileSync('./data/words', 'utf8');
    arr = _.each(file.split('\n'), function(w) {
      var word;
      if (!w.replace(/\s*/g, '') || w.length < 3) {
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
importRel = function(SIZE, callback) {
  return WordModel.find({}, function(err, all_words) {
    var g;
    g = _.groupBy(all_words, 'size');
    _.each(g, function(words, size) {
      size = parseInt(size, 10);
      if (size < 3) {
        return;
      }
      if (size !== SIZE) {
        return;
      }
      console.log('START size', size);
      _.each(words, function(w) {
        var related;
        related = _.filter(words, function(ww) {
          var flag, k, w1, w2, _ref;
          w1 = w.word;
          w2 = ww.word;
          if (w1 === w2) {
            return false;
          }
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
        w.rel_size = related.length;
        w.related = related;
        return w.save();
      });
      return console.log('DONE size', size);
    });
    return console.log('----------REL DONE');
  });
};
app = express();
app.use(assets());
app.use(express.static(process.cwd() + '/public'));
app.set('view engine', 'jade');
app.use(function(req, res, next) {
  res.locals({
    result: '',
    w1: req.param('w1'),
    w2: req.param('w2')
  });
  return next();
});
app.get('/', function(req, resp) {
  return resp.render('index');
});
app.get('/words', function(req, res) {
  var s1, s2;
  s1 = req.param('w1');
  s2 = req.param('w2');
  console.log('words', {
    s1: s1,
    s2: s2
  });
  return WordModel.find({
    size: s1.length,
    rel_size: {
      $gt: 0
    }
  }).populate('related').exec(function(err, all_words) {
    var graph, map, mess, w1, w2, x, z;
    map = {};
    _.each(all_words, function(w) {
      var o;
      o = {};
      _.each(w.related, function(r) {
        return o[r._id] = 1;
      });
      return map[w._id] = o;
    });
    graph = new Graph(map);
    w1 = _.find(all_words, function(w) {
      return w.word === s1;
    });
    w2 = _.find(all_words, function(w) {
      return w.word === s2;
    });
    if (!w1 || !w2) {
      mess = 'word not found';
      console.log(mess, {
        w1: w1,
        w2: w2
      });
      return res.render('index', {
        result: mess
      });
    }
    z = graph.findShortestPath(w1._id, w2._id);
    if (!z) {
      mess = 'path not found';
      console.log('path not found');
      return res.render('index', {
        result: mess
      });
    }
    x = _.map(z, function(id) {
      var word;
      word = _.find(all_words, function(w) {
        return w._id.toString() === id.toString();
      });
      return word != null ? word.word : void 0;
    });
    console.log('z', z);
    console.log('x', x.join(' '));
    return res.render('index', {
      result: x
    });
  });
});
port = process.env.PORT || process.env.VMC_APP_PORT || 3000;
app.listen(port, function() {
  return console.log("Listening on " + port + "\nPress CTRL-C to stop server.");
});