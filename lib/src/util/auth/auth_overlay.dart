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

import 'dart:ui';
import 'dart:async';

import 'package:flutter/material.dart';

import '../../flutter_ui.dart';
import '../../service/ui/protect_config.dart';
import 'auth_service.dart';

class AuthOverlay extends StatefulWidget {

  /// the protection configuration list
  final List<ProtectConfig>? config;

  const AuthOverlay({
    super.key,
    required this.config
  });

  @override
  State<AuthOverlay> createState() => _AuthOverlayState();

  /// Finds the [_AuthOverlayState] from the closest instance of this class that
  /// encloses the given context.
  ///
  /// If no instance of this class encloses the given context, will return null.
  /// To throw an exception instead, use [of] instead of this function.
  static bool isVisible(BuildContext? context) {
    return context?.findAncestorStateOfType<_AuthOverlayState>()?._isVisible ?? false;
  }

}

class _AuthOverlayState extends State<AuthOverlay> with WidgetsBindingObserver {

  /// The authentication service
  AuthService service = AuthService.instance;

  /// The current config (required in case of delayed hide)
  List<ProtectConfig>? _protectConfig;

  /// Hide delay timer
  Timer? _timerHide;

  /// Whether the app is in pause mode
  bool _isPaused = false;

  /// Whether auth on resume was triggered
  bool _handleAuthOnResume = false;

  /// Whether we wait until UI is ready before we hide the overlay
  bool _waitForHide = false;

  /// Whether there was a running secondary animation
  bool _hadSecondaryAnimation = false;

  /// Whether the overlay is currently shown
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();

    _protectConfig = widget.config;

    WidgetsBinding.instance.addObserver(this);

    service.addListener(_authServiceUpdated);
    service.init(_protectConfig);

    service.authenticate(false);
  }

  @override
  void dispose() {
    service.removeListener(_authServiceUpdated);

    WidgetsBinding.instance.removeObserver(this);

    _timerHide?.cancel();

    super.dispose();
  }

  @override
  void didUpdateWidget(AuthOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_isConfigChanged(_protectConfig, widget.config)) {

      bool hideTimerStopped = _timerHide?.isActive != true;

      //if hide timer is active -> hiding overlay is in progress -> don't change config until timer is done
      if (hideTimerStopped) {
        _protectConfig = widget.config;

        service.init(widget.config);
      }

      if (widget.config != null) {
        if (mounted && !service.isAuthenticated()) {
          //if timer is currently active -> wait until everything is done
          //and timer will change variables
          if (hideTimerStopped) {
            service.authenticate(false);
          }
        }
      }
      else if (_protectConfig != null && _protectConfig!.isNotEmpty) {
        _delayedHide();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Don't do auth too often
      if (_handleAuthOnResume) {
        _timerHide?.cancel();

        _waitForHide = false;

        _handleAuthOnResume = false;

        service.resumed();

        _isPaused = false;

        service.authenticate();
      }
      else {
        _isPaused = false;
      }
    } else if (state == AppLifecycleState.paused) {
      // Triggers re-auth on next resumed event
      _handleAuthOnResume = true;
      _isPaused = true;

      //immediate if possible
      setState(() {});

      //will send setState but with next frame
      service.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_protectConfig == null || _protectConfig!.isEmpty) {
      _isVisible = false;

      return Offstage();
    }

    if (!_waitForHide) {
      if (!_isPaused && service.isAuthenticated()) {
        _isVisible = false;

        return Offstage();
      }
    }

    _isVisible = true;

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
                  child: service.buildSkeleton(context),
                )
            )
        ),

        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            decoration: BoxDecoration(color: Colors.grey[200]?.withAlpha(10)),
          ),
        ),

        if (!service.isAuthSupported())
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 10,
                  offset: const Offset(0, 4), // Schatten nach unten verschoben
                ),
              ],
              border: Border.all(color: Colors.red.shade100, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.lock_person_rounded, color: Colors.red.shade400, size: 32),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'This application requires the use of biometrics or a PIN to proceed.',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          )
      ],
    );

  }

  void _authServiceUpdated() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) {
        if (service.isCanceled()) {
          _delayedHide();
        }
        else {
          setState(() {});
        }
      }
    });
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
    _timerHide = Timer.periodic(const Duration(milliseconds: 20), (timer) {
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

        service.init(widget.config);

        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  /// Gets whether the given configuration lists are different
  bool _isConfigChanged(List<ProtectConfig>? oldConfig, List<ProtectConfig>? newConfig) {
    if (oldConfig == null || newConfig == null) {
      return oldConfig != newConfig;
    }
    if (oldConfig.length != newConfig.length) {
      return true;
    }

    for (int i = 0; i < oldConfig.length; i++) {
      if (oldConfig[i] != newConfig[i]) {
        return true;
      }
    }

    return false;
  }

}
