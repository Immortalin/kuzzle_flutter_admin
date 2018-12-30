import 'package:flutter/material.dart';
import 'package:kuzzle/kuzzle_dart.dart';

import '../redux/instance.dart';
import '../redux/modules/current/actions.dart';
import 'collections.dart';

class IndexesPage extends StatefulWidget {
  @override
  _IndexesPageState createState() => _IndexesPageState();
}

class _IndexesPageState extends State<IndexesPage> {
  Kuzzle get kuzzle => store.state.current.kuzzle;
  List<String> indexes = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    try {
      final indexes = await kuzzle.listIndexes();
      setState(() {
        this.indexes = indexes;
      });
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
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Indexes'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                store.dispatch(ResetCurrent());
              },
            )
          ],
        ),
        body: Center(
          child: indexes == null
              ? const Text('Loading')
              : ListView(
                  children: <Widget>[
                    Column(
                      children: indexes
                          .map((index) => IndexListTile(index, getData))
                          .toList(),
                    ),
                  ],
                ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: indexes == null ? null : _incrementCounter,
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
            await store.state.current.kuzzle.deleteIndex(index);
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
