/*
 * Copyright 2025 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

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