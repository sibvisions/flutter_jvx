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

  testWidgets('CoLabelWidget has Text', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: CoLabelWidget(
          componentModel: LabelComponentModel(
              changedComponent: ChangedComponent.fromJson({
        'text': 'Hello Test!',
        'id': 'L123',
        'className': 'Label'
      }))),
    ));

    final textFinder = find.text('Hello Test!');

    expect(textFinder, findsOneWidget);
  });
}
