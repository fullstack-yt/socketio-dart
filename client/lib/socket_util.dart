import 'package:socket_io_client/socket_io_client.dart';

///
/// Tries connecting to socket.io server hosted at the connection url.
/// Exectutes [onConnect], [onDisconnect] and [onError] at the
/// specific lifecycle moments.
/// The [handlers] map contains all the custom event handlers,
/// the key is the event name and the value the even handler function.
///
Socket connectToSocket(
  String connectionUrl, {
  required Function(Socket socket) onConnect,
  required Function() onDisconnect,
  required Function() onError,
  required Map<String, Function(dynamic data)> handlers,
}) {
  Socket socket = io(connectionUrl, {
    'transports': ['websocket'],
    'force new connection': true,
  });

  // Adds Lifecycle event functions
  socket.onConnect((data) => onConnect(socket));
  socket.onDisconnect((data) => onDisconnect());
  socket.onConnectError((data) => onError());

  // Loops through the map and adds event handlers
  for (var element in handlers.entries) {
    socket.on(element.key, element.value);
  }
  return socket;
}

/// Sends an 'echo' event along with the [message]
echo(Socket socket, String message) {
  assert(socket.connected, 'Socket must be connected');
  socket.emit('echo', message);
}

/// Sends a 'broadcast' event along with the [message]
broadcast(Socket socket, String message) {
  assert(socket.connected, 'Socket must be connected');
  socket.emit('broadcast', message);
}

/// Sends a 'room' event along with a map containing the [message] and
/// the [room]
room(Socket socket, String message, String room) {
  assert(socket.connected, 'Socket must be connected');
  socket.emit('room', {'message': message, 'room': room});
}

/// Sends a 'joinRoom' event along with the [room]
joinRoom(Socket socket, String room) {
  assert(socket.connected, 'Socket must be connected');
  socket.emit('joinRoom', room);
}
