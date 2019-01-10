import 'dart:async';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter/material.dart';
import 'package:kuzzle/kuzzle_dart.dart';

import '../components/serversubtitle.dart';
import '../redux/instance.dart';
import '../redux/modules/current/actions.dart';
import '../redux/store.dart';
import 'documents.dart';

class CollectionsPage extends StatelessWidget {
  const CollectionsPage({@required this.index, Key key}) : super(key: key);

  final String index;
  @override
  Widget build(BuildContext context) =>
      StoreConnector<ReduxState, Iterable<Collection>>(
        converter: (store) => (store.state.current.imitationServer
                .imitationDatabase.db[index].keys as Iterable<String>)
            .map<Collection>((collectionName) =>
                store.state.current.collection(collectionName, index: index)),
        builder: (context, collections) => _CollectionsPage(
              collections: collections,
              index: index,
            ),
      );
}

class _CollectionsPage extends StatefulWidget {
  const _CollectionsPage(
      {@required this.collections, @required this.index, Key key})
      : super(key: key);

  final Iterable<Collection> collections;
  final String index;

  @override
  _CollectionsPageState createState() => _CollectionsPageState();
}

class _CollectionsPageState extends State<_CollectionsPage> {
  Kuzzle get kuzzle => store.state.current;
  Iterable<Collection> get collections => widget.collections;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    try {
      await kuzzle.collection(widget.index).list();
      store.dispatch(RefreshCurrent());
      print(collections);
    } catch (e, stacktrace) {
      print(e);
      print(stacktrace);
      showAboutDialog(
        context: context,
        applicationName: e.toString(),
      );
    }
  }

  Future<void> _incrementCounter() async {
    // NewCollectionPage
    await kuzzle.collection('collection').create();
    store.dispatch(RefreshCurrent());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Collections'),
              ServerSubtitle(
                extraText: widget.index,
              ),
            ],
          ),
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
