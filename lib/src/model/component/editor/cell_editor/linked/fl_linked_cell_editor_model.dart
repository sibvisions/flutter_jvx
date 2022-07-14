import '../../../../api/api_object_property.dart';
import '../cell_editor_model.dart';
import 'column_view.dart';
import 'link_reference.dart';

class FlLinkedCellEditorModel extends ICellEditorModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  LinkReference linkReference = LinkReference();

  ColumnView? columnView;

  dynamic additionalCondition;

  String? displayReferencedColumnName;

  String? displayConcatMask;

  String? searchColumnMapping;

  bool searchTextAnywhere = true;

  bool searchInAllTableColumns = false;

  bool sortByColumnName = false;

  bool tableHeaderVisible = true;

  bool validationEnabled = true;

  bool doNotClearColumnNames = true;
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlLinkedCellEditorModel get defaultModel => FlLinkedCellEditorModel();

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    linkReference = getPropertyValue(
        pJson: pJson,
        pKey: ApiObjectProperty.linkReference,
        pDefault: defaultModel.linkReference,
        pCurrent: linkReference,
        pConversion: (value) => LinkReference.fromJson(value));

    columnView = getPropertyValue(
        pJson: pJson,
        pKey: ApiObjectProperty.columnView,
        pDefault: defaultModel.columnView,
        pCurrent: columnView,
        pConversion: (value) => ColumnView.fromJson(value));

    displayReferencedColumnName = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.displayReferencedColumnName,
      pDefault: defaultModel.displayReferencedColumnName,
      pCurrent: displayReferencedColumnName,
    );
  }
}
