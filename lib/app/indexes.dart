import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kuzzle/kuzzle_dart.dart';

import '../components/exiticonbutton.dart';
import '../components/serversubtitle.dart';
import '../redux/instance.dart';
import '../redux/modules/common/model.dart';
import '../redux/modules/current/actions.dart';
import 'collections.dart';

class IndexesPage extends StatefulWidget {
  @override
  _IndexesPageState createState() => _IndexesPageState();
}

class _IndexesPageState extends State<IndexesPage> {
  KuzzleState get current => store.state.current;
  Kuzzle get kuzzle => current;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    try {
      await kuzzle.listIndexes();
      store.dispatch(RefreshCurrent());
    } catch (e) {
      print(e);
      showAboutDialog(
        context: context,
        applicationName: e.toString(),
      );
    }
  }

  Future<void> _incrementCounter() async {
    await kuzzle.createIndex(kuzzle.defaultIndex);
    store.dispatch(RefreshCurrent());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Indexes'),
              ServerSubtitle(),
            ],
          ),
          actions: <Widget>[ExitIconButton()],
        ),
        body: Center(
          child: current.indexes == null
              ? const Text('Loading')
              : ListView(
                  children: <Widget>[
                    Column(
                      children: current.indexes
                          .map((index) => IndexListTile(index, getData))
                          .toList(),
                    ),
                  ],
                ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: current.indexes == null ? null : _incrementCounter,
          tooltip: 'Add',
          child: const Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      );
}

enum IndexListTileOptions {
  delete,
}

class IndexListTile extends StatelessWidget {
  const IndexListTile(this.index, this.deleteCallback);

  final String index;
  final VoidCallback deleteCallback;

  Future<void> onOpenIndexListTile(BuildContext context, String index) async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => CollectionsPage(
              index: index,
            )));
  }

  PopupMenuButton<IndexListTileOptions> _listTilePopup(
          BuildContext context, String server) =>
      PopupMenuButton<IndexListTileOptions>(
        itemBuilder: (context) => <PopupMenuEntry<IndexListTileOptions>>[
              const PopupMenuItem(
                child: Text('Delete'),
                value: IndexListTileOptions.delete,
              ),
            ],
        onSelected: (option) async {
          if (option == IndexListTileOptions.delete) {
            await store.state.current.deleteIndex(index);
            deleteCallback();
          }
        },
      );

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(index),
        onTap: () => onOpenIndexListTile(context, index),
        trailing: _listTilePopup(context, index),
      );
}
