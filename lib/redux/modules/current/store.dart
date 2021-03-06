import '../common/model.dart';
import 'actions.dart';

export 'actions.dart';

final List<Type> _collectionActions = [
  SetCurrent,
  ResetCurrent,
];

KuzzleState currentReducer(KuzzleState state, dynamic action) {
  for (var actionType in _collectionActions) {
    if (actionType == action.runtimeType) {
      return action.mutate(state);
    }
  }
  return state;
}
