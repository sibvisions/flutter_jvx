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

import 'dart:async';

class Debounce {
  Debounce({
    this.delay = const Duration(milliseconds: 300),
  });

  final Duration delay;
  Timer? _timer;

  void call(void Function() callback) {
    if (_timer == null) {
      callback.call();
    }
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  void dispose() {
    _timer?.cancel(); // You can comment-out this line if you want. I am not sure if this call brings any value.
    _timer = null;
  }
}
