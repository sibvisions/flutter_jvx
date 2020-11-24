import 'package:connectivity/connectivity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jvx_flutterclient/core/utils/network/network_info.dart';
import 'package:mockito/mockito.dart';

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  NetworkInfoImpl networkInfo;
  MockConnectivity mockConnectivity;

  setUp(() {
    mockConnectivity = MockConnectivity();
    networkInfo = NetworkInfoImpl(mockConnectivity);
  });

  group('isConnected', () {
    test('should forward call to Connectivity.checkConnectivity', () async {
      final tHasConnection = true;

      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) => Future.value(ConnectivityResult.mobile));

      final result = await networkInfo.isConnected;

      verify(mockConnectivity.checkConnectivity());
      expect(result, tHasConnection);
    });
  });
}
