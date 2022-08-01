import '../../../../../util/parse_util.dart';
import '../../../../service/api/shared/api_object_property.dart';
import '../../../layout/alignments.dart';

class ICellEditorModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Open Editor on double click. This should be the default behaviour.
  static const int DOUBLE_CLICK = 0;

  /// Open Editor with single click.
  static const int SINGLE_CLICK = 1;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The class name of the editor.
  String className = "";

  /// Description of the content
  String? contentType;

  /// The horizontal alignment of the editor.
  HorizontalAlignment horizontalAlignment = HorizontalAlignment.LEFT;

  /// The vertical alignment of the editor.
  VerticalAlignment verticalAlignment = VerticalAlignment.TOP;

  /// If this editor should be shown inside a table.
  bool directCellEditor = false;

  /// The preferred editor mode
  int preferredEditorMode = DOUBLE_CLICK;

  /// If this editor should open in a popup
  bool autoOpenPopup = false;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes a [ICellEditorModel] with default values
  ICellEditorModel();

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Method definitions
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ICellEditorModel get defaultModel => ICellEditorModel();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void applyFromJson(Map<String, dynamic> pJson) {
    // ClassName
    className = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.className,
      pDefault: defaultModel.className,
      pCurrent: className,
    );

    // ContentType
    contentType = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.contentType,
      pDefault: defaultModel.contentType,
      pCurrent: contentType,
    );

    // HorizontalAlignment
    horizontalAlignment = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.horizontalAlignment,
      pDefault: defaultModel.horizontalAlignment,
      pCurrent: horizontalAlignment,
      pConversion: HorizontalAlignmentE.fromDynamic,
    );

    // VerticalAlignment
    verticalAlignment = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.verticalAlignment,
      pDefault: defaultModel.verticalAlignment,
      pCurrent: verticalAlignment,
      pConversion: VerticalAlignmentE.fromDynamic,
    );

    // DirectCellEditor
    directCellEditor = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.directCellEditor,
      pDefault: defaultModel.directCellEditor,
      pCurrent: directCellEditor,
    );

    // PreferredEditorMode
    preferredEditorMode = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.preferredEditorMode,
      pDefault: defaultModel.preferredEditorMode,
      pCurrent: preferredEditorMode,
    );

    // AutoOpenPopup
    autoOpenPopup = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.autoOpenPopup,
      pDefault: defaultModel.autoOpenPopup,
      pCurrent: autoOpenPopup,
    );
  }

  dynamic getPropertyValue({
    required Map<String, dynamic> pJson,
    required String pKey,
    required dynamic pDefault,
    required dynamic pCurrent,
    dynamic Function(dynamic)? pConversion,
  }) {
    return ParseUtil.getPropertyValue(
      pJson: pJson,
      pKey: pKey,
      pDefault: pDefault,
      pCurrent: pCurrent,
      pConversion: pConversion,
    );
  }
}
