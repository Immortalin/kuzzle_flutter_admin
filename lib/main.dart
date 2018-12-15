import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:kuzzle/kuzzle_dart.dart';

import 'helpers/kuzzle_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => KuzzleApp(
        kuzzle: KuzzleFlutter('192.168.1.6', defaultIndex: 'testfromflutter'),
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
      await KuzzleFlutter.instance.getServerInfo();
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
  Widget build(BuildContext context) => MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: isLoading
            ? LoadingPage()
            : (_error == null ? MyHomePage() : ErrorPage(_error)),
      );
}

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
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

class Post extends Object {
  Post.fromDocument(Document document) : title = document.content['title'];

  final String title;
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Post> documents = [];
  Collection collection;
  Room room;

  @override
  void initState() {
    super.initState();
    getData().catchError((error) {
      showAboutDialog(
        context: context,
        applicationName: error.toString(),
      );
    });
  }

  Future<void> getData() async {
    await KuzzleFlutter.instance.login(const Credentials(LoginStrategy.local,
        username: 'admin', password: 'admin'));
    final indexExists = await KuzzleFlutter.instance
        .existsIndex(KuzzleFlutter.instance.defaultIndex);
    if (!indexExists) {
      await KuzzleFlutter.instance
          .createIndex(KuzzleFlutter.instance.defaultIndex);
    }
    collection = KuzzleFlutter.instance.collection('posts');
    final collectionExists = await collection.exists();
    if (!collectionExists) {
      await collection.create();
    }
    final docSearch = await collection.search();
    setState(() {
      documents = docSearch.hits
          .map((document) => Post.fromDocument(document))
          .toList();
    });
    room = await collection.subscribe((data) {
      final dataObj = data.toObject();
      if (dataObj is Document) {
        setState(() {
          documents.add(Post.fromDocument(dataObj));
        });
      }
    }, scope: RoomScope.all, state: RoomState.done, users: RoomUsersScope.all);
  }

  Future<void> _incrementCounter() async {
    await collection.createDocument({
      'title': 'Post title',
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Posts'),
        ),
        body: Center(
          child: room == null
              ? const Text('Loading')
              : ListView(
                  children: <Widget>[
                    Column(
                      children: documents
                          .map((document) => ListTile(
                                title: Text(document.title.toString()),
                              ))
                          .toList(),
                    ),
                  ],
                ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: room == null ? null : _incrementCounter,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      );
}
