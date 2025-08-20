import 'dart:io';
import 'dart:async';

class TcpServerService {
  ServerSocket? _server;
  final int port;
  final void Function(String message, Socket client)? onMessageReceived;

  TcpServerService({this.port = 4040, this.onMessageReceived});

  Future<void> start() async {
    _server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    print(
        'Servidor escuchando en \\${_server!.address.address}:\\${_server!.port}');
    _server!.listen((Socket client) {
      print('Cliente conectado: \\${client.remoteAddress.address}');
      client.listen((data) {
        final mensaje = String.fromCharCodes(data);
        print('Mensaje recibido: \\${mensaje}');
        if (onMessageReceived != null) {
          onMessageReceived!(mensaje, client);
        }
        // Responde al cliente
        client.write('¡Recibido en Android!: \\${mensaje}');
      });
    });
  }

  Future<void> stop() async {
    await _server?.close();
    _server = null;
  }
}
