import 'package:flutter/material.dart';
import 'package:flutterclient/src/ui/component/co_radio_button_widget.dart';
import 'package:flutterclient/src/ui/component/co_text_field_widget.dart';
import 'package:flutterclient/src/ui/component/co_toggle_button_widget.dart';
import 'package:flutterclient/src/ui/component/model/toggle_button_component_model.dart';
import 'package:flutterclient/src/ui/container/co_group_panel_widget.dart';
import 'package:flutterclient/src/ui/container/co_scroll_panel_widget.dart';
import 'package:flutterclient/src/ui/container/co_split_panel_widget.dart';
import 'package:flutterclient/src/ui/container/models/group_panel_component_model.dart';
import 'package:flutterclient/src/ui/container/models/split_panel_component_model.dart';
import 'package:flutterclient/src/ui/editor/cell_editor/co_checkbox_cell_editor_widget.dart';
import 'package:flutterclient/src/ui/editor/cell_editor/co_choice_cell_editor_widget.dart';
import 'package:flutterclient/src/ui/editor/cell_editor/co_date_cell_editor_widget.dart';
import 'package:flutterclient/src/ui/editor/cell_editor/co_image_cell_editor_widget.dart';
import 'package:flutterclient/src/ui/editor/cell_editor/co_linked_cell_editor_widget.dart';
import 'package:flutterclient/src/ui/editor/cell_editor/co_number_cell_editor_widget.dart';
import 'package:flutterclient/src/ui/editor/cell_editor/models/cell_editor_model.dart';
import 'package:flutterclient/src/ui/editor/cell_editor/models/checkbox_cell_editor_model.dart';
import 'package:flutterclient/src/ui/editor/cell_editor/models/choice_cell_editor_model.dart';
import 'package:flutterclient/src/ui/editor/cell_editor/models/date_cell_editor_model.dart';
import 'package:flutterclient/src/ui/editor/cell_editor/models/image_cell_editor_model.dart';
import 'package:flutterclient/src/ui/editor/cell_editor/models/linked_cell_editor_model.dart';
import 'package:flutterclient/src/ui/editor/cell_editor/models/number_cell_editor_model.dart';
import 'package:uuid/uuid.dart';

import '../../../models/api/response_objects/response_data/component/changed_component.dart';
import '../../../models/api/response_objects/response_data/editor/cell_editor.dart';
import '../../component/co_button_widget.dart';
import '../../component/co_checkbox_component_widget.dart';
import '../../component/co_icon_widget.dart';
import '../../component/co_label_widget.dart';
import '../../component/co_password_field_widget.dart';
import '../../component/co_table_widget.dart';
import '../../component/co_text_area_widget.dart';
import '../../component/component_widget.dart';
import '../../component/model/button_component_model.dart';
import '../../component/model/component_model.dart';
import '../../component/model/icon_component_model.dart';
import '../../component/model/label_component_model.dart';
import '../../component/model/selectable_component_model.dart';
import '../../component/model/table_component_model.dart';
import '../../component/model/text_area_component_model.dart';
import '../../component/model/text_field_component_model.dart';
import '../../component/popup_menu/co_menu_item_widget.dart';
import '../../component/popup_menu/co_popup_menu_button_widget.dart';
import '../../component/popup_menu/co_popup_menu_widget.dart';
import '../../component/popup_menu/models/menu_item_component_model.dart';
import '../../component/popup_menu/models/popup_menu_button_component_model.dart';
import '../../component/popup_menu/models/popup_menu_component_model.dart';
import '../../container/co_panel_widget.dart';
import '../../container/models/container_component_model.dart';
import '../../editor/cell_editor/co_cell_editor_widget.dart';
import '../../editor/cell_editor/co_text_cell_editor_widget.dart';
import '../../editor/cell_editor/models/text_cell_editor_model.dart';
import '../../editor/co_editor_widget.dart';
import '../../editor/editor_component_model.dart';
import 'i_component_creator.dart';
import 'so_component_data.dart';

typedef ComponentWidgetBuilder = ComponentWidget Function(ComponentModel);
typedef CellEditorWidgetBuilder = CoCellEditorWidget Function(
    CellEditor cellEditor);

class SoComponentCreator implements IComponentCreator {
  static final Uuid uuid = Uuid();

  SoComponentCreator();

  Map<String, ComponentWidgetBuilder> standardComponents = {
    // Containers
    'Panel': (ComponentModel componentModel) => CoPanelWidget(
        componentModel: componentModel as ContainerComponentModel),
    'ScrollPanel': (ComponentModel componentModel) => CoScrollPanelWidget(
        componentModel: componentModel as ContainerComponentModel),
    'GroupPanel': (ComponentModel componentModel) => CoGroupPanelWidget(
        componentModel: componentModel as GroupPanelComponentModel),
    'SplitPanel': (ComponentModel componentModel) => CoSplitPanelWidget(
        componentModel: componentModel as SplitPanelComponentModel),

    // Components
    'Label': (ComponentModel componentModel) =>
        CoLabelWidget(componentModel: componentModel as LabelComponentModel),
    'Button': (ComponentModel componentModel) =>
        CoButtonWidget(componentModel: componentModel as ButtonComponentModel),
    'Icon': (ComponentModel componentModel) =>
        CoIconWidget(componentModel: componentModel as IconComponentModel),
    'PopupMenu': (ComponentModel componentModel) => CoPopupMenuWidget(
          componentModel: componentModel as PopupMenuComponentModel,
        ),
    'MenuItem': (ComponentModel componentModel) => CoMenuItemWidget(
          componentModel: componentModel as MenuItemComponentModel,
        ),
    'PopupMenuButton': (ComponentModel componentModel) =>
        CoPopupMenuButtonWidget(
          componentModel: componentModel as PopupMenuButtonComponentModel,
        ),
    'CheckBox': (ComponentModel componentModel) => CoCheckBoxWidget(
        componentModel: componentModel as SelectableComponentModel),
    'PasswordField': (ComponentModel componentModel) => CoPasswordFieldWidget(
          componentModel: componentModel as TextFieldComponentModel,
        ),
    'Table': (ComponentModel componentModel) => CoTableWidget(
          componentModel: componentModel as TableComponentModel,
        ),
    'TextArea': (ComponentModel componentModel) => CoTextAreaWidget(
        componentModel: componentModel as TextAreaComponentModel),
    'TextField': (ComponentModel componentModel) => CoTextFieldWidget(
        componentModel: componentModel as TextFieldComponentModel),
    'ToggleButton': (ComponentModel componetModel) => CoToggleButtonWidget(
        componentModel: componetModel as ToggleButtonComponentModel),
    'RadioButton': (ComponentModel componentModel) => CoRadioButtonWidget(
        componentModel: componentModel as SelectableComponentModel),
  };

  Map<String, CellEditorWidgetBuilder> standardCellEditors = {
    'TextCellEditor': (CellEditor cellEditor) => CoTextCellEditorWidget(
        cellEditorModel: TextCellEditorModel(cellEditor: cellEditor)),
    'CheckBoxCellEditor': (CellEditor cellEditor) => CoCheckboxCellEditorWidget(
        cellEditorModel:
            CheckBoxCellEditorModel(currentCellEditor: cellEditor)),
    'NumberCellEditor': (CellEditor cellEditor) => CoNumberCellEditorWidget(
        cellEditorModel: NumberCellEditorModel(cellEditor: cellEditor)),
    'ImageViewer': (CellEditor cellEditor) => CoImageCellEditorWidget(
        cellEditorModel: ImageCellEditorModel(cellEditor: cellEditor)),
    'ChoiceCellEditor': (CellEditor cellEditor) => CoChoiceCellEditorWidget(
        cellEditorModel: ChoiceCellEditorModel(cellEditor: cellEditor)),
    'DateCellEditor': (CellEditor cellEditor) => CoDateCellEditorWidget(
        cellEditorModel: DateCellEditorModel(cellEditor: cellEditor)),
    'LinkedCellEditor': (CellEditor cellEditor) => CoLinkedCellEditorWidget(
        cellEditorModel: LinkedCellEditorModel(cellEditor: cellEditor))
  };

  @override
  ComponentWidget createComponent(ComponentModel componentModel) {
    late ComponentWidget componentWidget;

    if (componentModel.changedComponent.className?.isNotEmpty ?? true) {
      if (componentModel.changedComponent.className == 'Editor') {
        componentWidget = _createEditor(componentModel);
      } else if (componentModel.changedComponent.className == null ||
          this.standardComponents[componentModel.changedComponent.className] ==
              null) {
        componentWidget =
            _createDefaultComponent(componentModel.changedComponent);
      } else {
        componentWidget =
            standardComponents[componentModel.changedComponent.className]!(
                componentModel);
      }
    }

    return componentWidget;
  }

  ComponentWidget _createDefaultComponent(ChangedComponent changedComponent) {
    LabelComponentModel model =
        LabelComponentModel(changedComponent: changedComponent);
    model.text = 'Undefined Component "${changedComponent.className}"!';

    ComponentWidget componentWidget = CoLabelWidget(componentModel: model);

    return componentWidget;
  }

  CoEditorWidget _createEditor(ComponentModel componentModel) {
    CoEditorWidget editor = CoEditorWidget(
      cellEditor: createCellEditor(componentModel.changedComponent.cellEditor!),
      editorComponentModel: componentModel as EditorComponentModel,
    );

    return editor;
  }

  CoCellEditorWidget createCellEditor(CellEditor toCreateCellEditor) {
    if (standardCellEditors[toCreateCellEditor.className] != null) {
      CoCellEditorWidget cellEditor =
          standardCellEditors[toCreateCellEditor.className]!(
              toCreateCellEditor);

      return cellEditor;
    } else {
      return CoCellEditorWidget(
          cellEditorModel: CellEditorModel(cellEditor: toCreateCellEditor));
    }
  }

  CoCellEditorWidget? createCellEditorForTable(
      CellEditor toCreateCellEditor, SoComponentData data) {
    CoCellEditorWidget? cellEditor;

    switch (toCreateCellEditor.className) {
      case "DateCellEditor":
        {
          cellEditor = CoDateCellEditorWidget(
            cellEditorModel: DateCellEditorModel(cellEditor: toCreateCellEditor)
              ..isTableView = true,
          );
        }
        break;
      case "ChoiceCellEditor":
        {
          cellEditor = CoChoiceCellEditorWidget(
            cellEditorModel:
                ChoiceCellEditorModel(cellEditor: toCreateCellEditor)
                  ..isTableView = true,
          );
        }
        break;
      case "CheckBoxCellEditor":
        {
          cellEditor = CoCheckboxCellEditorWidget(
              cellEditorModel:
                  CheckBoxCellEditorModel(currentCellEditor: toCreateCellEditor)
                    ..isTableView = true);
        }
        break;
      case "LinkedCellEditor":
        {
          cellEditor = CoLinkedCellEditorWidget(
            cellEditorModel:
                LinkedCellEditorModel(cellEditor: toCreateCellEditor)
                  ..isTableView = true
                  ..referencedData = data,
          );
        }
        break;
    }

    return cellEditor;
  }

  CoEditorWidget? createEditorForTable(
      CellEditor toCreatecellEditor,
      dynamic value,
      bool editable,
      int indexInTable,
      SoComponentData data,
      String columnName) {
    CoCellEditorWidget? cellEditor =
        createCellEditorForTable(toCreatecellEditor, data);

    if (cellEditor == null) return null;

    EditorComponentModel componentModel =
        EditorComponentModel.withoutChangedComponent(
            value, columnName, indexInTable, null, editable);

    // componentModel.indexInTable = indexInTable;

    CoEditorWidget editor = CoEditorWidget(
      key: ValueKey(uuid.v4()),
      cellEditor: cellEditor,
      editorComponentModel: componentModel,
    );

    componentModel.data = data;

    return editor;
  }

  void replaceComponent(
      String className, ComponentWidget Function(ComponentModel) closure) {
    this.standardComponents[className] = closure;
  }

  void replaceCellEditor(
      String className, CoCellEditorWidget Function(CellEditor) closure) {
    this.standardCellEditors[className] = closure;
  }
}
