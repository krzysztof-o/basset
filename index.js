var spritesheet = require('../spritesheet.js/spritesheet.js');
var chokidar = require('chokidar');
var path = require('path');
var fs = require('fs');
var async = require('async');
var server = require('./lib/server.js');

var PATH = 'assets';
var watcher = chokidar.watch(PATH, {ignored: /^\./, persistent: true});

watcher.on('change', function (file) {
  if (!isNotSpritesheetFile(file)) return;
//  if (!isImageFile(path)) return;

  console.log('File', file, 'has been changed');
  generateSpritesheet(path.dirname(file), function (err) {
    server.send('refresh');
  });
});

var directories = [PATH].concat(getAllDirectories(PATH));
async.eachSeries(directories, function (directory, callback) {
  //generateSpritesheet(directory, callback);
});
server.connect('localhost', 6000);

function generateSpritesheet(path, callback) {
  var files = fs.readdirSync(path);
  files = files.map(function (file) {
    return path + '/' + file;
  });
  files = files.filter(isImageFile);
  files = files.filter(isNotSpritesheetFile);

  spritesheet(files, {path: path, name: path.substr(Math.max(0, path.lastIndexOf('/') + 1))}, function (err) {
//    if (err) throw err;

    if (!err) {
      console.log('spritesheet generated!');
    }
    callback(null);
  });
}

function isImageFile(file) {
  return ['jpg', '.jpeg', '.png'].indexOf(path.extname(file)) >= 0;
}

function isNotSpritesheetFile(file) {
  return getFilenameWithoutExt(file) !== getSpritesheetName(file);
}

function getSpritesheetName(file) {
  var dirname = path.dirname(file);
  return dirname.substr(Math.max(dirname.lastIndexOf('/') + 1, 0));
}

function getFilenameWithoutExt(file) {
  var basename = path.basename(file);
  return basename.substr(0, basename.lastIndexOf('.'));
}

function getAllDirectories(path, directories) {
  var directories = directories || [];
  fs.readdirSync(path).forEach(function (name) {
    var directory = path + '/' + name;
    if (fs.lstatSync(directory).isDirectory()) {
      directories.push(directory);
      getAllDirectories(directory, directories);
    }
  });
  return directories;
}
