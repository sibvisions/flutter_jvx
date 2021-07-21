import 'package:flutter_test/flutter_test.dart';
import 'package:flutterclient/flutterclient.dart';

import '../../../fixtures/fixture_reader.dart';

void main() {
  late QRCodeFormatter formatter;

  setUp(() {
    formatter = QRCodeFormatter();
  });

  final Map<String, dynamic> tProperties = <String, dynamic>{
    'URL': 'http://192.168.0.80:8080/JVx.mobile/services/mobile',
    'APPNAME': 'demo',
    'USER': 'test',
    'PWD': 'test'
  };

  group('should return formatted properties map from', () {
    test('valid json', () async {
      final result =
          formatter.formatQRCode(fixture('qr_code_json_format.json'));

      expect(result, tProperties);
    });

    test('valid properties string with "="', () async {
      final qrString = fixture('qr_code_string_with_equals_format.txt');

      final result = formatter.formatQRCode(qrString);

      expect(result, tProperties);
    });

    test('valid properties string with ":"', () async {
      final qrString = fixture('qr_code_string_with_colon_format.txt');

      final result = formatter.formatQRCode(qrString);

      expect(result, tProperties);
    });

    test('valid properties string with only two properties given', () async {
      final tResult = <String, dynamic>{
        'APPNAME': 'meycabinprogress',
        'URL':
            'https://devmeyvisionxapp.meyershipbuilding.com/Meycabinprogress/services/mobile'
      };

      final qrString = fixture('qr_code_string_meyer.txt');

      final result = formatter.formatQRCode(qrString);

      expect(result, tResult);
    });
  });
}
