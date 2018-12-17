import 'package:flutter/widgets.dart';
import 'package:kuzzle/kuzzle_dart.dart';

class KuzzleFlutter extends Kuzzle {
  KuzzleFlutter(String host, {@required String defaultIndex, int port = 7512})
      : super(host, defaultIndex: defaultIndex, port: port);

  /// Application level instance which can be called
  /// from anywhere in the app and directly used
  static KuzzleFlutter instance;
}

class KuzzleApp extends StatefulWidget {
  /// It initalizes the instance with the passed [Kuzzle] object
  ///
  /// This instance can be accessed anywhere with [KuzzleFlutter.instance]
  const KuzzleApp({
    @required this.kuzzle,
    @required this.child,
    Key key,
  }) : super(key: key);

  final KuzzleFlutter kuzzle;
  final Widget child;

  @override
  KuzzleAppState createState() => KuzzleAppState();
}

class KuzzleAppState extends State<KuzzleApp> {
  @override
  void initState() {
    KuzzleFlutter.instance = widget.kuzzle;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class KuzzleContainer extends StatelessWidget {
  const KuzzleContainer({this.builder}) : super();

  final Widget Function(BuildContext context, KuzzleFlutter kuzzle) builder;

  @override
  Widget build(BuildContext context) =>
      builder(context, KuzzleFlutter.instance);
}
