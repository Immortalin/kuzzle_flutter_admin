import 'dart:io';
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'app/root.dart';
import 'components/loading.dart';

import 'redux/instance.dart';
import 'redux/modules/common/model.dart';
import 'redux/modules/current/actions.dart';
import 'redux/modules/servers/actions.dart';
import 'redux/store.dart';

/// If the current platform is desktop, override the default platform to
/// a supported platform (iOS for macOS, Android for Linux and Windows).
/// Otherwise, do nothing.
void _setTargetPlatformForDesktop() {
  TargetPlatform targetPlatform;
  if (Platform.isMacOS) {
    targetPlatform = TargetPlatform.iOS;
  } else if (Platform.isLinux || Platform.isWindows) {
    targetPlatform = TargetPlatform.android;
  }
  if (targetPlatform != null) {
    debugDefaultTargetPlatformOverride = targetPlatform;
  }
}

void main() {
  _setTargetPlatformForDesktop();
  try {
    runApp(
      StoreProvider<ReduxState>(
        store: store,
        child: App(),
      ),
    );
  } catch (e) {
    runApp(MaterialApp(
      title: 'Error',
      home: Scaffold(
        body: Container(
          child: Text(e.toString()),
        ),
      ),
    ));
  }
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  void onSave(KuzzleState server) {
    store.dispatch(AddServer(KuzzleState(server.host, server.port)));
  }

  void onDelete(KuzzleState server) {
    store.dispatch(DeleteServer(server));
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
        ),
        home: StoreConnector<ReduxState, ReduxState>(
          converter: (store) => store.state,
          builder: (context, state) =>
              state.rehydrated == false || state.servers == null
                  ? LoadingPage()
                  : Container(
                      child: state.servers.isEmpty
                          ? NewServerPage(onSave)
                          : state.current == null
                              ? ServersListPage(
                                  state.servers,
                                  onDelete,
                                  onSaveCallback: onSave,
                                )
                              : FlutterApp(),
                    ),
        ),
      );
}

class NewServerPage extends StatelessWidget {
  NewServerPage(this.onSaveCallback);

  final void Function(KuzzleState) onSaveCallback;

  final TextEditingController hostEditingController =
      TextEditingController(text: '127.0.0.1');
  final TextEditingController portEditingController =
      TextEditingController(text: '7512');

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('New Server'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () => onSaveCallback(KuzzleState(
                  hostEditingController.text,
                  int.parse(portEditingController.text))),
            )
          ],
        ),
        body: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: hostEditingController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(labelText: 'Host'),
              ),
              TextFormField(
                controller: portEditingController,
                keyboardType: const TextInputType.numberWithOptions(
                    signed: true, decimal: false),
                decoration: const InputDecoration(labelText: 'Port'),
              ),
            ],
          ),
        ),
      );
}

enum ServerListTileOptions {
  delete,
}

class ServersListPage extends StatelessWidget {
  const ServersListPage(this.servers, this.deleteCallback,
      {this.onSaveCallback});

  final List<KuzzleState> servers;
  final void Function(KuzzleState) deleteCallback;
  final void Function(KuzzleState) onSaveCallback;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Saved servers'),
        ),
        body: ListView(
          children: servers
              .map((server) =>
                  ServerListTile(server, () => deleteCallback(server)))
              .toList(),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => NewServerPage((server) {
                      Navigator.of(context).pop();
                      onSaveCallback(server);
                    })));
          },
        ),
      );
}

class ServerListTile extends StatefulWidget {
  const ServerListTile(this.server, this.deleteCallback);

  final KuzzleState server;
  final VoidCallback deleteCallback;

  @override
  ServerListTileState createState() => ServerListTileState();
}

class ServerListTileState extends State<ServerListTile> {
  void onOpenServer(BuildContext context, KuzzleState server) =>
      store.dispatch(SetCurrent(server));

  PopupMenuButton<ServerListTileOptions> _listTilePopup(KuzzleState server) =>
      PopupMenuButton<ServerListTileOptions>(
        itemBuilder: (context) => <PopupMenuEntry<ServerListTileOptions>>[
              const PopupMenuItem(
                child: Text('Delete'),
                value: ServerListTileOptions.delete,
              ),
            ],
        onSelected: (option) {
          if (option == ServerListTileOptions.delete) {
            widget.deleteCallback();
          }
        },
      );

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(widget.server.host),
        onTap: () => onOpenServer(context, widget.server),
        trailing: _listTilePopup(widget.server),
      );
}
