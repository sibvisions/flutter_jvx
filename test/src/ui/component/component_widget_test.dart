import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterclient/flutterclient.dart';
import 'package:flutterclient/src/models/api/response_objects/response_data/component/changed_component.dart';
import 'package:flutterclient/injection_container.dart' as di;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await di.init();
  });

  testWidgets('ComponentWidget has Container, Center and Text',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ComponentWidget(
          componentModel: ComponentModel(changedComponent: ChangedComponent())),
    ));

    final textFinder = find.text('Please overwrite the build method!');
    final containerFinder = find.byType(Container);
    final centerFinder = find.byType(Center);

    expect(textFinder, findsOneWidget);
    expect(containerFinder, findsOneWidget);
    expect(centerFinder, findsOneWidget);
  });
}
