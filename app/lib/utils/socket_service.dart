import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SocketService {
  io.Socket? socket;
  static final SocketService _instance = SocketService._internal();

  factory SocketService() {
    return _instance;
  }

  SocketService._internal();

  void connect() {
    socket = io.io('${dotenv.env['SERVER_URL']}/room', <String, dynamic>{
      'transports': ['websocket'],
      'path': '/socket.io',
      'autoConnect': true,
      'reconnection': true,
    });

    // 연결 시 이벤트 리스너 설정
    socket?.onConnect((_) {
      print('Socket connected');
    });

    socket?.onError((error) {
      print('Socket connection error: $error');
    });

    socket?.onDisconnect((_) {
      print('Socket disconnected');
    });

    socket?.connect();
  }

  void disconnect() {
    socket?.disconnect();
    socket = null;
  }
}
