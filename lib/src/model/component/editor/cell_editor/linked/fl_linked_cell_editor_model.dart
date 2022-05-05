import 'package:flutter_client/src/model/component/editor/cell_editor/linked/column_view.dart';
import 'package:flutter_client/src/model/component/editor/cell_editor/linked/link_reference.dart';

import '../../../../api/api_object_property.dart';
import '../cell_editor_model.dart';

class FlLinkedCellEditorModel extends ICellEditorModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  late LinkReference linkReference;

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
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    var jsonLinkReference = pJson[ApiObjectProperty.linkReference];
    if (jsonLinkReference != null) {
      linkReference = LinkReference.fromJson(jsonLinkReference);
    }

    var jsonColumnView = pJson[ApiObjectProperty.columnView];
    if (jsonColumnView != null) {
      columnView = ColumnView.fromJson(jsonColumnView);
    }

    var jsonDisplayReferencedColumnName = pJson[ApiObjectProperty.displayReferencedColumnName];
    if (jsonDisplayReferencedColumnName != null) {
      displayReferencedColumnName = jsonDisplayReferencedColumnName;
    }
  }
}
