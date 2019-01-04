import 'dart:convert';
import 'package:kuzzle/kuzzle_dart.dart';
import 'package:kuzzle_imitation/kuzzle_imitation.dart';

class KuzzleState extends Kuzzle {
  KuzzleState(
    String host,
    int port, {
    ImitationServer imitationServer,
  }) : super(host, port: port, defaultIndex: 'testindex') {
    imitationServer ??= ImitationServer();
    this.imitationServer = imitationServer;
  }

  @override
  void networkQuery(Map<String, dynamic> body) {
    super.networkQuery(body);
    final response = json.decode(imitationServer.transform(json.encode(body)));
    requestToExpected[body['requestId']] = response;
  }

  @override
  void onStreamListen(dynamic message) {
    super.onStreamListen(message);
    final jsn = json.decode(message);
    if (requestToExpected.containsKey(jsn['requestId'])) {
      compareResults(requestToExpected[jsn['requestId']], jsn);
    }
  }

  void compareResults(dynamic expected, dynamic actual) {
    if (expected['result'] != actual['result']) {
      imitationServer.updateData(actual);
    }
  }

  static KuzzleState fromJson(dynamic json) {
    if (json == null || json['host'] == null || json['port'] == null) {
      return null;
    }
    return KuzzleState(
      json['host'],
      json['port'],
    );
  }

  KuzzleState copyWith() => KuzzleState(
        host,
        port,
        imitationServer: imitationServer,
      );

  Iterable<String> get indexes => imitationServer.imitationDatabase.db.keys;
  Map<String, dynamic> requestToExpected = {};
  ImitationServer imitationServer;

  dynamic toJson() => {
        'host': host,
        'port': port,
      };
}
