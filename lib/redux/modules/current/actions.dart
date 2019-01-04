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
    state.disconect();
    return null;
  }
}

class RefreshCurrent extends Action<KuzzleState> {
  RefreshCurrent();

  @override
  KuzzleState mutate([KuzzleState state]) => state.copyWith();
}
