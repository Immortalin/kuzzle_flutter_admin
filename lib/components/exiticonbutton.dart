import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../redux/modules/current/actions.dart';
import '../redux/store.dart';

class ExitIconButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => StoreConnector<ReduxState, bool>(
        converter: (store) => store.state.current != null,
        builder: (context, isCurrent) =>
            isCurrent ? _ExitIconButton() : Container(),
      );
}

class _ExitIconButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      StoreConnector<ReduxState, VoidCallback>(
        converter: (store) => () => store.dispatch(ResetCurrent()),
        builder: (context, callback) => IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () {
                callback();
              },
            ),
      );
}
