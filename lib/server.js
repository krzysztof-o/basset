var sys = require('sys');
var net = require('net');
var sockets = [];


exports.connect = function (host, port) {
  var server = net.createServer(onConnection);
  server.listen(port, host);
  console.log('Server Created at ' + host + ':' + port + '\n');
};
exports.send = function (data) {
  sockets.forEach(function (socket) {
    socket.write(data);
  });
};

function onConnection(socket) {
  console.log('Connected: ' + socket.remoteAddress + ':' + socket.remotePort);
  sockets.push(socket);

  socket.on('end', function () {
    console.log('Disconnected: ' + socket.remoteAddress + ':' + socket.remotePort);
    if (sockets.indexOf(socket) >= 0) {
      sockets.splice(sockets.indexOf(socket), 1);
    }
  });
}
