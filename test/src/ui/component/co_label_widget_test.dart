import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterclient/flutterclient.dart';
import 'package:flutterclient/src/models/api/response_objects/response_data/component/changed_component.dart';
import 'package:flutterclient/injection_container.dart' as di;
import 'package:shared_preferences/shared_preferences.dart';

import 'co_button_widget_test.dart';

void main() {
  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await di.init();
  });

  testWidgets('CoLabelWidget has Text', (WidgetTester tester) async {
    LabelComponentModel componentModel =
        LabelComponentModel(changedComponent: ChangedComponent());

    componentModel.updateProperties(
        MockBuildContext(),
        ChangedComponent.fromJson(
            {'text': 'Hello Test!', 'id': 'L123', 'className': 'Label'},
            DateTime.now()));

    await tester.pumpWidget(MaterialApp(
      home: CoLabelWidget(componentModel: componentModel),
    ));

    final textFinder = find.text('Hello Test!');

    expect(textFinder, findsOneWidget);
  });
}
