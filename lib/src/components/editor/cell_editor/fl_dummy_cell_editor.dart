/* 
 * Copyright 2022 SIB Visions GmbH
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

import '../../../model/component/editor/cell_editor/cell_editor_model.dart';
import '../../../model/component/fl_component_model.dart';
import '../../dummy/fl_dummy_widget.dart';
import 'i_cell_editor.dart';

class FlDummyCellEditor extends ICellEditor<FlDummyModel, FlDummyWidget, ICellEditorModel, dynamic> {
  dynamic _value;

  FlDummyCellEditor()
      : super(
          model: ICellEditorModel(),
          cellEditorJson: {},
          onValueChange: _doNothing,
          onEndEditing: _doNothing,
          onFocusChanged: _doNothing,
        );

  @override
  void dispose() {}

  @override
  createWidget(Map<String, dynamic>? pJson) {
    return FlDummyWidget(model: createWidgetModel());
  }

  @override
  FlDummyModel createWidgetModel() => FlDummyModel();

  @override
  void setValue(pValue) {
    _value = pValue;
  }

  @override
  dynamic getValue() {
    return _value;
  }

  @override
  String formatValue(dynamic pValue) {
    return pValue?.toString() ?? "";
  }

  @override
  double? getEditorWidth(Map<String, dynamic>? pJson) {
    return null;
  }

  static void _doNothing(dynamic ignore) {}
}
