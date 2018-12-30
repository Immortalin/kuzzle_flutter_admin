import 'dart:io';
import 'package:flutter/material.dart';

import '../redux/instance.dart';
import '../redux/modules/current/actions.dart';

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () {
                store.dispatch(ResetCurrent());
              },
            )
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              Text('Loading'),
            ],
          ),
        ),
      );
}
