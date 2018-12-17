import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage(this.error);
  final String error;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(error == null ? '' : error),
            ],
          ),
        ),
      );
}
