import 'package:kuzzle/kuzzle_dart.dart';

class KuzzleState {
  KuzzleState(this.host, this.port, {this.allData = const {}}) {
    kuzzle = Kuzzle(host, port: port, defaultIndex: 'testindex');
  }

  static KuzzleState fromJson(dynamic json) {
    if (json == null || json['host'] == null || json['port'] == null) {
      return null;
    }
    return KuzzleState(json['host'], json['port'], allData: json['allData']);
  }

  String host;
  int port;
  Kuzzle kuzzle;

  // {indexname: {collectionname: {documentid: {}}}}
  Map<String, Map<String, Map<String, dynamic>>> allData;

  dynamic toJson() => {
        'host': host,
        'port': port,
        'allData': allData,
      };
}
