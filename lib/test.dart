import 'package:socket_io_client/socket_io_client.dart';

main() {
  Socket socket = io(
      'http://localhost:3000',
      OptionBuilder()
          .setTransports(['websocket']) // for Flutter or Dart VM
          .disableAutoConnect() // disable auto-connection
          .setExtraHeaders({'foo': 'bar'}) // optional
          .build());
  socket.connect();
  socket.onConnect((_) {
    print('connect');
    // socket.emitWithAck('msg', 'athul', ack: (data) {
    //   print('ack $data');
    //   if (data != null) {
    //     print('from server $data');
    //   } else {
    //     print("Null");
    //   }
    // });
  });
  socket.on('board_content', (data) {
    print("event $data");
  });
}
