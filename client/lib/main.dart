import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';
import './screens/home_screen.dart';

void main() {
  runApp(const SocketApp());
}

class SocketProvider extends ChangeNotifier {
  Socket? socket;

  setSocket(Socket? socket) {
    this.socket = socket;
    notifyListeners();
  }
}

class SocketApp extends StatefulWidget {
  const SocketApp({super.key});

  @override
  State<SocketApp> createState() => _SocketAppState();
}

class _SocketAppState extends State<SocketApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Socket App',
      debugShowCheckedModeBanner: false,
      home: ChangeNotifierProvider<SocketProvider>(
        create: (_) => SocketProvider(),
        child: const HomeScreen(),
      ),
    );
  }
}
