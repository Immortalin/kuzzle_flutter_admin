import 'package:kuzzle/kuzzle_dart.dart';

class KuzzleState {
  KuzzleState(
    this.host,
    this.port, {
    this.indexes = const [],
    this.indexCollections = const {},
    this.collectionDocuments = const {},
    Kuzzle kuzzle,
  }) {
    if (kuzzle == null) {
      this.kuzzle = Kuzzle(host, port: port, defaultIndex: 'testindex');
    } else {
      this.kuzzle = kuzzle;
    }
  }

  static KuzzleState fromJson(dynamic json) {
    if (json == null || json['host'] == null || json['port'] == null) {
      return null;
    }
    return KuzzleState(
      json['host'],
      json['port'],
      // indexes: json['indexes'],
      // indexCollections: json['indexCollections'],
      // collectionDocuments: json['collectionDocuments'],
    );
  }

  String host;
  int port;
  Kuzzle kuzzle;

  List<String> indexes;
  Map<String, List<String>> indexCollections;
  Map<String, List<dynamic>> collectionDocuments;

  KuzzleState copyWith({
    List<String> indexes,
    Map<String, List<String>> indexCollections,
    Map<String, List<dynamic>> collectionDocuments,
  }) =>
      KuzzleState(
        host,
        port,
        kuzzle: kuzzle,
        indexes: indexes != null ? indexes : this.indexes,
        indexCollections:
            indexCollections != null ? indexCollections : this.indexCollections,
        collectionDocuments: collectionDocuments != null
            ? collectionDocuments
            : this.collectionDocuments,
      );

  dynamic toJson() => {
        'host': host,
        'port': port,
        'indexes': indexes,
        'indexCollections': indexCollections,
        'collectionDocuments': collectionDocuments,
      };
}
