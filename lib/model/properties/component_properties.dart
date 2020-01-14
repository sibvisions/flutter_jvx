
import 'package:jvx_mobile_v3/model/properties/properties.dart';

/// ComponentProperty.SCREEN__TITLE_NEW = screen.titleNew
/// 
/// ComponentProperty.SCREEN__TITLE = screen.title
/// 
/// ComponentProperty.SCREEN_TITLE = screenTitle
/// 
/// ComponentProperty.SCREENTITLE = screentitle

enum ComponentProperty {
  ID,
  NAME,
  CLASS_NAME,
  PARENT,
  INDEX_OF,
  LAYOUT,
  LAYOUT_DATA,
  DATA_PROVIDER,
  DATA_ROW,
  COLUMN_NAME,
  TEXT,
  BACKGROUND,
  VISIBLE,
  FONT,
  FOREGROUND,
  ENABLED,
  CONSTRAINTS,
  VERTICAL_ALIGNMENT,
  HORIZONTAL_ALIGNMENT,
  SHOW_VERTICAL_LINES,
  SHOW_HORIZONTAL_LINES,
  TABLE_HEADER_VISIBLE,
  COLUMN_NAMES,
  RELOAD,
  COLUMN_LABELS,
  DIVIDER_POSITION,
  DIVIDER_ALIGNMENT,
  MAXIMUM_SIZE,
  READONLY,
  EVENT_FOCUS_GAINED,
  $DESTROY,
  $REMOVE,
  SCREEN__TITLE,
  CELL_EDITOR__EDITABLE,
  CELL_EDITOR__PLACEHOLDER,
  CELL_EDITOR__BACKGROUND,
  CELL_EDITOR__FOREGROUND,
  CELL_EDITOR__HORIZONTAL_ALIGNMENT,
  CELL_EDITOR__FONT,
  SELECTED_ROW,
  LABEL,
  DATA_TYPE_IDENTIFIER,
  NULLABLE,
}

class ComponentProperties {
  Properties _properties;

  ComponentProperties(Map<String, dynamic> json) {
    _properties = Properties(json);
  }

  bool hasProperty(ComponentProperty property) {
    return _properties.hasProperty(_properties.propertyAsString(property.toString()));
  }

  void removeProperty(ComponentProperty property) {
    _properties.removeProperty(_properties.propertyAsString(property.toString()));
  }

  T getProperty<T>(ComponentProperty property, [T defaultValue]) {
    return _properties.getProperty<T>(_properties.propertyAsString(property.toString()), defaultValue);
  }
}
