import 'package:jvx_mobile_v3/model/column_view.dart';
import 'package:jvx_mobile_v3/model/popup_size.dart';

class CellEditor {
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
  String className;
  bool tableReadonly;
  bool directCellEditor;
  bool autoOpenPopup;
}