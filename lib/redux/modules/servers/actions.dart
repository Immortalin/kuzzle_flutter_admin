import '../common/actions.dart';
import '../common/model.dart';

const List<KuzzleState> initServersState = [];

class InitServers extends Action<List<KuzzleState>> {
  InitServers(this.payload);
  final List<KuzzleState> payload;

  @override
  List<KuzzleState> mutate([List<KuzzleState> state = initServersState]) =>
      payload;
}

class AddServer extends Action<List<KuzzleState>> {
  AddServer(this.payload);
  final KuzzleState payload;

  @override
  List<KuzzleState> mutate([List<KuzzleState> state = initServersState]) {
    final newstate = state.toList();
    newstate.add(payload);
    return newstate;
  }
}

class DeleteServer extends Action<List<KuzzleState>> {
  DeleteServer(this.payload);
  final KuzzleState payload;

  @override
  List<KuzzleState> mutate([List<KuzzleState> state = initServersState]) {
    final newstate = state.toList();
    newstate.remove(payload);
    return newstate;
  }
}
