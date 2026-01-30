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

import '../../../flutter_jvx.dart';
import '../../mask/work_screen/skeleton_screen.dart';


/// true means success, false means cancel, null means error
typedef AuthenticationCallback = void Function(bool? success);

class BiometricAuthentication extends StatefulWidget {

  /// the secured widget
  final Widget child;

  /// the skeleton builder
  final WidgetBuilder? skeletonBuilder;

  /// the re-authentication timeout (default: 30 seconds)
  final Duration reAuthTimeout;

  /// a caching name for init/destroy independent authentication timeout
  final String? name;

  /// whether child handles on pop (child will or won't be added to widget tree)
  final bool childHandlesOnPop;

  /// whether to secure app
  final bool secureApp;

  /// the authentication callback event
  final AuthenticationCallback? onAuthentication;

  const BiometricAuthentication({
    super.key,
    required this.child,
    this.childHandlesOnPop = false,
    this.secureApp = true,
    this.name,
    this.reAuthTimeout = const Duration(seconds: 30),
    this.onAuthentication,
    this.skeletonBuilder
  });

  @override
  State<BiometricAuthentication> createState() => _BiometricAuthenticationState();

  /// Clears biometric authentication cache for [appId] only
  static void clearCache(String? appId) {
    _BiometricAuthenticationState.globalAuthTime.removeWhere((key, value) => key.startsWith("$appId@"));
  }

  /// Clears biometric authentication cache for all applications
  static void clearCacheForAllApps() {
    _BiometricAuthenticationState.globalAuthTime.clear();
  }
}

class _BiometricAuthenticationState extends State<BiometricAuthentication> with WidgetsBindingObserver{
  /// The method channel for platform/native communication
  static const platformChannel = MethodChannel('com.sibvisions.flutter_jvx/security');
  /// Whether to use native channel communication
  static final bool _useChannel = Platform.isIOS || Platform.isAndroid;

  /// the global "last" auth-time cache
  static Map<String, DateTime> globalAuthTime = {};

  final LocalAuthentication auth = LocalAuthentication();

  String? cacheKey;

  /// last successful authentication time
  DateTime? _lastAuthTime;

  /// whether biometric authentication is possible
  bool _isBiometricAuthPossible = false;

  bool _isBack = false;
  bool _isAuthenticating = false;
  bool _isAuthenticated = false;
  bool _isPaused = false;

  bool _didAuthOnResume = true;

  @override
  void initState() {
    super.initState();

    //init last auth-time with global time - if name is set
    if (widget.name != null) {
      //it's a good idea to use the application id as prefix
      cacheKey = "${IConfigService().currentApp.value ?? "<undefined>"}@${widget.name}";

      _lastAuthTime = globalAuthTime[cacheKey];

      _cleanupGlobalAuthTime();

      if (_lastAuthTime != null && _isLastAuthStillValid()) {
        _isAuthenticated = true;
      }
    }

    WidgetsBinding.instance.addObserver(this);

    auth.isDeviceSupported().then((bool isSupported) =>{
      if (isSupported) {
        _initBiometric()
      }
    });

    if (widget.secureApp && _useChannel) {
      platformChannel.invokeMethod('setSecure', true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();

    if (widget.secureApp && _useChannel) {
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
        _isAuthenticated = _isAuthenticating;

        _authenticateWithBiometrics();
      }
    } else if (state == AppLifecycleState.paused) {
      // Triggers re-auth on next resumed event
      _didAuthOnResume = false;
      _isPaused = true;

      //does nothing under iOS because it's too late - but works under Android
      setState(() {});
    }
  }

  /// Cleanup expired auth time records
  Future<void> _cleanupGlobalAuthTime() async {
    DateTime now = DateTime.now();
    globalAuthTime.removeWhere((key, value) => now.difference(value) >= widget.reAuthTimeout);
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

    if (DateTime.now().difference(_lastAuthTime!) >= widget.reAuthTimeout) {
      return false;
    }

    return true;
  }

  Future<void> _authenticateWithBiometrics() async {
    if (_isLastAuthStillValid()) {
      setState(() {_isAuthenticated = true;});

      return;
    }

    if (!_isBiometricAuthPossible || _isAuthenticated || _isAuthenticating || _isBack) {
      return;
    }

    _isAuthenticated = false;
    _isBack = false;
    _lastAuthTime = null;

    if (cacheKey != null) {
      globalAuthTime.remove(cacheKey!);
    }

    bool authenticated = false;

    try {
      setState(() {
        _isAuthenticating = true;
      });

      if (_useChannel) {
        await platformChannel.invokeMethod('setAuthStatus', true);
      }

      authenticated = await auth.authenticate(
        localizedReason: FlutterUI.translate('Scan your fingerprint or face to authenticate'),
        persistAcrossBackgrounding: true,
        //biometricOnly: true,
      );

      if (_useChannel && authenticated) {
        await platformChannel.invokeMethod('hideBlur');
      }

      setState(() {
        _isAuthenticated = authenticated;
        _isAuthenticating = false;
        _lastAuthTime = DateTime.now();

        if (cacheKey != null) {
          globalAuthTime[cacheKey!] = _lastAuthTime!;
        }
      });

      if (widget.onAuthentication != null) {
        widget.onAuthentication!(true);
      }
    } on LocalAuthException catch (e) {
      FlutterUI.log.e("$e");

      if (e.code == LocalAuthExceptionCode.userCanceled
          || e.code == LocalAuthExceptionCode.systemCanceled) {

        setState(() {
          _isAuthenticating = false;
          _isBack = true;
        });

        if (mounted) {
          if (widget.onAuthentication != null) {
            widget.onAuthentication!(false);
          }
          else {
            unawaited(Navigator.maybePop(context));
          }
        }
        else {
          if (widget.onAuthentication != null) {
            widget.onAuthentication!(null);
          }
        }
      }
      else {
        setState(() {_isAuthenticating = false;});

        if (widget.onAuthentication != null) {
          widget.onAuthentication!(null);
        }
      }
      return;
    } on PlatformException catch (e) {
      FlutterUI.log.e("$e");

      setState(() {_isAuthenticating = false;});

      if (widget.onAuthentication != null) {
        widget.onAuthentication!(null);
      }

      return;
    }
    finally {
      if (_useChannel) {
        await platformChannel.invokeMethod('setAuthStatus', false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticated && !_isPaused) {
      return widget.child;
    }

    return Stack(
      children: [
        //add the original child to support onWillPop (e.g. close screen command)
        if (widget.childHandlesOnPop) widget.child,
        Scaffold(
            appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.surface,
              title: Text("Authenticate"),
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
        if (!_isBack)
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
    if (widget.skeletonBuilder != null) {
      return widget.skeletonBuilder!(context);
    }
    else {
      return SkeletonScreen();
    }
  }

}
