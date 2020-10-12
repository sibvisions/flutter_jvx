import 'dart:collection';

import '../../jvx_flutterclient.dart';
import '../../model/changed_component.dart';
import '../../model/properties/component_properties.dart';
import '../component/component_model.dart';
import 'co_editor_widget.dart';

class EditorComponentModel extends ComponentModel {
  Queue<SoComponentData> _toUpdateData = Queue<SoComponentData>();

  String dataProvider;
  String dataRow;
  String columnName;

  Queue<SoComponentData> get toUpdateData => _toUpdateData;
  set toUpdateData(Queue<SoComponentData> toUpdateData) =>
      _toUpdateData = toUpdateData;

  EditorComponentModel(ChangedComponent changedComponent)
      : super(changedComponent) {
    if (dataProvider == null)
      dataProvider = changedComponent.getProperty<String>(
          ComponentProperty.DATA_BOOK, dataProvider);

    dataRow = changedComponent.getProperty<String>(ComponentProperty.DATA_ROW);

    if (dataProvider == null) dataProvider = dataRow;
  }
}
