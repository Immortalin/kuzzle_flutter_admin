import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kuzzle/kuzzle_dart.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({@required this.collection, Key key}) : super(key: key);

  final Collection collection;

  @override
  DocumentsPageState createState() => DocumentsPageState();
}

class DocumentsPageState extends State<DocumentsPage> {
  List<Document> documents = [];
  Room room;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    try {
      final documentsSearch = await widget.collection.search();
      setState(() {
        documents = documentsSearch.hits;
      });
      final room = await widget.collection.subscribe((data) {
        final dataObj = data.toObject();
        if (dataObj is Document) {
          setState(() {
            documents.add(dataObj);
          });
        }
      },
          scope: RoomScope.all,
          state: RoomState.done,
          users: RoomUsersScope.all);
      setState(() {
        this.room = room;
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
    await widget.collection.createDocument({
      'title': 'Post title',
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Documents'),
        ),
        body: Center(
          child: documents == null
              ? const Text('Loading')
              : ListView(
                  children: <Widget>[
                    Column(
                      children: documents
                          .map(
                              (document) => DocumentListTile(document, getData))
                          .toList(),
                    ),
                  ],
                ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: documents == null ? null : _incrementCounter,
          tooltip: 'Add',
          child: const Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      );
}

enum DocumentListTileOptions {
  delete,
}

class DocumentListTile extends StatelessWidget {
  const DocumentListTile(this.document, this.deleteCallback);

  final Document document;
  final VoidCallback deleteCallback;

  Future<void> onOpenCollectionListTile(
      BuildContext context, Document document) async {
    // await Navigator.of(context).push(MaterialPageRoute(
    //     builder: (context) => DocumentsPage(
    //           collection: collection,
    //         )));
  }

  PopupMenuButton<DocumentListTileOptions> _listTilePopup(Document document) =>
      PopupMenuButton<DocumentListTileOptions>(
        itemBuilder: (context) => <PopupMenuEntry<DocumentListTileOptions>>[
              const PopupMenuItem(
                child: Text('Truncate'),
                value: DocumentListTileOptions.delete,
              ),
            ],
        onSelected: (option) async {
          if (option == DocumentListTileOptions.delete) {
            await document.delete();
            deleteCallback();
          }
        },
      );

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(document.id),
        onTap: () => onOpenCollectionListTile(context, document),
        trailing: _listTilePopup(document),
      );
}
