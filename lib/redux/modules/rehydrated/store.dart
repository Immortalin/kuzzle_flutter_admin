import '../common/actions.dart';

class RehydratedAction extends Action<bool> {
  @override
  bool mutate(bool state) => true;
}

bool rehydratedReducer(bool state, dynamic action) {
  if (action is RehydratedAction) {
    return action.mutate(state);
  }
  return state;
}
