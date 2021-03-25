import 'dart:io';

import 'package:flutterclient/src/models/state/app_state.dart';

import '../../../../injection_container.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    String baseUrl = sl<AppState>().serverConfig!.baseUrl;
    String? trimmedBaseUrl;

    try {
      if (baseUrl.isNotEmpty) {
        trimmedBaseUrl = baseUrl.split('/')[2].split(':')[0];
      }

      final result = await InternetAddress.lookup(trimmedBaseUrl!);
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }
}
