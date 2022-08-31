import 'dart:developer' as dev;

/// The log level.
enum LogLevel {
  /// Any error that is forcing a shutdown of the service or application to prevent data loss (or further data loss).
  /// I reserve these only for the most heinous errors and situations where
  /// there is guaranteed to have been data corruption or loss.
  FATAL,

  /// Any error which is fatal to the operation, but not the service or application
  /// (can’t open a required file, missing data, etc.). These errors will force user (administrator, or direct user)
  /// intervention. These are usually reserved (in my apps) for incorrect connection strings, missing services, etc.
  ERROR,

  /// Anything that can potentially cause application oddities, but for which I am automatically recovering.
  /// (Such as switching from a primary to backup server, retrying an operation, missing secondary data, etc.)
  WARNING,

  /// Generally useful information to log (service start/stop, configuration assumptions, etc).
  /// Info I want to always have available but usually don’t care about under normal circumstances.
  INFO,

  /// Information that is diagnostically helpful to people more than just developers (IT, sysadmins, etc.).
  DEBUG,

  /// Only when I would be “tracing” the code and trying to find one part of a function specifically.
  TRACE,
}

enum LogType { GENERAL, CONFIG, LAYOUT, STORAGE, DATA, COMMAND, UI }

/// The log level which is always logged, independent from the type.
const LogLevel MINIMUM_LOG = LogLevel.WARNING;

class LOGGER {
  // ignore: non_constant_identifier_names
  static Map<LogType, LogLevel> LOG_SETTINGS = {
    LogType.GENERAL: LogLevel.ERROR,
    LogType.CONFIG: LogLevel.ERROR,
    LogType.LAYOUT: LogLevel.ERROR,
    LogType.STORAGE: LogLevel.ERROR,
    LogType.DATA: LogLevel.ERROR,
    LogType.COMMAND: LogLevel.ERROR,
    LogType.UI: LogLevel.ERROR,
  };

  static logs({
    required List<LogType> pTypes,
    required LogLevel pLevel,
    dynamic pMessage,
    Object? pError,
    StackTrace? pStacktrace,
  }) {
    bool canLog = MINIMUM_LOG.index >= pLevel.index;

    if (!canLog) {
      for (LogType logType in pTypes) {
        LogLevel? logLevel = LOG_SETTINGS[logType];

        if (logLevel != null && logLevel.index >= pLevel.index) {
          canLog = true;
          break;
        }
      }
    }

    if (canLog) {
      _log(
        pLevel: pLevel,
        pMessage: pMessage,
        pError: pError,
        pStacktrace: pStacktrace,
      );
    }
  }

  static logsF({required List<LogType> pTypes, dynamic pMessage, Object? pError, StackTrace? pStacktrace}) {
    logs(pLevel: LogLevel.FATAL, pTypes: pTypes, pMessage: pMessage, pError: pError, pStacktrace: pStacktrace);
  }

  static logsE({required List<LogType> pTypes, dynamic pMessage, Object? pError, StackTrace? pStacktrace}) {
    logs(pLevel: LogLevel.ERROR, pTypes: pTypes, pMessage: pMessage, pError: pError, pStacktrace: pStacktrace);
  }

  static logsW({required List<LogType> pTypes, dynamic pMessage, Object? pError, StackTrace? pStacktrace}) {
    logs(pLevel: LogLevel.WARNING, pTypes: pTypes, pMessage: pMessage, pError: pError, pStacktrace: pStacktrace);
  }

  static logsI({required List<LogType> pTypes, dynamic pMessage, Object? pError, StackTrace? pStacktrace}) {
    logs(pLevel: LogLevel.INFO, pTypes: pTypes, pMessage: pMessage, pError: pError, pStacktrace: pStacktrace);
  }

  static logsD({required List<LogType> pTypes, dynamic pMessage, Object? pError, StackTrace? pStacktrace}) {
    logs(pLevel: LogLevel.DEBUG, pTypes: pTypes, pMessage: pMessage, pError: pError, pStacktrace: pStacktrace);
  }

  static logsT({required List<LogType> pTypes, dynamic pMessage, Object? pError, StackTrace? pStacktrace}) {
    logs(pLevel: LogLevel.TRACE, pTypes: pTypes, pMessage: pMessage, pError: pError, pStacktrace: pStacktrace);
  }

  static log({
    required LogType pType,
    required LogLevel pLevel,
    dynamic pMessage,
    Object? pError,
    StackTrace? pStacktrace,
  }) {
    bool canLog = MINIMUM_LOG.index >= pLevel.index;

    if (!canLog) {
      LogLevel? logLevel = LOG_SETTINGS[pType];
      canLog = logLevel != null && logLevel.index >= pLevel.index;
    }

    if (canLog) {
      _log(
        pLevel: pLevel,
        pMessage: pMessage,
        pError: pError,
        pStacktrace: pStacktrace,
      );
    }
  }

  static logF({required LogType pType, dynamic pMessage, Object? pError, StackTrace? pStacktrace}) {
    log(pLevel: LogLevel.FATAL, pType: pType, pMessage: pMessage, pError: pError, pStacktrace: pStacktrace);
  }

  static logE({required LogType pType, dynamic pMessage, Object? pError, StackTrace? pStacktrace}) {
    log(pLevel: LogLevel.ERROR, pType: pType, pMessage: pMessage, pError: pError, pStacktrace: pStacktrace);
  }

  static logW({required LogType pType, dynamic pMessage, Object? pError, StackTrace? pStacktrace}) {
    log(pLevel: LogLevel.WARNING, pType: pType, pMessage: pMessage, pError: pError, pStacktrace: pStacktrace);
  }

  static logI({required LogType pType, dynamic pMessage, Object? pError, StackTrace? pStacktrace}) {
    log(pLevel: LogLevel.INFO, pType: pType, pMessage: pMessage, pError: pError, pStacktrace: pStacktrace);
  }

  static logD({required LogType pType, dynamic pMessage, Object? pError, StackTrace? pStacktrace}) {
    log(pLevel: LogLevel.DEBUG, pType: pType, pMessage: pMessage, pError: pError, pStacktrace: pStacktrace);
  }

  static logT({required LogType pType, dynamic pMessage, Object? pError, StackTrace? pStacktrace}) {
    log(pLevel: LogLevel.TRACE, pType: pType, pMessage: pMessage, pError: pError, pStacktrace: pStacktrace);
  }

  static _log({
    required LogLevel pLevel,
    dynamic pMessage,
    Object? pError,
    StackTrace? pStacktrace,
  }) {
    dev.log(
      "${pLevel.name}:${pMessage != null ? " $pMessage" : ""}",
      //toString() prevents truncating
      error: pError.toString(),
      stackTrace: pStacktrace,
    );
  }
}
