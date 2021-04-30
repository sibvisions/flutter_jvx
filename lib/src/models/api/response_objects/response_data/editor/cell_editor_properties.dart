import '../component/properties.dart';

enum CellEditorProperty {
  CLASS_NAME,
  HORIZONTAL_ALIGNMENT,
  VERTICAL_ALIGNMENT,
  PREFERRED_EDITOR_MODE,
  CONTENT_TYPE,
  DIRECT_CELL_EDITOR,
  COLUMN_NAME,
  DEFAULT_IMAGE_NAME,
  ALLOWED_VALUES,
  IMAGE_NAMES,
  DATE_FORMAT,
  NUMBER_FORMAT,
  DATA_PROVIDER,
  SELECTED_VALUE,
  DESELECTED_VALUE,
  TEXT,
  BORDER_VISIBLE,
  PLACEHOLDER_VISIBLE,
  DEFAULT_IMAGE,
  IMAGES,
  BOOLEAN,
  PRECISION,
  SCALE,
  LENGTH,
  SIGNED,
  PRESERVE_ASPECT_RATIO,
  TABLE_READONLY,
  COLUMNS,
  ROWS
}

class CellEditorProperties {
  Properties _properties;

  CellEditorProperties(Map<String, dynamic> json)
      : _properties = Properties(json);

  bool hasProperty(CellEditorProperty property) {
    return _properties
        .hasProperty(Properties.propertyAsString(property.toString()));
  }

  void removeProperty(CellEditorProperty property) {
    _properties
        .removeProperty(Properties.propertyAsString(property.toString()));
  }

  T? getProperty<T>(CellEditorProperty property, T? defaultValue) {
    return _properties.getProperty<T>(
        Properties.propertyAsString(property.toString()), defaultValue);
  }
}
