import 'dart:async';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:kuzzle/kuzzle_dart.dart';

import '../components/error.dart';
import '../components/loading.dart';

import '../redux/instance.dart';

import 'indexes.dart';
import 'login.dart';

class FlutterApp extends StatefulWidget {
  @override
  RootContainerState createState() => RootContainerState();
}

class RootContainerState extends State<FlutterApp> {
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
      await store.state.current.kuzzle.connect();
      await store.state.current.kuzzle.memoryStorage.ping();
    } catch (e) {
      if (e == null || e.toString() == null) {
        setState(() {
          _error = 'Some unknown error occured';
        });
      } else {
        print(e);
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
          : store.state.current.kuzzle.getJwtToken() == null
              ? LoginPage()
              : IndexesPage());
}
