import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:kuzzle/kuzzle_dart.dart';

import '../components/error.dart';
import '../components/loading.dart';
import '../helpers/kuzzle_flutter.dart';
import '../models/server.dart';

import 'indexes.dart';
import 'login.dart';

class FlutterApp extends StatelessWidget {
  const FlutterApp({@required this.server, Key key}) : super(key: key);

  final Server server;

  @override
  Widget build(BuildContext context) => KuzzleApp(
        kuzzle: KuzzleFlutter(
          server.host,
          defaultIndex: 'testfromflutter',
          port: server.port,
        ),
        child: RootContainer(),
      );
}

class RootContainer extends StatefulWidget {
  @override
  RootContainerState createState() => RootContainerState();
}

class RootContainerState extends State<RootContainer> {
  String _error;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    tryConnect();
  }

  Future<void> tryConnect() async {
    setState(() {
      isLoading = true;
    });
    try {
      await KuzzleFlutter.instance.connect();
      await KuzzleFlutter.instance.memoryStorage.ping();
    } catch (e) {
      if (e == null || e.toString() == null) {
        setState(() {
          _error = 'Some unknown error occured';
        });
      } else {
        if (e is ResponseError || e is WebSocketChannelException) {
          setState(() {
            _error = e.message;
          });
        } else {
          setState(() {
            _error = e.toString();
          });
        }
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => isLoading
      ? LoadingPage()
      : (_error != null
          ? ErrorPage(_error)
          : KuzzleContainer(
              builder: (context, kuzzle) =>
                  kuzzle.getJwtToken() == null ? LoginPage() : IndexesPage(),
            ));
}
