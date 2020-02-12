import 'package:flutter_test/flutter_test.dart';
import '../lib/utils/globals.dart' as globals;

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
