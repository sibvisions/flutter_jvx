import 'cell_editor_properties.dart';
import 'column_view.dart';
import 'link_reference.dart';
import 'popup_size.dart';

class CellEditor extends CellEditorProperties {
  String className;
  LinkReference linkReference;
  ColumnView columnView;
  PopupSize popupSize;

  CellEditor.fromJson(Map<String, dynamic> json) : super(json) {
    className = this.getProperty<String>(CellEditorProperty.CLASS_NAME);
    if (json['linkReference'] != null)
      linkReference = LinkReference.fromJson(json['linkReference']);
    if (json['columnView'] != null)
      columnView = ColumnView.fromJson(json['columnView']);
    if (json['popupSize'] != null)
      popupSize = PopupSize.fromJson(json['popupSize']);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'className': className,
        'linkReference': linkReference?.toJson(),
        'columnView': columnView?.toJson(),
        'popupSize': popupSize?.toJson()
      };
}
