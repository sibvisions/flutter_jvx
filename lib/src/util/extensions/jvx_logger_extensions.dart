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
