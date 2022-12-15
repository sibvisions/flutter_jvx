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

import 'package:logger/logger.dart';

class JVxFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return event.level.index >= level!.index;
  }
}

/// A decorator for a [LogPrinter] that allows for prefixing the logger
class JVxPrefixPrinter extends LogPrinter {
  final LogPrinter _realPrinter;
  final String prefix;

  JVxPrefixPrinter(
    this._realPrinter, {
    required this.prefix,
  });

  @override
  List<String> log(LogEvent event) {
    return _realPrinter.log(event).map((s) => '$prefix$s').toList();
  }
}

/// A override of the [PrettyPrinter] that allows for prefixing the logger
class JVxPrettyPrinter extends PrettyPrinter {
  final String prefix;

  JVxPrettyPrinter({
    required this.prefix,
    super.stackTraceBeginIndex,
    super.methodCount,
    super.errorMethodCount,
    super.lineLength,
    super.colors,
    super.printEmojis,
    super.printTime,
    super.excludeBox,
    super.noBoxingByDefault,
  });

  @override
  String stringifyMessage(message) {
    return super.stringifyMessage("$prefix: $message");
  }
}
