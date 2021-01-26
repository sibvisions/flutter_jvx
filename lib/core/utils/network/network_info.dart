import 'dart:io';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final String connectionChecker;

  NetworkInfoImpl(this.connectionChecker);

  @override
  Future<bool> get isConnected async {
    try {
      final result = await InternetAddress.lookup(this.connectionChecker);
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;

    // ConnectivityResult result =
    //     await this.connectionChecker.checkConnectivity();

    // if (result != ConnectivityResult.none) {
    //   return true;
    // }
    // return false;
  }
}
