import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';
import '../components/filled_button.dart';
import '../components/text_prompt.dart';
import '../main.dart';
import '../socket_util.dart';
import 'package:awesome/awesome.dart';

const colors = [
  Colors.red,
  Colors.blue,
  Colors.green,
  Colors.amber,
  Colors.brown,
  Colors.indigo,
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _message = 'Not connected';
  var _backgroundColor = Colors.white;
  var _fontColor = Colors.black;
  final SheetController _controller = SheetController();
  final TextEditingController _dataController = TextEditingController();
  final FocusNode _node = FocusNode();
  String? _room;
  late ExpansionState _state;

  @override
  void dispose() {
    _node.dispose();
    _controller.dispose();
    super.dispose();
  }

  Socket? handleSubmit() {
    var socketProvider = context.read<SocketProvider>();
    if (socketProvider.socket == null) return null;
    _controller.animateToMinimized(
      duration: const Duration(milliseconds: 400),
    );
    _dataController.clear();
    return socketProvider.socket!;
  }

  handleEcho(data) {
    var socket = handleSubmit();
    if (socket == null) return;
    echo(socket, data);
  }

  handleBroadcast(data) {
    var socket = handleSubmit();
    if (socket == null) return;
    broadcast(socket, data);
  }

  handleRoom(data) {
    var socket = handleSubmit();
    if (socket == null || _room == null) return;
    room(socket, data, _room!);
  }

  handleJoinRoom(data) {
    var socket = handleSubmit();
    if (socket == null) return;
    joinRoom(socket, data);
    setState(() {
      _room = data;
    });
  }

  @override
  void initState() {
    super.initState();
    _state = ExpansionState.minimized;
  }

  handleTap(Function(String data) function) {
    return () {
      if (_dataController.text.isEmpty) return;
      function(_dataController.text);
    };
  }

  @override
  Widget build(BuildContext context) {
    var socketProvider = context.watch<SocketProvider>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: DraggableBottomBar(
        controller: _controller,
        onThreshold: (value) {
          setState(() {
            _state = value ? ExpansionState.step : ExpansionState.minimized;
          });
        },
        onChange: () {
          _node.unfocus();
        },
        bar: Container(),
        modal: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              TextField(
                controller: _dataController,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1,
                ),
                focusNode: _node,
                decoration: InputDecoration(
                  hintText: 'Data',
                  hintStyle: const TextStyle(
                    fontSize: 16,
                  ),
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  fillColor: const Color(0xFFEEEEEE),
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.transparent,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.transparent,
                    ),
                  ),
                ),
                onSubmitted: (data) {
                  handleEcho(data);
                },
                onTap: () {
                  _controller.animateToExpanded(
                    duration: const Duration(milliseconds: 400),
                  );
                  _node.requestFocus();
                },
              ),
              AnimatedOpacity(
                opacity: _state == ExpansionState.minimized ? 0 : 1,
                duration: const Duration(milliseconds: 150),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 16),
                    FilledButton(
                      onTap: handleTap(handleEcho),
                      text: 'Echo',
                      backgroundColor: colors[0],
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onTap: handleTap(handleBroadcast),
                      text: 'Broadcast',
                      backgroundColor: colors[1],
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onTap: handleTap(handleRoom),
                      text: 'To Room',
                      backgroundColor: colors[2],
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onTap: handleTap(handleJoinRoom),
                      text: 'Join Room',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        child: Stack(
          children: [
            Container(
              color: _backgroundColor,
              child: Center(
                child: Text(
                  _message,
                  style: TextStyle(
                    color: _fontColor,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 16.0,
                  top: 8.0,
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: TapScale(
                    onTap: () {
                      if (!(socketProvider.socket?.connected ?? false)) {
                        showTextPrompt(
                          context,
                          title: 'Endpoint',
                          placeholder: 'URL',
                          onSubmit: (url) {
                            connectToSocket(
                              url,
                              onConnect: (socket) {
                                context
                                    .read<SocketProvider>()
                                    .setSocket(socket);
                                setState(() {
                                  _message = 'No event received';
                                });
                              },
                              onDisconnect: () {
                                _fontColor = Colors.black;
                                _backgroundColor = Colors.white;
                                _message = 'Not connected';
                              },
                              onError: () {},
                              handlers: {
                                'echo': (data) {
                                  int random = Random().nextInt(6);
                                  setState(() {
                                    _message = 'Echo:\n\n"$data"';
                                    _fontColor = Colors.white;
                                    _backgroundColor = colors[random];
                                  });
                                },
                                'broadcast': (data) {
                                  int random = Random().nextInt(6);
                                  setState(() {
                                    _message = 'Broadcast:\n\n"$data"';
                                    _fontColor = Colors.white;
                                    _backgroundColor = colors[random];
                                  });
                                },
                                'room': (data) {
                                  int random = Random().nextInt(6);
                                  setState(() {
                                    _message = 'Room:\n\n"$data"';
                                    _fontColor = Colors.white;
                                    _backgroundColor = colors[random];
                                  });
                                },
                                'join': (data) {
                                  int random = Random().nextInt(6);
                                  setState(() {
                                    _message = 'Joined Room:\n\n$data';
                                    _fontColor = Colors.white;
                                    _backgroundColor = colors[random];
                                  });
                                },
                              },
                            );
                          },
                        );
                      } else {
                        socketProvider.socket?.disconnect();
                        context.read<SocketProvider>().setSocket(null);
                      }
                    },
                    child: SizedBox(
                      height: 44,
                      width: 44,
                      child: (socketProvider.socket?.connected ?? false)
                          ? Image.asset('assets/lightning.png')
                          : Image.asset('assets/lightning_slash.png'),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
