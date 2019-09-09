import 'package:jvx_mobile_v3/model/column_view.dart';
import 'package:jvx_mobile_v3/model/link_reference.dart';
import 'package:jvx_mobile_v3/model/popup_size.dart';

class CellEditor {
  int horizontalAlignment;
  int verticalAlignment;
  int preferredEditorMode;
  String additionalCondition;
  ColumnView columnView;
  bool displayReferencedColumnName;
  bool displayConcatMask;
  LinkReference linkReference;
  PopupSize popupSize;
  bool searchColumnMapping;
  bool searchTextAnywhere;
  bool searchInAllTableColumns;
  bool sortByColumnName;
  bool tableHeaderVisible;
  bool validationEnabled;
  bool doNotClearColumnNames;
  String className;
  bool tableReadonly;
  bool directCellEditor;
  bool autoOpenPopup;

  CellEditor();

  CellEditor.fromJson(Map<String, dynamic> json) {
    horizontalAlignment = json['horizontalAlignment'];
    verticalAlignment = json['verticalAlignment'];
    preferredEditorMode = json['preferredEditorMode'];
    additionalCondition = json['additionalCondition'];
    if (json['columnView'] != null) columnView = ColumnView.fromJson(json['columnView']);
    displayReferencedColumnName = json['displayReferencedColumnName'];
    displayConcatMask = json['displayConcatMask'];
    if (json['linkReference'] != null) linkReference = LinkReference.fromJson(json['linkReference']);
    if (json['popupSize'] != null) popupSize = PopupSize.fromJson(json['popupSize']);
    searchColumnMapping = json['searchColumnMapping'];
    searchTextAnywhere = json['searchTextAnywhere'];
    sortByColumnName = json['sortByColumnName'];
    tableHeaderVisible = json['tableHeaderVisible'];
    validationEnabled = json['validationEnabled'];
    doNotClearColumnNames = json['doNotClearColumnNames'];
    className = json['className'];
    tableReadonly = json['tableReadonly'];
    directCellEditor = json['directCellEditor'];
    autoOpenPopup = json['autoOpenPopup'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'horizontalAlignment': horizontalAlignment,
    'verticalAlignment': verticalAlignment,
    'preferredEditorMode': preferredEditorMode,
    'additionalCondition': additionalCondition,
    'columnView': columnView.toJson(),
    'displayReferencedColumnName': displayReferencedColumnName,
    'displayConcatMask': displayConcatMask,
    'linkReference': linkReference.toJson(),
    'popupSize': popupSize.toJson(),
    'searchColumnMapping': searchColumnMapping,
    'searchTextAnywhere': searchTextAnywhere,
    'searchInAllTableColumns': searchInAllTableColumns,
    'sortByColumnName': sortByColumnName,
    'tableHeaderVisible': tableHeaderVisible,
    'validationEnabled': validationEnabled,
    'doNotClearColumnNames': doNotClearColumnNames,
    'className': className,
    'tableReadonly': tableReadonly,
    'directCellEditor': directCellEditor,
    'autoOpenPopup': autoOpenPopup
  };
}