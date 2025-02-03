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

enum Lvl {
  a(Level.all),
  all(Level.all),
  o(Level.off),
  off(Level.off),
  e(Level.error),
  error(Level.error),
  d(Level.debug),
  debug(Level.debug),
  f(Level.fatal),
  fatal(Level.fatal),
  i(Level.info),
  info(Level.info),
  t(Level.trace),
  trace(Level.trace),
  w(Level.warning),
  warning(Level.warning);

  final Level level;

  get value => level.value;

  const Lvl(this.level);
}

class JVxLogger extends Logger {

  final LogFilter _filter;

  JVxLogger({required LogFilter filter, required LogPrinter printer}): _filter = filter, super(filter: filter, printer: printer);

  bool cl(Lvl level) {
    return _canLog(level.value);
  }

  bool canLog(Level level) {
    return _canLog(level.value);
  }

  bool _canLog(int value) {
    if (value == Level.off.value) {
      return false;
    }

    if (_filter.level == null) {
      return value >= Logger.level.value;
    }
    else {
      return value >= _filter.level!.value;
    }
  }
}

class JVxFilter extends LogFilter {

  JVxFilter([Level? level]) {
    this.level = level ?? Level.error;
  }

  @override
  bool shouldLog(LogEvent event) {
    if (level! == Level.off) {
      return false;
    }

    return event.level.value >= level!.value;
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
    super.excludePaths,
    super.levelColors,
    super.levelEmojis,
  });

  @override
  String stringifyMessage(message) {
    return super.stringifyMessage("$prefix: $message");
  }
}
