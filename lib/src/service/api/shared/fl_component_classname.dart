/* 
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

/// The strings as sent by the JVxMobile server
abstract class FlComponentClassname {
  static const String LABEL = "Label";
  static const String BUTTON = "Button";
  static const String ICON = "Icon";
  static const String POPUP_MENU = "PopupMenu";
  static const String MENU_ITEM = "MenuItem";
  static const String SEPERATOR = "Separator";
  static const String POPUP_MENU_BUTTON = "PopupMenuButton";
  static const String CHECK_BOX = "CheckBox";
  static const String PASSWORD_FIELD = "PasswordField";
  static const String TABLE = "Table";
  static const String TEXT_AREA = "TextArea";
  static const String TEXT_FIELD = "TextField";
  static const String TOGGLE_BUTTON = "ToggleButton";
  static const String RADIO_BUTTON = "RadioButton";
  static const String MAP = "Map";
  static const String CHART = "Chart";
  static const String GAUGE = "Gauge";
  static const String EDITOR = "Editor";
  static const String TREE = "Tree";
}

abstract class FlContainerClassname {
  static const String PANEL = "Panel";
  static const String DESKTOP_PANEL = "DesktopPanel";
  static const String GROUP_PANEL = "GroupPanel";
  static const String SCROLL_PANEL = "ScrollPanel";
  static const String SPLIT_PANEL = "SplitPanel";
  static const String TABSET_PANEL = "TabsetPanel";
  static const String TOOLBAR_PANEL = "ToolBarPanel";
  static const String CUSTOM_CONTAINER = "CustomContainer";
  static const String DIALOG = "Dialog";
}

abstract class FlCellEditorClassname {
  static const String TEXT_CELL_EDITOR = "TextCellEditor";
  static const String CHECK_BOX_CELL_EDITOR = "CheckBoxCellEditor";
  static const String NUMBER_CELL_EDITOR = "NumberCellEditor";
  static const String IMAGE_VIEWER = "ImageViewer";
  static const String CHOICE_CELL_EDITOR = "ChoiceCellEditor";
  static const String DATE_CELL_EDITOR = "DateCellEditor";
  static const String LINKED_CELL_EDITOR = "LinkedCellEditor";
}
