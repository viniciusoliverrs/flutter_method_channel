import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(
    const MaterialApp(
      title: "Platform Channel",
      home: HomeView(),
    ),
  );
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String _helloWorld = "";
  final platformChannelService = PlatformChannelService();
  static const stream =  EventChannel("com.example.platform_channel/stream");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(_helloWorld),
            ElevatedButton(
              onPressed: () async {
                final platformChannelService = PlatformChannelService();
                final result = await platformChannelService.callSimplesMethodChannel();
                setState(() {
                  _helloWorld = result;
                });
              },
              child: const Text("Get String"),
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await platformChannelService.callSimpleMethodChannelWithParams("Vinicius");
                setState(() {
                  _helloWorld = result;
                });
              },
              child: const Text("Get With Params"),
            ),
            Text("Stream Method Channel Result"),
            StreamBuilder(
                stream: stream.receiveBroadcastStream(),
                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  return Text("${snapshot.data}");
                })
          ],
        ),
      ),
    );
  }
}

class PlatformChannelService {
  final platform = const MethodChannel("com.example.platform_channel/hello");
  PlatformChannelService() {
    platform.setMethodCallHandler(_callbackPlatformChannel);
  }

  Future<String> callSimplesMethodChannel() async => await platform.invokeMethod("getHelloWorld");
  Future<String> callSimpleMethodChannelWithParams(String param) async {
    if(param == null || param.isEmpty) return "";
    return await platform.invokeMethod("getHelloWorld",{"user":param});
  }

  Future<void> _callbackPlatformChannel(MethodCall call) async {
    final String args = call.arguments;
    switch(call.method) {
      case "methodCallback":
        print("Method channel callback -> $args");
    }
  }
}
