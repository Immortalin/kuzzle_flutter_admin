import 'package:flutter/material.dart';

import 'package:kuzzle/kuzzle_dart.dart';

import '../helpers/kuzzle_flutter.dart';
import 'documents.dart';

class CollectionsPage extends StatefulWidget {
  const CollectionsPage({@required this.index, Key key}) : super(key: key);

  final String index;

  @override
  CollectionsPageState createState() => CollectionsPageState();
}

class CollectionsPageState extends State<CollectionsPage> {
  List<Collection> collections = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    try {
      final collections =
          await KuzzleFlutter.instance.listCollections(widget.index);
      setState(() {
        this.collections = collections;
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
    // NewCollectionPage
    await KuzzleFlutter.instance.collection('collection').create();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Collectiones'),
        ),
        body: Center(
          child: collections == null
              ? const Text('Loading')
              : ListView(
                  children: <Widget>[
                    Column(
                      children: collections
                          .map((collection) =>
                              CollectionListTile(collection, getData))
                          .toList(),
                    ),
                  ],
                ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: collections == null ? null : _incrementCounter,
          tooltip: 'Add',
          child: const Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      );
}

enum CollectionListTileOptions {
  delete,
}

class CollectionListTile extends StatelessWidget {
  const CollectionListTile(this.collection, this.deleteCallback);

  final Collection collection;
  final VoidCallback deleteCallback;

  Future<void> onOpenCollectionListTile(
      BuildContext context, Collection collection) async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => DocumentsPage(
              collection: collection,
            )));
  }

  PopupMenuButton<CollectionListTileOptions> _listTilePopup(
          Collection collection) =>
      PopupMenuButton<CollectionListTileOptions>(
        itemBuilder: (context) => <PopupMenuEntry<CollectionListTileOptions>>[
              const PopupMenuItem(
                child: Text('Truncate'),
                value: CollectionListTileOptions.delete,
              ),
            ],
        onSelected: (option) async {
          if (option == CollectionListTileOptions.delete) {
            await collection.truncate();
            deleteCallback();
          }
        },
      );

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(collection.collectionName),
        onTap: () => onOpenCollectionListTile(context, collection),
        trailing: _listTilePopup(collection),
      );
}
