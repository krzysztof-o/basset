var spritesheet = require('../spritesheet.js/index.js');
var chokidar = require('chokidar');
var path = require('path');
var fs = require('fs');
var async = require('async');
var server = require('./lib/server.js');

var argv = require('optimist')
    .usage('Usage: $0 <path>')
    .demand(1)
    .argv;

var PATH = path.resolve(argv._[0]);
console.log('Wacthing ', PATH);

var watcher = chokidar.watch(PATH, {ignored:/^\./, persistent:true});

watcher.on('change', function (file) {
    if (path.resolve(path.dirname(file)) == PATH) return;
    if (!isNotSpritesheetFile(file)) return;
    if (!isImageFile(file)) return;

    console.log('File', file, 'has been changed', path.dirname(file));
    generateSpritesheet(path.dirname(file), function (err) {
        server.send('refresh');
    });
});

async.eachSeries(getAllDirectories(PATH), function (directory, callback) {
    generateSpritesheet(directory, callback);
});
server.connect('localhost', 6000);


function generateSpritesheet(_path, callback) {
    var files = fs.readdirSync(_path);
    files = files.map(function (file) {
        return path.resolve(_path + path.sep + file);
    });
    files = files.filter(isImageFile);
    files = files.filter(isNotSpritesheetFile);

    spritesheet(files, {path:_path, name:'spritesheet', format: 'starling'}, function (err) {
        if (err) throw err;

        if (!err) {
            console.log('spritesheet generated!');
        }
        callback(null);
    });
}

function isImageFile(file) {
    return ['.jpg', '.jpeg', '.png'].indexOf(path.extname(file)) >= 0;
}

function isNotSpritesheetFile(file) {
    return path.basename(file) !== 'spritesheet.png';
}

function getAllDirectories(_path, directories) {
    var directories = directories || [];
    fs.readdirSync(_path).forEach(function (name) {
        var directory = path.resolve(_path + path.sep + name);
        if (fs.lstatSync(directory).isDirectory()) {
            directories.push(directory);
            getAllDirectories(directory, directories);
        }
    });
    return directories;
}
