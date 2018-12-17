import 'package:flutter/material.dart';

import '../helpers/kuzzle_flutter.dart';
import 'collections.dart';

class IndexesPage extends StatefulWidget {
  @override
  _IndexesPageState createState() => _IndexesPageState();
}

class _IndexesPageState extends State<IndexesPage> {
  List<String> indexes = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    try {
      final indexes = await KuzzleFlutter.instance.listIndexes();
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
    await KuzzleFlutter.instance
        .createIndex(KuzzleFlutter.instance.defaultIndex);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Indexes'),
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

  PopupMenuButton<IndexListTileOptions> _listTilePopup(String server) =>
      PopupMenuButton<IndexListTileOptions>(
        itemBuilder: (context) => <PopupMenuEntry<IndexListTileOptions>>[
              const PopupMenuItem(
                child: Text('Delete'),
                value: IndexListTileOptions.delete,
              ),
            ],
        onSelected: (option) async {
          if (option == IndexListTileOptions.delete) {
            await KuzzleFlutter.instance.deleteIndex(index);
            deleteCallback();
          }
        },
      );

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(index),
        onTap: () => onOpenIndexListTile(context, index),
        trailing: _listTilePopup(index),
      );
}
