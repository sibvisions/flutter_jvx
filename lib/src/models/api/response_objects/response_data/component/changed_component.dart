import '../editor/cell_editor.dart';
import 'component_properties.dart';

class ChangedComponent extends ComponentProperties {
  static final String _cellEditorIdentifier = "cellEditor";
  String? id;
  String? name;
  String? className;
  CellEditor? cellEditor;
  bool? destroy;
  bool? remove;
  bool additional = false;
  String? screenTitle;
  String? screenNavigationName;
  bool? screenModal;

  ChangedComponent(
      {this.id,
      this.name,
      this.className,
      this.cellEditor,
      this.destroy,
      this.remove,
      this.screenTitle,
      this.screenModal,
      this.screenNavigationName})
      : super({});

  get layoutName {
    List<String>? parameter =
        this.getProperty<String>(ComponentProperty.LAYOUT, null)?.split(",");
    if (parameter != null && parameter.length > 0) {
      return parameter[0];
    }

    return null;
  }

  ChangedComponent.fromJson(Map<String, dynamic> json) : super(json) {
    id = this.getProperty<String>(ComponentProperty.ID, '');
    name = this.getProperty<String>(ComponentProperty.NAME, '');
    className = this.getProperty<String>(ComponentProperty.CLASS_NAME, '');
    destroy = this.getProperty<bool>(ComponentProperty.$DESTROY, false);
    remove = this.getProperty<bool>(ComponentProperty.$REMOVE, false);
    additional = this.getProperty<bool>(ComponentProperty.$ADDITIONAL, false)!;
    screenTitle =
        this.getProperty<String>(ComponentProperty.SCREEN___TITLE___, '');
    screenNavigationName = this
        .getProperty<String>(ComponentProperty.SCREEN___NAVIGATION_NAME___, '');
    screenModal =
        this.getProperty<bool>(ComponentProperty.SCREEN___MODAL___, false);

    if (json[_cellEditorIdentifier] != null)
      cellEditor = CellEditor.fromJson(json[_cellEditorIdentifier]);
  }
}
