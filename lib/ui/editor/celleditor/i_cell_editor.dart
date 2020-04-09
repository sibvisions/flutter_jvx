import 'package:flutter/material.dart';
import '../../../model/cell_editor.dart';
import '../../../model/popup_size.dart';

abstract class ICellEditor {
  BuildContext context;
  bool isTableView;
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

  Size preferredSize;
  Size minimumSize;
  Size maximumSize;

  bool get isPreferredSizeSet;
  bool get isMinimumSizeSet;
  bool get isMaximumSizeSet;

  ICellEditor(CellEditor cellEditor, this.context);

  Widget getWidget({bool editable, Color background, Color foreground, String placeholder, String font, int horizontalAlignment});
}