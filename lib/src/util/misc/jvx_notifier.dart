import 'package:flutter/foundation.dart';

/// Is used to report changes, but does not hold a value, only a getter function.
class JVxNotifier<T> extends ChangeNotifier implements ValueListenable<T> {
  final T Function() getterFunction;

  JVxNotifier(this.getterFunction);

  @override
  T get value => getterFunction.call();

  @override
  String toString() => '${describeIdentity(this)}($value)';

  /// Notify listeners
  void notify() {
    notifyListeners();
  }
}

/// It is only used to report changes, not what the changes entail nor a value.
class JVxChangeNotifier extends JVxNotifier<void> {
  JVxChangeNotifier() : super(() {});

  @override
  String toString() => describeIdentity(this);
}
