import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterclient/src/models/api/response_objects/response_data/component/changed_component.dart';
import 'package:flutterclient/injection_container.dart' as di;
import 'package:flutterclient/src/ui/component/co_button_widget.dart';
import 'package:flutterclient/src/ui/component/model/button_component_model.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await di.init();
  });

  testWidgets('CoButtonWidget has Text', (WidgetTester tester) async {
    final componentModel = ButtonComponentModel(
        changedComponent: ChangedComponent.fromJson({
          'text': 'Hello Test!',
          'id': 'B123',
          'className': 'Button',
          'name': 'B235-Sysntwea'
        }),
        onAction: (BuildContext context, String componentId,
            String? classNameEventSourceRef) {});

    componentModel.updateProperties(
        MockBuildContext(), componentModel.changedComponent);

    await tester.pumpWidget(MaterialApp(
        home: CoButtonWidget(
      componentModel: componentModel,
    )));

    await tester.tap(find.byType(ElevatedButton));

    final textFinder = find.text('Hello Test!');

    expect(textFinder, findsOneWidget);
  });
}
