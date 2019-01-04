import 'dart:io';
import 'package:redux/redux.dart';
import 'package:redux_logging/redux_logging.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:redux_persist_flutter/redux_persist_flutter.dart';

import './modules/common/actions.dart';
import './modules/common/model.dart';
import './modules/current/store.dart';
import './modules/servers/store.dart';

class ReduxState {
  ReduxState(
      {this.servers = initServersState, this.current, this.rehydrated = false});

  List<KuzzleState> servers = initServersState;
  KuzzleState current;
  bool rehydrated = false;

  ReduxState copyWith({int servers}) =>
      ReduxState(servers: servers ?? this.servers);

  // !!!
  static ReduxState fromJson(dynamic json) {
    print(json);
    return ReduxState(
        servers: json == null || json['servers'] == null
            ? initServersState
            : (json['servers'] as List<dynamic>)
                .map<KuzzleState>(KuzzleState.fromJson)
                .toList(),
        current: json == null ? null : KuzzleState.fromJson(json['current']));
  }

  // !!!
  dynamic toJson() => {
        'servers': servers.map((server) => server.toJson()).toList(),
        'current': current == null ? null : current.toJson(),
      };
}

class InitStateReset extends Action<ReduxState> {
  InitStateReset(this.servers, this.current);
  final List<KuzzleState> servers;
  final KuzzleState current;

  @override
  ReduxState mutate(ReduxState state) {
    state.rehydrated = true;
    state.servers = servers;
    state.current = current;
    return state;
  }
}

ReduxState reducer(ReduxState state, dynamic action) {
  if (action is InitStateReset) {
    return action.mutate(state);
  }
  state.current = currentReducer(state.current, action);
  state.servers = serversReducer(state.servers, action);
  state.rehydrated = state.rehydrated;
  return state;
}

Store<ReduxState> initState() {
  StorageEngine storage;
  if (Platform.isAndroid || Platform.isIOS) {
    storage = FlutterStorage();
  } else {
    storage = FileStorage(File('state.json'));
  }
  final persistor = Persistor<ReduxState>(
    storage: storage, // Or use other engines
    serializer: JsonSerializer<ReduxState>(
        ReduxState.fromJson), // Or use other serializers
  );
  final store = Store<ReduxState>(
    reducer,
    initialState: ReduxState(),
    middleware: [
      LoggingMiddleware.printer(),
      persistor.createMiddleware(),
    ],
  );

  persistor.load().then((state) {
    store.dispatch(InitStateReset(state.servers, state.current));
  });

  return store;
}
