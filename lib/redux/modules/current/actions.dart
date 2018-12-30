import '../common/actions.dart';
import '../common/model.dart';

class SetCurrent extends Action<KuzzleState> {
  SetCurrent(this.payload);
  final KuzzleState payload;

  @override
  KuzzleState mutate([KuzzleState state]) => payload;
}

class ResetCurrent extends Action<KuzzleState> {
  ResetCurrent();

  @override
  KuzzleState mutate([KuzzleState state]) {
    state.kuzzle.disconect();
    return null;
  }
}

class SetIndexes extends Action<KuzzleState> {
  SetIndexes(this.indexes);

  List<String> indexes;

  @override
  KuzzleState mutate([KuzzleState state]) {
    final indexCollections = <String, List<String>>{};
    for (var index in indexes) {
      indexCollections.addAll({
        index: [],
      });
    }
    return state.copyWith(
      indexes: indexes,
      indexCollections: indexCollections,
    );
  }
}
