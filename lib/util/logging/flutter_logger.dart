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
const LOG_LEVEL MINIMUM_LOG = LOG_LEVEL.FATAL;

const Map<LOG_TYPE, LOG_LEVEL> LOG_SETTINGS = {
  LOG_TYPE.GENERAL: LOG_LEVEL.ERROR,
  LOG_TYPE.CONFIG: LOG_LEVEL.ERROR,
  LOG_TYPE.LAYOUT: LOG_LEVEL.ERROR,
  LOG_TYPE.STORAGE: LOG_LEVEL.ERROR,
  LOG_TYPE.DATA: LOG_LEVEL.ERROR,
  LOG_TYPE.COMMAND: LOG_LEVEL.ERROR,
  LOG_TYPE.UI: LOG_LEVEL.ERROR,
};

class LOGGER {
  static log(List<LOG_TYPE> pTypes, LOG_LEVEL pLevel, dynamic pMessage, StackTrace? pStacktrace) {
    bool canLog = MINIMUM_LOG.index <= pLevel.index;

    if (!canLog) {
      for (LOG_TYPE logType in pTypes) {
        LOG_LEVEL? logLevel = LOG_SETTINGS[logType];

        if (logLevel != null && logLevel.index <= pLevel.index) {
          canLog = true;
          break;
        }
      }
    }

    if (canLog) {
      dev.log(pMessage.toString());
      if (pStacktrace != null) {
        dev.log(pStacktrace.toString());
      }
    }
  }
}
