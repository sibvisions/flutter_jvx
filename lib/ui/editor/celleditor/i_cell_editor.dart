import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/model/column_view.dart';
import 'package:jvx_mobile_v3/model/component_properties.dart';
import 'package:jvx_mobile_v3/model/data/data/jvx_data.dart';
import 'package:jvx_mobile_v3/model/popup_size.dart';

abstract class ICellEditor {
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

  ICellEditor(ComponentProperties properties, this.context);

  void setData(JVxData data);

  Widget getWidget();
}