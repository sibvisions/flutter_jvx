import 'package:flutter/widgets.dart';

import '../config/i_config_service.dart';

/// true means success, false means cancel, null means error
typedef AuthenticationCallback = void Function(bool? success);

class ProtectConfig {

    /// the default value for reAuth max timeout
    static final Duration _reAuthMaxTimeoutDefault = const Duration(hours: 24);

    /// the current reAuth max timeout
    static Duration _reAuthMaxTimeout = _reAuthMaxTimeoutDefault;

    static Duration get reAuthMaxTimeout => _reAuthMaxTimeout;

    static set reAuthMaxTimeout(Duration? duration) {
      if (duration == null) {
        _reAuthMaxTimeout = _reAuthMaxTimeoutDefault;
      }
      else {
        _reAuthMaxTimeout = duration;
      }
    }

    /// the skeleton builder
    final WidgetBuilder? skeletonBuilder;

    /// the re-authentication timeout (default: 30 seconds)
    final Duration reAuthTimeout;

    /// a caching name for init/destroy independent authentication timeout
    final String? name;

    /// a unique caching key for the current application
    final String? cacheKey;

    /// whether to secure app
    final bool secureApp;

    /// whether to re-auth only after resume
    final bool reAuthOnlyAfterResume;

    /// the authentication callback event
    final AuthenticationCallback? onAuthentication;

    ProtectConfig({
        this.secureApp = true,
        this.name,
        this.reAuthTimeout = const Duration(seconds: 30),
        this.reAuthOnlyAfterResume = false,
        this.onAuthentication,
        this.skeletonBuilder
    }) : cacheKey = "${IConfigService().currentApp.value ?? "<undefined>"}@$name";

    @override
    String toString() {
        return 'ProtectConfig{secureApp: $secureApp, name: $name, reAuthTimeout: $reAuthTimeout, '
               'reAuthOnlyAfterResume: $reAuthOnlyAfterResume, onAuthentication: $onAuthentication, '
               'skeletonBuilder: $skeletonBuilder}';
    }

    @override
    bool operator ==(Object other) {
        if (identical(this, other)) return true;

        return other is ProtectConfig &&
            other.secureApp == secureApp &&
            other.name == name &&
            other.reAuthTimeout == reAuthTimeout &&
            other.reAuthOnlyAfterResume == reAuthOnlyAfterResume &&
            other.onAuthentication == onAuthentication &&
            other.skeletonBuilder == skeletonBuilder;
    }

    @override
    int get hashCode {
      return Object.hash(
        secureApp,
        name,
        reAuthTimeout,
        reAuthOnlyAfterResume,
        onAuthentication,
        skeletonBuilder,
      );
    }

}