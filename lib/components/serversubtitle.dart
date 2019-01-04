import 'package:flutter/material.dart';
import '../redux/instance.dart';
import '../redux/modules/common/model.dart';

class ServerSubtitle extends StatelessWidget {
  const ServerSubtitle({this.extraText = ''});

  KuzzleState get current => store.state.current;
  final String extraText;

  @override
  Widget build(BuildContext context) {
    return Text(
      '${current.host}:${current.port} $extraText',
      style: Theme.of(context).textTheme.subtitle.apply(color: Colors.white),
    );
  }
}
