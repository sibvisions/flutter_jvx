/*
 * Copyright 2022 SIB Visions GmbH
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

import '../flutter_ui.dart';
import '../model/command/api/alive_command.dart';
import '../model/command/api/device_status_command.dart';
import '../service/command/i_command_service.dart';
import '../service/config/i_config_service.dart';
import '../service/service.dart';
import '../service/ui/i_ui_service.dart';
import '../util/widgets/status_banner.dart';
import 'apps/app_overview_page.dart';
import 'state/app_style.dart';
import 'state/loading_bar.dart';

class JVxOverlay extends StatefulWidget {
  final Widget? child;

  const JVxOverlay({
    super.key,
    required this.child,
  });

  /// Finds the [JVxOverlayState] from the closest instance of this class that
  /// encloses the given context.
  static JVxOverlayState of(BuildContext context) {
    final JVxOverlayState? result = maybeOf(context);
    if (result != null) {
      return result;
    }
    throw FlutterError.fromParts([
      ErrorSummary(
        "JVxOverlay.of() called with a context that does not contain a JVxOverlay.",
      ),
      context.describeElement("The context used was"),
    ]);
  }

  /// Finds the [JVxOverlayState] from the closest instance of this class that
  /// encloses the given context.
  ///
  /// If no instance of this class encloses the given context, will return null.
  /// To throw an exception instead, use [of] instead of this function.
  static JVxOverlayState? maybeOf(BuildContext? context) {
    return context?.findAncestorStateOfType<JVxOverlayState>();
  }

  @override
  State<JVxOverlay> createState() => JVxOverlayState();
}

class JVxOverlayState extends State<JVxOverlay> {
  final GlobalKey<StatusBannerState> _statusBannerKey = GlobalKey();
  final GlobalKey<DialogsWidgetState> _dialogsKey = GlobalKey();

  /// Report device status to server
  final BehaviorSubject<Size> _subject = BehaviorSubject();
  late final StreamSubscription<Size> subscription;

  late final RootBackButtonDispatcher backButtonDispatcher;

  bool _loading = false;
  Future? _loadingDelayFuture;

  bool _lockDelayed = false;
  bool _forceDisableBarrier = false;

  bool? _connected;
  Timer? _connectedTimer;
  String? _connectedMessage;

  void refreshDialogs() {
    _dialogsKey.currentState?.setState(() {});
  }

  bool get forceDisableBarrier => _forceDisableBarrier;

  /// Overrides the modal barrier.
  ///
  /// Do not forget to re-enable it again!
  void overrideModalBarrier(bool forceDisableBarrier) {
    setState(() {
      _forceDisableBarrier = forceDisableBarrier;
    });
  }

  bool _showInternalUrl = false;

  bool get showInternalUrl => _showInternalUrl;

  /// Displays the internal app url on top of the screen.
  set showInternalUrl(bool value) => setState(() => _showInternalUrl = value);

  bool get loading => _loading;

  /// Shows the [LoadingBar] after a specified [delay], and continues to show it until [hideLoading] is called.
  void showLoading(Duration delay, [bool lockDelayed = false]) {
    if (!_loading) {
      _loadingDelayFuture = Future.delayed(delay);
      _loading = true;
      _lockDelayed = lockDelayed;

      if (SchedulerBinding.instance.schedulerPhase != SchedulerPhase.idle) {
        SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {}));
        return;
      }

      setState(() {});
    }
  }

  /// Cancels or stops the [LoadingBar] triggered by [showLoading].
  void hideLoading() {
    if (_loading) {
      _loading = false;
      _lockDelayed = false;
      setState(() {});
    }
  }

  void setConnectionState(bool connected) {
    if (_connected == connected) return;

    _connected = connected;
    if (_connected!) {
      setState(() {
        _connectedMessage = "Server Connection restored";
      });
      _connectedTimer?.cancel();
      _connectedTimer = Timer(
        const Duration(seconds: 2),
        () {
          if (!mounted) return;
          _hideStatusBanner();
        },
      );
    } else if (!_connected!) {
      _connectedTimer?.cancel();
      setState(() {
        _connectedMessage = "Server Connection lost, retrying...";
      });
    } else {
      _connectedTimer?.cancel();
      _hideStatusBanner();
    }
  }

  void resetConnectionState({bool instant = false}) {
    _connectedTimer?.cancel();
    _connected = null;
    if (instant) {
      _removeStatusBanner();
    } else {
      _hideStatusBanner();
    }
  }

  void _hideStatusBanner() {
    _statusBannerKey.currentState?.close();
  }

  void _removeStatusBanner() {
    setState(() => _connectedMessage = null);
  }

  bool get _isLocked => _loading && !_forceDisableBarrier;

  bool get _showConnectedBarrier => !loading && _connected == false && !_forceDisableBarrier;

  bool get _showExit => _showConnectedBarrier && _connectedMessage != null;

  FutureOr<void> clear(ClearReason reason) {
    _forceDisableBarrier = false;
    _loading = false;
    _lockDelayed = false;
    resetConnectionState(instant: true);
  }

  @override
  void initState() {
    super.initState();
    backButtonDispatcher = RootBackButtonDispatcher();
    backButtonDispatcher.addCallback(_onBackPress);

    subscription = _subject.throttleTime(const Duration(milliseconds: 8), trailing: true).listen((size) {
      if (IUiService().clientId.value != null && !IConfigService().offline.value) {
        ICommandService()
            .sendCommand(DeviceStatusCommand(
              screenWidth: size.width.toInt(),
              screenHeight: size.height.toInt(),
              reason: "Device Size changed",
            ))
            .catchError((e, stack) => FlutterUI.logAPI.d("Failed to send device status", error: e, stackTrace: stack));
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (IUiService().clientId.value != null && !IConfigService().offline.value) {
      ICommandService()
          .sendCommand(DeviceStatusCommand(
            darkMode: Theme.of(context).brightness == Brightness.dark,
            reason: "Platform Brightness changed",
          ))
          .catchError((e, stack) => FlutterUI.logAPI.w("Failed to send device status", error: e, stackTrace: stack));
    }
  }

  /// Returns true if this callback will handle the request;
  /// otherwise, returns false.
  Future<bool> _onBackPress() async {
    if ((_isLocked || _showConnectedBarrier) && !_showExit) {
      // Block request.
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    _subject.add(MediaQuery.sizeOf(context));

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      },
      child: AppStyle(
        applicationStyle: IConfigService().applicationStyle.value,
        applicationSettings: IUiService().applicationSettings.value,
        child: FutureBuilder(
          future: _loadingDelayFuture,
          builder: (context, snapshot) {
            return LoadingBar(
              show: _loading && snapshot.connectionState == ConnectionState.done,
              child: Stack(
                children: [
                  if (widget.child != null) widget.child!,
                  DialogsWidget(key: _dialogsKey),
                  if (_isLocked && (!_lockDelayed || snapshot.connectionState == ConnectionState.done))
                    const ModalBarrier(
                      dismissible: false,
                    ),
                  if (_showConnectedBarrier)
                    const ModalBarrier(
                      dismissible: false,
                      color: Colors.black26,
                    ),
                  if (_showExit)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 25,
                      child: Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Opacity(
                            opacity: 0.9,
                            child: Material(
                              type: MaterialType.button,
                              elevation: 20.0,
                              borderRadius: BorderRadius.circular(16),
                              color: Theme.of(context).colorScheme.surface,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () async {
                                  await IUiService().routeToAppOverview();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 14.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: 4.0),
                                        child: Icon(
                                          AppOverviewPage.appsIcon,
                                          size: 24,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          FlutterUI.translate("Exit App"),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.onSurface,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (_connectedMessage != null)
                    StatusBanner(
                      key: _statusBannerKey,
                      edgePadding: 8,
                      useMaxWidth: true,
                      backgroundColor: _connected == true
                          ? const Color(0xFF1A964A)
                          : Theme.of(context).snackBarTheme.backgroundColor,
                      color: _connected == true
                          ? (Theme.of(context).colorScheme.brightness == Brightness.light
                              ? const Color(0xFF141414)
                              : Colors.white)
                          : null,
                      onClose: () => _removeStatusBanner(),
                      onTap: _connected == false
                          ? () {
                              ICommandService()
                                  .sendCommand(AliveCommand(reason: "User requested retry", retryRequest: false))
                                  .catchError((_) {});
                            }
                          : null,
                      dismissible: _connected != false,
                      child: Text(
                        FlutterUI.translate(_connectedMessage),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  if (showInternalUrl)
                    Positioned(
                      top: kToolbarHeight - 16,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: Align(
                            alignment: Alignment.center,
                            child: Opacity(
                              opacity: 0.8,
                              child: Material(
                                clipBehavior: Clip.hardEdge,
                                borderRadius: BorderRadius.circular(20),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListenableBuilder(
                                    listenable: routerDelegate,
                                    builder: (context, child) {
                                      return Text(
                                        routerDelegate.configuration.location.toString(),
                                        textAlign: TextAlign.center,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    subscription.cancel();
    backButtonDispatcher.removeCallback(_onBackPress);
    super.dispose();
  }
}

class DialogsWidget extends StatefulWidget {
  const DialogsWidget({super.key});

  @override
  State<DialogsWidget> createState() => DialogsWidgetState();
}

class DialogsWidgetState extends State<DialogsWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: _getDialogs());
  }

  List<Widget> _getDialogs() {
    return IUiService()
        .getJVxDialogs()
        .map(
          (e) => Stack(
            children: [
              Opacity(
                opacity: 0.7,
                child: ModalBarrier(
                  dismissible: e.dismissible,
                  color: Colors.black54,
                  onDismiss: () {
                    e.onClose();
                    IUiService().closeJVxDialog(e);
                    setState(() {});
                  },
                ),
              ),
              e,
            ],
          ),
        )
        .toList();
  }
}
