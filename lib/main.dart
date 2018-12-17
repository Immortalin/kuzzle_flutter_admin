import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/root.dart';
import 'components/loading.dart';
import 'helpers/kuzzle_flutter.dart';
import 'models/server.dart';

void main() => runApp(App());

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  List<Server> servers;
  SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();
    getServers();
  }

  Future<void> getServers() async {
    sharedPreferences = await SharedPreferences.getInstance();
    try {
      final serverInString = sharedPreferences.get('servers');
      final serversDynamic = json.decode(serverInString);
      final servers = serversDynamic
          .map<Server>((server) => Server.fromMap(server))
          .toList();
      setState(() {
        this.servers = servers;
      });
    } catch (e) {
      print(e);
      setState(() {
        servers = [];
      });
    }
  }

  Future<void> saveServers() async {
    sharedPreferences.setString('servers',
        json.encode(servers.map((server) => server.toMap()).toList()));
  }

  void onSave(Server server) {
    setState(() {
      servers.add(server);
    });
    saveServers();
  }

  void onDelete(Server server) {
    setState(() {
      servers.remove(server);
    });
    saveServers();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: servers == null
            ? LoadingPage()
            : Container(
                child: servers.isEmpty
                    ? NewServerPage(onSave)
                    : ServersListPage(
                        servers,
                        onDelete,
                        onSaveCallback: onSave,
                      ),
              ),
      );
}

class NewServerPage extends StatelessWidget {
  NewServerPage(this.onSaveCallback);

  final void Function(Server) onSaveCallback;

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
              onPressed: () => onSaveCallback(Server(hostEditingController.text,
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

  final List<Server> servers;
  final void Function(Server) deleteCallback;
  final void Function(Server) onSaveCallback;

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

class ServerListTile extends StatelessWidget {
  const ServerListTile(this.server, this.deleteCallback);

  final Server server;
  final VoidCallback deleteCallback;

  Future<void> onOpenServer(BuildContext context, Server server) async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => FlutterApp(
              server: server,
            )));
    if (KuzzleFlutter.instance != null) {
      KuzzleFlutter.instance.disconect();
      KuzzleFlutter.instance = null;
    }
  }

  PopupMenuButton<ServerListTileOptions> _listTilePopup(Server server) =>
      PopupMenuButton<ServerListTileOptions>(
        itemBuilder: (context) => <PopupMenuEntry<ServerListTileOptions>>[
              const PopupMenuItem(
                child: Text('Delete'),
                value: ServerListTileOptions.delete,
              ),
            ],
        onSelected: (option) {
          if (option == ServerListTileOptions.delete) {
            deleteCallback();
          }
        },
      );

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(server.host),
        onTap: () => onOpenServer(context, server),
        trailing: _listTilePopup(server),
      );
}
