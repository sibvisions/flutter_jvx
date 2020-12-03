import 'properties.dart';

/// ComponentProperty.SCREEN__TITLE_NEW = screen.titleNew
///
/// ComponentProperty.SCREEN__TITLE = screen.title
///
/// ComponentProperty.SCREEN_TITLE = screenTitle
///
/// ComponentProperty.SCREENTITLE = screentitle
///
/// ComponentProperty.SCREEN___TITLE = screen.title

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
  DATA_BOOK,
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
  PREFERRED_SIZE,
  MAXIMUM_SIZE,
  MINIMUM_SIZE,
  READONLY,
  EVENT_FOCUS_GAINED,
  EVENT_ACTION,
  $DESTROY,
  $REMOVE,
  $ADDITIONAL,
  SCREEN__TITLE,
  CELL_EDITOR___EDITABLE___,
  CELL_EDITOR___PLACEHOLDER___,
  CELL_EDITOR___BACKGROUND___,
  CELL_EDITOR___FOREGROUND___,
  CELL_EDITOR___HORIZONTAL_ALIGNMENT___,
  CELL_EDITOR___FONT___,
  SELECTED_ROW,
  LABEL,
  DATA_TYPE_IDENTIFIER,
  NULLABLE,
  IMAGE,
  SELECTED,
  BORDER,
  COLUMNS,
  DEFAULT_MENU_ITEM,
  AUTO_RESIZE,
  EDITABLE,
  STYLE,
  EVENT_TAB_CLOSED,
  EVENT_TAB_MOVED,
  EVENT_TAB_ACTIVATED,
  SELECTED_INDEX,
  PLACEHOLDER
}

class ComponentProperties {
  Properties _properties;

  ComponentProperties(Map<String, dynamic> json) {
    _properties = Properties(json);
  }

  bool hasProperty(ComponentProperty property) {
    return _properties
        .hasProperty(_properties.propertyAsString(property.toString()));
  }

  void removeProperty(ComponentProperty property) {
    _properties
        .removeProperty(_properties.propertyAsString(property.toString()));
  }

  T getProperty<T>(ComponentProperty property, [T defaultValue]) {
    return _properties.getProperty<T>(
        _properties.propertyAsString(property.toString()), defaultValue);
  }
}
