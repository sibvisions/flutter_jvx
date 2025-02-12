import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';

import 'export_json_page.dart';

void main() {
    testWidgets("Example json creation", (WidgetTester tester) async {
        ExportJsonPage widget = const ExportJsonPage(0);

        await tester.pumpWidget(MaterialApp(home: widget));

        Finder f = find.byType(IconButton);
        f.tryEvaluate();

        await tester.tap(f);
    });
}