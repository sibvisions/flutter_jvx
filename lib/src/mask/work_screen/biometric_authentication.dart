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
import 'skeleton_screen.dart';

class BiometricAuthentication extends StatefulWidget {

  final Widget? child;

  const BiometricAuthentication({
    super.key,
    this.child
  });

  @override
  State<BiometricAuthentication> createState() => _BiometricAuthenticationState();
}

class _BiometricAuthenticationState extends State<BiometricAuthentication> with WidgetsBindingObserver{
  /// The method channel for platform/native communication
  static const platformChannel = MethodChannel('com.sibvisions.flutter_jvx/security');
  /// Whether to use native channel communication
  static final bool _useChannel = Platform.isIOS || Platform.isAndroid;

  final LocalAuthentication auth = LocalAuthentication();

  DateTime? _lastAuthTime;

  bool _isBiometricAuthPossible = false;

  bool _isBack = false;
  bool _isAuthenticating = false;
  bool _isAuthenticated = false;

  bool _didAuthOnResume = true;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    auth.isDeviceSupported().then((bool isSupported) =>{
      if (isSupported) {
        _initBiometric()
      }
    });

    if (_useChannel) {
      platformChannel.invokeMethod('setSecure', true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();

    if (_useChannel) {
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

    final diff = DateTime.now().difference(_lastAuthTime!).inSeconds;

    if (diff >= 30) {
      return false;
    }

    return true;
  }

  Future<void> _authenticateWithBiometrics() async {
    if (_isLastAuthStillValid()) {
      _isAuthenticated = true;
      return;
    }

    if (!_isBiometricAuthPossible || _isAuthenticated || _isAuthenticating || _isBack) {
      return;
    }

    _isAuthenticated = false;
    _isBack = false;
    _lastAuthTime = null;

    bool authenticated = false;

    try {
      setState(() {
        _isAuthenticating = true;
      });

      if (_useChannel) {
        await platformChannel.invokeMethod('setAuthStatus', true);
      }

      authenticated = await auth.authenticate(
        localizedReason: 'Scan your fingerprint (or face or whatever) to authenticate',
        persistAcrossBackgrounding: true,
       // biometricOnly: true,
      );

      if (_useChannel && authenticated) {
        await platformChannel.invokeMethod('hideBlur');
      }

      setState(() {
        _isAuthenticated = authenticated;
        _isAuthenticating = false;
        _lastAuthTime = DateTime.now();
      });
    } on LocalAuthException catch (e) {
      FlutterUI.log.e("$e");

      if (e.code == LocalAuthExceptionCode.userCanceled
          || e.code == LocalAuthExceptionCode.systemCanceled) {

        setState(() {
          _isAuthenticating = false;
          _isBack = true;
        });

        if (mounted) {
          unawaited(Navigator.maybePop(context));
        }
      }
      else {
        setState(() {_isAuthenticating = false;});
      }
      return;
    } on PlatformException catch (e) {
      FlutterUI.log.e("$e");

      setState(() {_isAuthenticating = false;});
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
      return widget.child!;
    }

    return Stack(
      children: [
        //add the original child to support onWillPop (close screen)
        widget.child!,
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
                  child: SkeletonScreen(),
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

}
