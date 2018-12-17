class Server {
  Server(this.host, this.port);

  Server.fromMap(Map<String, dynamic> map)
      : host = map['host'],
        port = map['port'];

  final String host;
  final int port;

  Map<String, dynamic> toMap() => {
        'host': host,
        'port': port,
      };
}
