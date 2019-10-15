import 'package:jvx_mobile_v3/model/popup_size.dart';
import 'package:jvx_mobile_v3/model/properties/cell_editor_properties.dart';
import 'column_view.dart';
import 'link_reference.dart';

class CellEditor extends CellEditorProperties {
  String className;
  LinkReference linkReference;
  ColumnView columnView;
  PopupSize popupSize;

  CellEditor.fromJson(Map<String, dynamic> json) : super(json) {
    className = this.getProperty<String>(CellEditorProperty.CLASS_NAME);
    if (json['linkReference'] != null) linkReference = LinkReference.fromJson(json['linkReference']);
    if (json['columnView'] != null) columnView = ColumnView.fromJson(json['columnView']);
    if (json['popupSize'] != null) popupSize = PopupSize.fromJson(json['popupSize']);
  }
}