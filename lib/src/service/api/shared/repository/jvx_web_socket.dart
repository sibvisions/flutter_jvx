import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:universal_io/io.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../flutter_ui.dart';
import '../../../../util/external/retry.dart';
import '../../../../util/import_handler/import_handler.dart';
import '../../../config/config_controller.dart';
import '../../../ui/i_ui_service.dart';

/// Uses [WebSocketChannel] to create a web socket for sending and receiving.
///
/// Supports reconnects.
class JVxWebSocket {
  Duration? _pingInterval;

  Duration? get pingInterval => _pingInterval;

  set pingInterval(Duration? interval) {
    _pingInterval = interval;
    resetPingInterval();
  }

  JVxWebSocket({
    required this.uriSupplier,
    required this.onData,
    this.title,
    this.headersSupplier,
    this.onConnectedChange,
    Duration? pingInterval,
  }) : _pingInterval = pingInterval;

  /// Name of this WebSocket handler instance (used for logging).
  final String? title;

  /// Supplier for on-demand url creation.
  final Uri? Function() uriSupplier;

  /// onData callback from Web Socket.
  final void Function(dynamic data) onData;

  /// Header supplier for dynamic connection creation.
  final Map<String, dynamic> Function()? headersSupplier;

  /// Custom callback for connection states (e.g. global connection state)
  ///
  /// This purposely doesn't use a [ValueNotifier] as we sometimes want to send the same value again.
  final void Function(bool connected)? onConnectedChange;

  /// If we know that the current server has an web socket available.
  final ValueNotifier<bool> _availability = ValueNotifier(false);

  /// Describes the current status of the currently active websocket.
  ///
  /// Yes there can be multiple, because we can't close them reliably...
  final ValueNotifier<bool> _connectedState = ValueNotifier(false);

  /// Describes the current status of the currently active websocket.
  ValueListenable<bool> get connected => _connectedState;

  /// True if the current server has an web socket available.
  ValueListenable<bool> get available => _availability;

  /// Web Socket for incoming connection
  WebSocketChannel? _webSocket;

  StreamSubscription? _subscription;

  /// Current retry delay, gets doubled after ever failed attempt until 60.
  int _retryDelay = 2;

  /// Controls if we should try to reconnect after the socket closes.
  bool _manualClose = false;

  Timer? _pingTimer;
  Timer? _reconnectTimer;

  String get _logPrefix => "${title ?? "JVxWebSocket"}#$hashCode: ";

  Future<void> startWebSocket() async {
    await stopWebSocket();
    return _openWebSocket();
  }

  Future<void> stopWebSocket() async {
    _retryDelay = 2;

    if (_reconnectTimer != null) {
      _reconnectTimer?.cancel();
      _reconnectTimer = null;
      FlutterUI.logAPI.i("${_logPrefix}Canceled WebSocket reconnect");
    }

    await _closeWebSocket();
  }

  FutureOr<void> dispose() async {
    await stopWebSocket();
    _connectedState.dispose();
    _availability.dispose();
  }

  void send(dynamic data) {
    _webSocket?.sink.add(data);
  }

  Future<void> _openWebSocket({int retryAttempts = 3}) async {
    await _closeWebSocket();

    Uri? uri = uriSupplier.call();
    if (uri == null) {
      FlutterUI.logAPI.d("${_logPrefix}WebSocket connect canceled: missing URI");
      return;
    }

    await retry(
      maxAttempts: retryAttempts,
      onRetry: (e) => FlutterUI.logAPI.w("${_logPrefix}Retrying initial WebSocket connection", e),
      () => _connect(uri),
    );
  }

  Future<void> _connect(Uri uri) async {
    FlutterUI.logAPI.i("${_logPrefix}Connecting to $uri");

    var webSocket = createWebSocket(
      uri,
      headersSupplier?.call(),
    );

    await webSocket.ready.then((value) {
      _availability.value = true;
      if (!_connectedState.value) {
        // onReady
        FlutterUI.logAPI.i("${_logPrefix}Connected to WebSocket#${webSocket.hashCode}");

        _connectedState.value = true;
        _retryDelay = 2;
        _manualClose = false;
      }

      onConnectedChange?.call(true);

      resetPingInterval();
    });

    _webSocket = webSocket;
    _subscription = webSocket.stream.listen(
      (data) {
        // Re-set to possibly override a single failing http request.
        onConnectedChange?.call(true);

        if (data.isNotEmpty) {
          try {
            FlutterUI.logAPI.d("${_logPrefix}Received data via WebSocket#${webSocket.hashCode}: $data");
            if (data == "OK") {
              FlutterUI.logAPI.d("${_logPrefix}Received pong (OK)");
              resetPingInterval();
            }
            onData.call(data);
          } catch (e, stack) {
            FlutterUI.logAPI.e("${_logPrefix}Error handling websocket message:", e, stack);
          }
        }
      },
      onError: (error) {
        // As there is no cancel of a currently connecting websocket (yet),
        // this is only triggered when the connection websocket fails to initially connect.
        FlutterUI.logAPI.w("${_logPrefix}Connection to WebSocket#${webSocket.hashCode} failed", error);

        _handleError(error);
      },
      onDone: () {
        FlutterUI.logAPI.w(
          "${_logPrefix}Connection to WebSocket#${webSocket.hashCode} closed ${_manualClose ? "manually " : ""}"
          "(${webSocket.closeCode ?? "No CloseCode"})"
          "${webSocket.closeReason?.isNotEmpty ?? false ? ": ${webSocket.closeReason}" : ""}",
        );

        _connectedState.value = false;
        resetPingInterval();
        _retryDelay = 2;

        if (webSocket.closeCode != status.policyViolation) {
          // Invalid session shouldn't trigger a offline warning.
          //
          // The following scenario can happen:
          // Connection gets interrupted (trying reconnect)
          // Server restarts in the meantime (Session gets invalid)
          // Connections gets restored but clientId is invalid
          // Connection is ready but Web Socket gets closed because of invalid session
          onConnectedChange?.call(false);
        }

        // Don't retry if server goes down because the clientId will be invalid anyway, which triggers a restart on its own.
        // Don't retry if we closed the socket (indicated either trough manualClose or status.normalClosure)
        if (!_manualClose &&
            ![status.normalClosure, status.goingAway, status.policyViolation].contains(webSocket.closeCode)) {
          reconnectWebSocket();
        }

        _manualClose = false;
      },
      cancelOnError: true,
    );
  }

  void _handleError(error) {
    _connectedState.value = false;
    onConnectedChange?.call(false);
    resetPingInterval();

    if (error is WebSocketChannelException &&
        error.inner is WebSocketChannelException &&
        (error.inner as WebSocketChannelException).inner is WebSocketException) {
      // Server probably doesn't support web sockets.
      _availability.value = false;
      FlutterUI.logAPI.i("${_logPrefix}Connection to WebSocket#${_webSocket.hashCode} was determined as unavailable");
    } else {
      reconnectWebSocket();
    }
  }

  /// Resets the ping timer and restarts if the requirements are fulfilled.
  ///
  /// A ping message is sent every [pingInterval], starting at the first
  /// [pingInterval] after a new value has been assigned or a pong message has
  /// been received. If a ping message is not answered by a pong message from the
  /// peer, the `WebSocket` is assumed disconnected and the connection is closed
  /// with a [WebSocketStatus.goingAway] close code. When a ping signal is sent,
  /// the pong message must be received within [pingInterval].
  ///
  /// Requirement:
  /// * HttpClient works ([client] != `null`).
  /// * Connection works ([connected] == `true`).
  /// * Session is valid ([IUiService.clientId] != `null`).
  /// * App is in foreground ([AppLifecycleState] == [AppLifecycleState.resumed]).
  ///
  /// This method is called during the following changes:
  /// * Connection State
  /// * [AppLifecycleState]
  /// * When web socket stops
  void resetPingInterval() {
    _pingTimer?.cancel();
    FlutterUI.logAPI.d("${_logPrefix}Ping Interval reset");

    if (pingInterval == null || pingInterval == Duration.zero || pingInterval!.isNegative) return;
    // No connection.
    if (!_connectedState.value) return;
    // Are we offline?
    if (ConfigController().offline.value) return;
    // Not in foreground.
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) return;

    _pingTimer = Timer(pingInterval!, () async {
      // No connection.
      if (!_connectedState.value) return;

      try {
        _webSocket!.sink.add("PING");
        FlutterUI.logAPI.d("${_logPrefix}Ping sent");

        if (pingInterval == null || pingInterval == Duration.zero) return;
        _pingTimer = Timer(pingInterval!, () {
          FlutterUI.logAPI.w("${_logPrefix}No pong received in ${pingInterval!.inSeconds}s.");
          // No pong received.
          _closeWebSocket(WebSocketStatus.goingAway);
          onConnectedChange?.call(false);
          reconnectWebSocket();
        });
      } on IOException catch (e, stack) {
        FlutterUI.logAPI.w("${_logPrefix}Ping failed", e, stack);
      }
    });
    FlutterUI.logAPI.d("${_logPrefix}Ping Interval started");
  }

  void reconnectWebSocket() {
    _retryDelay = min(_retryDelay << 1, 60);
    FlutterUI.logAPI.i("${_logPrefix}Retrying WebSocket connection in $_retryDelay seconds...");
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: _retryDelay), () async {
      try {
        FlutterUI.logAPI.i("${_logPrefix}Retrying WebSocket connection");
        await _openWebSocket(retryAttempts: 0);
      } catch (e, stack) {
        FlutterUI.logAPI.w("${_logPrefix}WebSocket Retry failed", e, stack);
        _handleError(e);
      }
    });
  }

  Future<void> _closeWebSocket([int? closeCode]) async {
    // Only needed for `onError`
    if (_webSocket != null && _connectedState.value && closeCode == null) {
      _manualClose = true;
    }

    // Workaround for never finishing future in some cases
    // https://github.com/dart-lang/web_socket_channel/issues/231
    try {
      await _webSocket?.sink
          .close(closeCode ?? WebSocketStatus.normalClosure, "Client stopped")
          .timeout(const Duration(seconds: 2));
      if (_webSocket != null) {
        FlutterUI.logAPI.i("${_logPrefix}Connection to WebSocket successfully closed");
      }
    } on TimeoutException catch (_) {
      // FlutterUI.logAPI.w("${_logPrefix}Closing WebSocket timed out, continuing", e, stack);
    } finally {
      _connectedState.value = false;
    }
    _webSocket = null;

    // Cancel subscription to ignore possible future events from already disposed web sockets.
    // This is important as we currently can't close web sockets reliably, therefore
    // we could receive a totally unrelated close/error event from an older socket that
    // finally timed out or died any other way.
    try {
      await _subscription?.cancel();
    } catch (_) {}
    _subscription = null;

    resetPingInterval();
  }
}
