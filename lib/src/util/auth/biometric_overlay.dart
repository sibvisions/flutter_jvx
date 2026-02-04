/*
 * Copyright 2025 SIB Visions GmbH
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

import 'dart:io';
import 'dart:ui';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../../flutter_ui.dart';
import '../../service/ui/protect_config.dart';

class BiometricOverlay extends StatefulWidget {

  /// the authentication callback event
  final ProtectConfig? config;

  const BiometricOverlay({
    super.key,
    required this.config
  });

  @override
  State<BiometricOverlay> createState() => _BiometricOverlayState();

  /// Clears biometric authentication cache for [appId] only
  static void clearCache(String? appId) {
    _BiometricOverlayState.globalAuthTime.removeWhere((key, value) => key.startsWith("$appId@"));
  }

  /// Clears biometric authentication cache for all applications
  static void clearCacheForAllApps() {
    _BiometricOverlayState.globalAuthTime.clear();
  }
}

class _BiometricOverlayState extends State<BiometricOverlay> with WidgetsBindingObserver{
  /// The method channel for platform/native communication
  static const platformChannel = MethodChannel('com.sibvisions.flutter_jvx/security');
  /// Whether to use native channel communication
  static final bool _useChannel = Platform.isIOS || Platform.isAndroid;

  /// the global "last" auth-time cache
  static Map<String, ({DateTime creation, Duration? expires, bool afterResume})> globalAuthTime = {};

  final LocalAuthentication auth = LocalAuthentication();

  /// last successful authentication time
  DateTime? _lastAuthTime;

  Timer? _timer;

  /// The current config (required in case of delayed hide)
  ProtectConfig? _protectConfig;

  /// whether biometric authentication is possible
  bool _isBiometricAuthPossible = false;

  bool _isAuthenticating = false;
  bool _isAuthenticated = false;
  bool _isPaused = false;

  bool _didAuthOnResume = true;

  bool _waitForHide = false;

  ///whether there was a running secondary animation
  bool _hadSecondaryAnimation = false;

  /// whether secure mode was changed by overlay
  bool setSecure = false;

  @override
  void initState() {
    super.initState();

    _protectConfig = widget.config;

    _initAuthState();

    WidgetsBinding.instance.addObserver(this);

    auth.isDeviceSupported().then((bool isSupported) {
      if (isSupported) {
        _initBiometric();
      }
    });

    if (_protectConfig != null && _protectConfig!.secureApp && _useChannel) {
      setSecure = true;

      platformChannel.invokeMethod('setSecure', true);
    }
  }

  @override
  void didUpdateWidget(BiometricOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.config != widget.config) {
      _isAuthenticated = false;

      //if timer is active -> hide overlay is in progress -> don't change config until timer is done
      if (_timer?.isActive != true) {
        _protectConfig = widget.config;
      }

      _initAuthState();

      if (widget.config != null) {
        if (_isBiometricAuthPossible && _useChannel && !setSecure) {
          setSecure = true;
          platformChannel.invokeMethod('setSecure', true);
        }

        if (_isBiometricAuthPossible && mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            //not authenticated with "old" config -> cancel
            if (!_isAuthenticated) {
              _timer?.cancel();

              _waitForHide = false;
              _protectConfig = widget.config;

              if (_isBiometricAuthPossible && _isAuthenticating) {
                unawaited(auth.stopAuthentication());
              }
            }

            _authenticateWithBiometrics();
          });
        }
      }
      else {
        if (_protectConfig != null) {
          _delayedHide();
        }

        if (_isBiometricAuthPossible && _useChannel && setSecure) {
          setSecure = false;
          platformChannel.invokeMethod('setSecure', false);
        }
      }
    }
  }

  void _initAuthState() {
    _cleanupGlobalAuthTime();

    if (widget.config?.cacheKey != null) {
      var cacheInfo = globalAuthTime[widget.config!.cacheKey];
      _lastAuthTime = cacheInfo?.creation;

      if (_lastAuthTime != null && _isLastAuthStillValid()) {
        _isAuthenticated = true;
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();

    if (_isBiometricAuthPossible && _isAuthenticating) {
      unawaited(auth.stopAuthentication());
    }

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();

    if (setSecure) {
      platformChannel.invokeMethod('setSecure', false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _isPaused = false;

      // Don't do auth too often
      if (!_didAuthOnResume) {
        _didAuthOnResume = true;
        _isAuthenticated = false;

        if (_protectConfig?.reAuthOnlyAfterResume == true) {
          _lastAuthTime = null;
        }

        _authenticateWithBiometrics();
      }
    } else if (state == AppLifecycleState.paused) {
      // Triggers re-auth on next resumed event
      _didAuthOnResume = false;
      _isPaused = true;
      _isAuthenticating = false;

      //does nothing under iOS because it's too late - but works under Android
      setState(() {});
    }
  }

  /// Cleanup expired auth time records
  Future<void> _cleanupGlobalAuthTime() async {
    DateTime now = DateTime.now();

    globalAuthTime.removeWhere((key, value) => value.expires != null && now.difference(value.creation) >= value.expires!);
  }

  Future<void> _initBiometric() async {
    try {
      if (await auth.canCheckBiometrics) {
        late List<BiometricType> biometricTypes;

        try {
          biometricTypes = await auth.getAvailableBiometrics();
        } on PlatformException catch (e) {
          FlutterUI.log.e(e);
        }

        _isBiometricAuthPossible = biometricTypes.isNotEmpty;

        if (!mounted) {
          return;
        }

        setState(() {});

        if (_isBiometricAuthPossible) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _authenticateWithBiometrics();
          });
        }
      }
    } on PlatformException catch (e) {
      FlutterUI.log.e(e);
    }
  }

  bool _isLastAuthStillValid() {
    if (_lastAuthTime == null) {
      return false;
    }

    if (widget.config == null) {
      return false;
    }

    if (!widget.config!.reAuthOnlyAfterResume && DateTime.now().difference(_lastAuthTime!) >= widget.config!.reAuthTimeout) {
      return false;
    }

    return true;
  }

  Future<void> _authenticateWithBiometrics() async {
    if (_protectConfig == null) {
      return;
    }

    if (_isLastAuthStillValid()) {
      setState(() {
        _isAuthenticated = true;
      });
      return;
    }

    if (!_isBiometricAuthPossible || _isAuthenticated || _isAuthenticating) {
      return;
    }

    _waitForHide = false;
    _isAuthenticated = false;
    _lastAuthTime = null;

    if (_protectConfig!.cacheKey != null) {
      globalAuthTime.remove(_protectConfig!.cacheKey);
    }

    bool authenticated = false;
    bool currentAuthStatus = true;

    try {
      setState(() {
        _isAuthenticating = true;
      });

      if (_useChannel) {
        await platformChannel.invokeMethod('setAuthStatus', currentAuthStatus);
      }

      authenticated = await auth.authenticate(
        localizedReason: FlutterUI.translate('Scan your fingerprint or face to authenticate'),
        persistAcrossBackgrounding: true,
        //biometricOnly: true,
      );

      if (_useChannel && authenticated) {
        await platformChannel.invokeMethod('hideBlur');

        await platformChannel.invokeMethod('setAuthStatus', false);
        currentAuthStatus = false;
      }

      setState(() {
        _isAuthenticated = authenticated;

        _isAuthenticating = false;
        _lastAuthTime = DateTime.now();

        if (_protectConfig!.cacheKey != null) {
          if (_protectConfig != null) {
            globalAuthTime[_protectConfig!.cacheKey!] = (
              creation: _lastAuthTime!,
              expires: _protectConfig!.reAuthOnlyAfterResume ? ProtectConfig.reAuthMaxTimeout : _protectConfig!.reAuthTimeout,
              afterResume: _protectConfig!.reAuthOnlyAfterResume);
          }
        }
      });

      _notifyListener(true);
    } on LocalAuthException catch (e) {
      FlutterUI.log.e("$e");

      if (e.code == LocalAuthExceptionCode.userCanceled
          || e.code == LocalAuthExceptionCode.systemCanceled) {

        setState(() {
          _isAuthenticating = false;
        });

        if (mounted) {
          _delayedHide();

          _notifyListener(false);
        }
        else {
          _notifyListener(null);
        }
      }
      else {
        setState(() {_isAuthenticating = false;});

        _notifyListener(null);
      }
      return;
    } on PlatformException catch (e) {
      FlutterUI.log.e("$e");

      setState(() {_isAuthenticating = false;});

      _notifyListener(null);

      return;
    }
    finally {
      if (_useChannel && currentAuthStatus) {
        await platformChannel.invokeMethod('setAuthStatus', false);
      }
    }
  }

  void _notifyListener(bool? state) {
    if (_protectConfig?.onAuthentication != null) {
      _protectConfig!.onAuthentication!(state);
    }
  }

  void _delayedHide() {
    _waitForHide = true;

    if (mounted) {
      setState(() {});
    }

    const maxWait = Duration(milliseconds: 800);
    final stopwatch = Stopwatch()..start();

    _hadSecondaryAnimation = false;

    //Check periodic to be sure that animation is really done and UI is
    //painted
    _timer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      final navigator = FlutterUI.getBeamerDelegate().navigatorKey.currentState;

      //We try to find the current route
      Route? currentRoute;
      navigator?.popUntil((route) {
        currentRoute = route;
        return true; // don't pop, just check
      });

      final bool timeoutReached = stopwatch.elapsed >= maxWait;

      bool isFinished = false;
      if (currentRoute is ModalRoute) {
        Animation? primary = (currentRoute as ModalRoute).animation;
        Animation? secondary = (currentRoute as ModalRoute).secondaryAnimation;

        if (secondary != kAlwaysDismissedAnimation && !_hadSecondaryAnimation) {
          _hadSecondaryAnimation = secondary?.value > 0 && secondary!.isAnimating;
        }

        if (primary != kAlwaysDismissedAnimation) {
          isFinished = primary?.value == 1.0 && !primary!.isAnimating;
        }

        if (isFinished && _hadSecondaryAnimation) {
          isFinished = secondary == kAlwaysDismissedAnimation || (secondary?.value == 0.0 && !secondary!.isAnimating);
        }
      }

      if ((isFinished && stopwatch.elapsedMilliseconds >= 350) || timeoutReached) {
        timer.cancel();
        stopwatch.stop();

        _waitForHide = false;
        _protectConfig = widget.config;

        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_protectConfig == null) {
      return Offstage();
    }

    if (!_waitForHide) {
      if (_isAuthenticated && !_isPaused) {
        return Offstage();
      }
    }

/*    if (_protectConfig == null || (!_waitForHide && _isAuthenticated && !_isPaused)) {
      return Offstage();
    }
*/
    return Stack(
      children: [
        Scaffold(
            appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.surface,
              title: Text(FlutterUI.translate("Authenticate")),
              automaticallyImplyLeading: false,
              titleSpacing: 0,
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: _buildSkeleton(context),
                )
            )
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            decoration: BoxDecoration(color: Colors.grey[200]?.withAlpha(10)),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    if (_protectConfig?.skeletonBuilder != null) {
      return _protectConfig!.skeletonBuilder!(context);
    }
    else {
      return Container(color: Theme.of(context).colorScheme.surface);
    }
  }

}
