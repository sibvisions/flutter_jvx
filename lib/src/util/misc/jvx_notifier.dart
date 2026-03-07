/*
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

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
