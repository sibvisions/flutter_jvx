import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jvx_flutterclient/application_widget.dart';
import 'package:jvx_flutterclient/core/ui/widgets/util/app_state_provider.dart';
import 'package:jvx_flutterclient/core/ui/widgets/util/restart_widget.dart';
import 'package:jvx_flutterclient/core/ui/widgets/util/shared_pref_provider.dart';
import 'package:jvx_flutterclient/injection_container.dart' as di;
import 'package:jvx_flutterclient/mobile_app.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await di.init();

  group('creation of initial widgets', () {
    testWidgets('ApplicationWidget creation', (WidgetTester tester) async {
      await tester.pumpWidget(new ApplicationWidget());

      expect(find.byType(MobileApp), findsOneWidget);
      expect(find.byType(RestartWidget), findsOneWidget);
      expect(find.byType(AppStateProvider), findsOneWidget);
      expect(find.byType(SharedPrefProvider), findsOneWidget);
    });

    testWidgets('MobileApp creation', (WidgetTester tester) async {
      await tester.pumpWidget(new MobileApp(
        supportedLocales: [Locale('en'), Locale('de')],
        themeData: ThemeData(),
        shouldLoadConfig: false,
      ));

      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}

Widget makeTestableWidget({Widget child}) {
  return MaterialApp(
    home: child,
  );
}
