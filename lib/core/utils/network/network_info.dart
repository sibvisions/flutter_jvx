import 'dart:io';

import 'package:jvx_flutterclient/core/models/app/app_state.dart';
import 'package:jvx_flutterclient/injection_container.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final String connectionChecker;

  NetworkInfoImpl(this.connectionChecker);

  @override
  Future<bool> get isConnected async {
    String baseUrl = sl<AppState>().baseUrl;
    String trimmedBaseUrl;

    try {
      if (baseUrl != null && baseUrl.isNotEmpty) {
        trimmedBaseUrl = baseUrl.split('/')[2].split(':')[0];
      }

      final result = await InternetAddress.lookup(
          trimmedBaseUrl ?? this.connectionChecker);
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('YOU HAVE CONNECTION TO THE SERVER');
        return true;
      }
    } on SocketException catch (_) {
      print('YOU HAVE NO CONNECTION TO THE SERVER');
      return false;
    }
    print('YOU HAVE NO CONNECTION TO THE SERVER');
    return false;
  }
}
