import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../../flutter_ui.dart';
import '../../service/config/i_config_service.dart';
import '../../service/ui/protect_config.dart';

class AuthService extends ChangeNotifier {

  /// The auth title
  static final String title = 'Scan your fingerprint or face to authenticate';

  /// the global "last" auth-time cache
  static final Map<String, ({DateTime creation, Duration? expires, bool afterResume})> _globalAuthTime = {};

  /// the method channel for platform/native communication
  static const platformChannel = MethodChannel('com.sibvisions.flutter_jvx/security');

  /// whether we use only biometric auth
  static final bool biometricOnly = false;

  /// whether to use native channel communication
  static final bool _useChannel = Platform.isIOS || Platform.isAndroid;

  /// the authentication support
  final LocalAuthentication _auth = LocalAuthentication();

  /// the current configuration list
  List<ProtectConfig>? _config;

  /// the index of invalid configuration
  int _invalidConfigIndex = -1;

  /// whether authentication is supported
  bool _isAuthSupported = true;

  /// whether biometric authentication is possible
  bool _isBiometricAuthPossible = false;

  bool _isAuthenticating = false;
  bool _isAuthenticated = false;
  bool _isCanceled = false;


  AuthService._internal() {
    _auth.isDeviceSupported().then((bool isSupported) async {
      _isAuthSupported = isSupported;

      try {
        if (await _auth.canCheckBiometrics) {

          late List<BiometricType> biometricTypes;

          try {
            biometricTypes = await _auth.getAvailableBiometrics();

            _isBiometricAuthPossible = biometricTypes.isNotEmpty;
          } on PlatformException catch (e) {
            FlutterUI.log.e(e);
          }

          _isBiometricAuthPossible = false;

          notifyListeners();
        }
      } on PlatformException catch (e) {
        FlutterUI.log.e(e);
      }
    });
  }

  static final AuthService instance = AuthService._internal();

  /// Clears biometric authentication cache for [appId] only
  static void clearCache(String? appId) {
    _globalAuthTime.removeWhere((key, value) => key.startsWith("$appId@"));
  }

  /// Clears biometric authentication cache for all applications
  static void clearCacheForAllApps() {
    _globalAuthTime.clear();
  }

  void init(List<ProtectConfig>? config) {
    _config = config;

    if (_config != null && _config!.isNotEmpty) {
      _invalidConfigIndex = - 1;

      _cleanupGlobalAuthTime();

      bool validTime = true;
      bool secureApp = false;

      DateTime now = DateTime.now();

      for (int i = 0; i < _config!.length; i++) {
        ProtectConfig entry = _config![i];

        if (validTime) {
          if (entry.cacheKey != null) {
            var cacheInfo = _globalAuthTime[entry.cacheKey];

            if (cacheInfo != null) {
              validTime = cacheInfo.expires == null || now.difference(cacheInfo.creation) < cacheInfo.expires!;
            }
            else {
              validTime = false;
            }

            if (!validTime) {
              _invalidConfigIndex = i;
            }
          }
        }

        if (entry.secureApp) {
          secureApp = true;
        }
      }

      //only valid if all entries are valid
      _isAuthenticated = validTime;

      setSecure(secureApp);
    }
    else {
      _invalidConfigIndex = -1;

      _isAuthenticated = true;
      _isCanceled = false;

      setSecure(false);
    }
  }

  /// Cleanup expired auth time records
  Future<void> _cleanupGlobalAuthTime() async {
    DateTime now = DateTime.now();

    _globalAuthTime.removeWhere((key, value) => value.expires != null && now.difference(value.creation) >= value.expires!);
  }

  void cancel() {
    if (_isAuthenticating) {
      _isAuthenticating = false;
      _auth.stopAuthentication();
    }

    notifyListeners();
  }

  bool isCanceled() {
    return _isCanceled;
  }

  bool isAuthenticated() {
    return _isAuthenticated;
  }

  bool isAuthSupported() {
    return _isAuthSupported;
  }

  void setSecure(bool secure) {
    if (_useChannel) {
      platformChannel.invokeMethod('setSecure', secure);
    }
  }

  /// Notification about app resumed
  void resumed() {
    bool notify = false;

    if (_config != null && _config!.isNotEmpty) {
      //if we'll find a config which will re-auth after resume ->
      for (int i = 0; i < _config!.length; i++) {
        ProtectConfig entry = _config![i];

        if (entry.reAuthOnlyAfterResume) {
          _invalidConfigIndex = i;
          _isCanceled = false;
          _isAuthenticated = false;

          if (entry.cacheKey != null) {
            _globalAuthTime.remove(entry.cacheKey);
          }

          notify = true;
        }
      }
    }

    String appKey = "${IConfigService().currentApp.value ?? "<undefined>"}@";

    //remove all remaining entries which are marked as resumed (for the same app)
    _globalAuthTime.removeWhere((key, value) => key.startsWith(appKey) && value.afterResume);

    if (notify) {
      notifyListeners();
    }
  }

  Future<void> authenticate([bool checkTimeout = true]) async {
    if (_config == null || _config!.isEmpty) {
      _invalidConfigIndex = -1;
      _isAuthenticated = true;
      _isCanceled = false;

      return;
    }

    if (checkTimeout) {
      _invalidConfigIndex = -1;

      bool validTime = true;

      for (int i = 0; i < _config!.length && validTime; i++) {
        ProtectConfig entry = _config![i];

        if (entry.cacheKey != null) {
          var cacheInfo = _globalAuthTime[entry.cacheKey];

          if (cacheInfo != null) {
            validTime = DateTime.now().difference(cacheInfo.creation) < entry.reAuthTimeout;
          }
          else {
            validTime = false;
          }

          if (!validTime) {
            _invalidConfigIndex = i;
          }
        }
      }

      if (validTime) {
        _isAuthenticated = true;

        notifyListeners();

        return;
      }
    }

    if (_isAuthenticated || (!_isBiometricAuthPossible && biometricOnly)) {
      _invalidConfigIndex = -1;

      _isAuthenticated = true;
      _isCanceled = false;

      return;
    }

    if (_isAuthenticating) {
      return;
    }

    _isAuthenticated = false;
    _isCanceled = false;

    //if we don't have an invalid config, we assume that the last config
    // should be used for authentication
    if (_invalidConfigIndex == -1) {
      _invalidConfigIndex = _config!.length - 1;
    }

    //remove all cached timeouts for entries which are not marked with re-auth after resume
    for (int i = 0; i < _config!.length; i++) {
      if (_config![i].cacheKey != null && !_config![i].reAuthOnlyAfterResume) {
        _globalAuthTime.remove(_config![i].cacheKey);
      }
    }

    bool authenticated = false;
    bool currentAuthStatus = true;

    try {
      _isAuthenticating = true;

      notifyListeners();

      if (_useChannel) {
        await platformChannel.invokeMethod('setAuthStatus', currentAuthStatus);
      }

      authenticated = await _auth.authenticate(
        localizedReason: FlutterUI.translate(title),
        persistAcrossBackgrounding: true,
        biometricOnly: biometricOnly,
      );

      if (_useChannel && authenticated) {
        await platformChannel.invokeMethod('hideBlur');

        await platformChannel.invokeMethod('setAuthStatus', false);
        currentAuthStatus = false;
      }

      _isAuthenticated = authenticated;

      _isAuthenticating = false;
      DateTime now = DateTime.now();

      for (int i = 0; i < _config!.length; i++) {
        ProtectConfig entry = _config![i];

        if (entry.cacheKey != null) {
          _globalAuthTime[entry.cacheKey!] = (
          creation: now,
          expires: entry.reAuthTimeout,
          afterResume: entry.reAuthOnlyAfterResume);
        }
      }

      _notifyAuthentication(true);
    } on LocalAuthException catch (e) {
      FlutterUI.log.e(e);

      if (e.code == LocalAuthExceptionCode.userCanceled
          || e.code == LocalAuthExceptionCode.timeout
          || e.code == LocalAuthExceptionCode.systemCanceled) {

        _isAuthenticating = false;
        _isCanceled = true;

        _notifyAuthentication(false);
      }
      else {
        _isAuthenticating = false;

        _notifyAuthentication(null);
      }
      return;
    } on PlatformException catch (e) {
      FlutterUI.log.e(e);

      _isAuthenticating = false;

      _notifyAuthentication(null);

      return;
    }
    finally {
      if (_useChannel && currentAuthStatus) {
        await platformChannel.invokeMethod('setAuthStatus', false);
      }
    }
  }

  void _notifyAuthentication(bool? state) {
    notifyListeners();

    if (_invalidConfigIndex >= 0) {
      _config![_invalidConfigIndex].onAuthentication?.call(state);
    }
  }

  /// Builds the skeleton widget for the overlay
  Widget buildSkeleton(BuildContext context) {
    if (_config != null && _invalidConfigIndex >= 0 && _invalidConfigIndex < _config!.length) {
      WidgetBuilder? builder = _config![_invalidConfigIndex].skeletonBuilder;

      if (builder != null) {
        return builder(context);
      }
    }

    return Container(color: Theme.of(context).colorScheme.surface);
  }

}
