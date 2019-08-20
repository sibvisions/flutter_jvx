import 'package:flutter_test/flutter_test.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

void main() {
  group('globals', () {
    test('appName is demo', () {
      expect(globals.appName, 'demo');
    });

    test('language is de', () {
      expect(globals.language, 'de');
    });
  });
}
