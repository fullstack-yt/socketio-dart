import 'package:socket_io/socket_io.dart';

handler(data) {}

void main(List<String> arguments) {
  Server io = Server();
  io.on('connection', (client) {
    client.on('echo', (data) {
      client.emit('echo', data);
    });

    client.on('broadcast', (data) {
      io.emit('broadcast', data);
    });

    client.on('joinRoom', (data) {
      client.join(data.toString());
      client.emit('join', data);
    });

    client.on('room', (data) {
      io.to(data['room']).emit('room', data['message']);
    });
  });

  io.listen(3000);
}
