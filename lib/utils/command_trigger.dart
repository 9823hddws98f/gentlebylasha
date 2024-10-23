import 'dart:async';

class CommandTrigger<TArg, TResult> {
  TResult Function(TArg)? _action;

  void setAction(TResult Function(TArg) action) {
    _action = action;
  }

  TResult trigger(TArg arg) => _action!(arg);

  void clearAction() {
    _action = null;
  }
}

class SimpleCommandTrigger {
  void Function()? _action;

  void setAction(void Function() action) {
    _action = action;
  }

  void trigger() => _action!();

  void clearAction() {
    _action = null;
  }
}

class ActionTrigger {
  FutureOr<void> Function()? _action;

  void setAction(FutureOr<void> Function() action) {
    _action = action;
  }

  FutureOr<void> trigger() => _action?.call();

  void clearAction() {
    _action = null;
  }
}
