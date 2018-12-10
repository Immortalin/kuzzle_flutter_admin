import 'package:flutter/widgets.dart';
import 'package:kuzzle_dart/kuzzle_dart.dart';

class KuzzleFlutter {
  KuzzleFlutter(this.kuzzle) {
    instance = this;
  }

  /// Application level instance which can be called
  /// from anywhere in the app and directly used
  static KuzzleFlutter instance;

  final Kuzzle kuzzle;
}

class KuzzleApp extends StatefulWidget {
  const KuzzleApp({
    @required this.kuzzle,
    @required this.child,
    Key key,
  }) : super(key: key);

  final Kuzzle kuzzle;
  final Widget child;

  @override
  KuzzleAppState createState() => KuzzleAppState();
}

class KuzzleAppState extends State<KuzzleApp> {
  @override
  void initState() {
    KuzzleFlutter.instance = KuzzleFlutter(widget.kuzzle);
    super.initState();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class KuzzleContainer extends StatelessWidget {
  const KuzzleContainer({this.builder}) : super();

  final Widget Function(BuildContext context, Kuzzle kuzzle) builder;

  @override
  Widget build(BuildContext context) =>
      builder(context, KuzzleFlutter.instance.kuzzle);
}
