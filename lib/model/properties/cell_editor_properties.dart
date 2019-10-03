
import 'package:jvx_mobile_v3/model/properties/properties.dart';

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
  IMAGE_NAMES
}

class CellEditorProperties {
  Properties _properties;

  CellEditorProperties(Map<String, dynamic> json) {
    _properties = Properties(json);
  }

  bool hasProperty(CellEditorProperty property) {
    return _properties.hasProperty(_properties.propertyAsString(property.toString()));
  }

  void removeProperty(CellEditorProperty property) {
    _properties.removeProperty(_properties.propertyAsString(property.toString()));
  }

  T getProperty<T>(CellEditorProperty property, [T defaultValue]) {
    return _properties.getProperty<T>(_properties.propertyAsString(property.toString()), defaultValue);
  }
}
