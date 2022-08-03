import 'dart:developer' as dev;

/// The log level.
enum LOG_LEVEL {
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

enum LOG_TYPE { GENERAL, CONFIG, LAYOUT, STORAGE, DATA, COMMAND, UI }

/// The log level which is always logged, independent from the type.
const LOG_LEVEL MINIMUM_LOG = LOG_LEVEL.WARNING;

class LOGGER {
  // ignore: non_constant_identifier_names
  static Map<LOG_TYPE, LOG_LEVEL> LOG_SETTINGS = {
    LOG_TYPE.GENERAL: LOG_LEVEL.ERROR,
    LOG_TYPE.CONFIG: LOG_LEVEL.ERROR,
    LOG_TYPE.LAYOUT: LOG_LEVEL.ERROR,
    LOG_TYPE.STORAGE: LOG_LEVEL.ERROR,
    LOG_TYPE.DATA: LOG_LEVEL.ERROR,
    LOG_TYPE.COMMAND: LOG_LEVEL.ERROR,
    LOG_TYPE.UI: LOG_LEVEL.ERROR,
  };

  static logs({
    required List<LOG_TYPE> pTypes,
    required LOG_LEVEL pLevel,
    dynamic pMessage,
    Object? pError,
    StackTrace? pStacktrace,
  }) {
    bool canLog = MINIMUM_LOG.index >= pLevel.index;

    if (!canLog) {
      for (LOG_TYPE logType in pTypes) {
        LOG_LEVEL? logLevel = LOG_SETTINGS[logType];

        if (logLevel != null && logLevel.index >= pLevel.index) {
          canLog = true;
          break;
        }
      }
    }

    if (canLog) {
      dev.log("$pLevel: " + pMessage.toString(), error: pError, stackTrace: pStacktrace);
    }
  }

  static logsF({required List<LOG_TYPE> pTypes, dynamic pMessage, Object? pError, StackTrace? pStacktrace}) {
    logs(pLevel: LOG_LEVEL.FATAL, pTypes: pTypes, pMessage: pMessage, pError: pError, pStacktrace: pStacktrace);
  }

  static logsE({required List<LOG_TYPE> pTypes, dynamic pMessage, Object? pError, StackTrace? pStacktrace}) {
    logs(pLevel: LOG_LEVEL.ERROR, pTypes: pTypes, pMessage: pMessage, pError: pError, pStacktrace: pStacktrace);
  }

  static logsW({required List<LOG_TYPE> pTypes, dynamic pMessage, Object? pError, StackTrace? pStacktrace}) {
    logs(pLevel: LOG_LEVEL.WARNING, pTypes: pTypes, pMessage: pMessage, pError: pError, pStacktrace: pStacktrace);
  }

  static logsI({required List<LOG_TYPE> pTypes, dynamic pMessage, Object? pError, StackTrace? pStacktrace}) {
    logs(pLevel: LOG_LEVEL.INFO, pTypes: pTypes, pMessage: pMessage, pError: pError, pStacktrace: pStacktrace);
  }

  static logsD({required List<LOG_TYPE> pTypes, dynamic pMessage, Object? pError, StackTrace? pStacktrace}) {
    logs(pLevel: LOG_LEVEL.DEBUG, pTypes: pTypes, pMessage: pMessage, pError: pError, pStacktrace: pStacktrace);
  }

  static logsT({required List<LOG_TYPE> pTypes, dynamic pMessage, Object? pError, StackTrace? pStacktrace}) {
    logs(pLevel: LOG_LEVEL.TRACE, pTypes: pTypes, pMessage: pMessage, pError: pError, pStacktrace: pStacktrace);
  }

  static log(
      {required LOG_TYPE pType, required LOG_LEVEL pLevel, dynamic pMessage, Object? pError, StackTrace? pStacktrace}) {
    bool canLog = MINIMUM_LOG.index >= pLevel.index;

    if (!canLog) {
      LOG_LEVEL? logLevel = LOG_SETTINGS[pType];
      canLog = logLevel != null && logLevel.index >= pLevel.index;
    }

    if (canLog) {
      dev.log("$pLevel: " + pMessage.toString(), error: pError, stackTrace: pStacktrace);
    }
  }

  static logF({required LOG_TYPE pType, dynamic pMessage, Object? pError, StackTrace? pStacktrace}) {
    log(pLevel: LOG_LEVEL.FATAL, pType: pType, pMessage: pMessage, pError: pError, pStacktrace: pStacktrace);
  }

  static logE({required LOG_TYPE pType, dynamic pMessage, Object? pError, StackTrace? pStacktrace}) {
    log(pLevel: LOG_LEVEL.ERROR, pType: pType, pMessage: pMessage, pError: pError, pStacktrace: pStacktrace);
  }

  static logW({required LOG_TYPE pType, dynamic pMessage, Object? pError, StackTrace? pStacktrace}) {
    log(pLevel: LOG_LEVEL.WARNING, pType: pType, pMessage: pMessage, pError: pError, pStacktrace: pStacktrace);
  }

  static logI({required LOG_TYPE pType, dynamic pMessage, Object? pError, StackTrace? pStacktrace}) {
    log(pLevel: LOG_LEVEL.INFO, pType: pType, pMessage: pMessage, pError: pError, pStacktrace: pStacktrace);
  }

  static logD({required LOG_TYPE pType, dynamic pMessage, Object? pError, StackTrace? pStacktrace}) {
    log(pLevel: LOG_LEVEL.DEBUG, pType: pType, pMessage: pMessage, pError: pError, pStacktrace: pStacktrace);
  }

  static logT({required LOG_TYPE pType, dynamic pMessage, Object? pError, StackTrace? pStacktrace}) {
    log(pLevel: LOG_LEVEL.TRACE, pType: pType, pMessage: pMessage, pError: pError, pStacktrace: pStacktrace);
  }
}
