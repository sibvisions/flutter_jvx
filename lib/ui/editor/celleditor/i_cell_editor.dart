import 'package:flutter/material.dart';
import '../../../model/cell_editor.dart';
import '../../../model/popup_size.dart';

abstract class ICellEditor {
  BuildContext context;
  bool isTableView;
  Size tableMinimumSize;
  int horizontalAlignment;
  int verticalAlignment;
  int preferredEditorMode;
  String additionalCondition;
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
  String dataProvider;
  dynamic value;
  String columnName;
  bool editable;

  Size preferredSize;
  Size minimumSize;
  Size maximumSize;

  bool get isPreferredSizeSet;
  bool get isMinimumSizeSet;
  bool get isMaximumSizeSet;
  
  bool get isTableMinimumSizeSet;

  ICellEditor(CellEditor cellEditor, this.context);

  Widget getWidget({bool editable, Color background, Color foreground, String placeholder, String font, int horizontalAlignment});
}