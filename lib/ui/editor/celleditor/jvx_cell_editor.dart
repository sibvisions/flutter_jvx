import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/column_view.dart';
import 'package:jvx_mobile_v3/model/component_properties.dart';
import 'package:jvx_mobile_v3/model/data/data/jvx_data.dart';
import 'package:jvx_mobile_v3/model/link_reference.dart';
import 'package:jvx_mobile_v3/model/popup_size.dart';

import 'i_cell_editor.dart';

class JVxCellEditor implements ICellEditor {
  Key key = GlobalKey<FormState>();
  BuildContext context;
  int horizontalAlignment;
  int verticalAlignment;
  int preferredEditorMode;
  String additionalCondition;
  ColumnView columnView;
  bool displayReferencedColumnName;
  bool displayConcatMask;
  PopupSize popupSize;
  bool searchColumnMapping;
  bool searchTextAnywhere;
  bool sortByColumnName;
  bool tableHeaderVisible;
  bool validationEnabled;
  bool doNotClearColumnNames;
  bool tableReadonly;
  bool directCellEditor;
  bool autoOpenPopup;
  String contentType;
  LinkReference linkReference;
  String dataProvider;
  dynamic value;
  String columnName;

  JVxCellEditor(ComponentProperties properties, this.context) {
    horizontalAlignment = properties.getProperty<int>("horizontalAlignment");
    verticalAlignment = properties.getProperty<int>("verticalAlignment");
    preferredEditorMode = properties.getProperty<int>("preferredEditorMode");
    contentType = properties.getProperty<String>("contentType");
    directCellEditor = properties.getProperty<bool>("directCellEditor", false);
    columnName = properties.getProperty<String>("columnName", columnName);
  }

  void setInitialData(JVxData data) {

  }

  void setData(JVxData data) {
    
  }


  @override
  Widget getWidget() {
    // ToDo: Implement getWidget
    return null;
  }
}