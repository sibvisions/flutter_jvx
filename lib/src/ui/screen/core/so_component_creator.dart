import 'package:flutter/material.dart';
import 'package:flutterclient/src/models/api/response_objects/response_data/component/changed_component.dart';
import 'package:flutterclient/src/models/api/response_objects/response_data/editor/cell_editor.dart';
import 'package:flutterclient/src/ui/component/co_icon_widget.dart';
import 'package:flutterclient/src/ui/component/model/icon_component_model.dart';
import 'package:flutterclient/src/ui/component/popup_menu/co_menu_item_widget.dart';
import 'package:flutterclient/src/ui/component/popup_menu/co_popup_menu_button_widget.dart';
import 'package:flutterclient/src/ui/component/popup_menu/co_popup_menu_widget.dart';
import 'package:flutterclient/src/ui/component/popup_menu/models/menu_item_component_model.dart';
import 'package:flutterclient/src/ui/component/popup_menu/models/popup_menu_button_component_model.dart';
import 'package:flutterclient/src/ui/component/popup_menu/models/popup_menu_component_model.dart';
import 'package:flutterclient/src/ui/editor/cell_editor/co_cell_editor_widget.dart';
import 'package:flutterclient/src/ui/editor/cell_editor/co_text_cell_editor_widget.dart';
import 'package:flutterclient/src/ui/editor/cell_editor/models/text_cell_editor_model.dart';
import 'package:flutterclient/src/ui/editor/co_editor_widget.dart';
import 'package:flutterclient/src/ui/editor/editor_component_model.dart';
import 'package:flutterclient/src/ui/screen/core/so_component_data.dart';

import '../../component/co_button_widget.dart';
import '../../component/co_label_widget.dart';
import '../../component/model/button_component_model.dart';
import '../../component/model/component_model.dart';
import '../../component/component_widget.dart';
import '../../component/model/component_model.dart';
import '../../component/model/label_component_model.dart';
import '../../container/co_panel_widget.dart';
import '../../container/models/container_component_model.dart';
import 'i_component_creator.dart';
import 'package:uuid/uuid.dart';

typedef ComponentWidgetBuilder = ComponentWidget Function(ComponentModel);
typedef CellEditorWidgetBuilder = CoCellEditorWidget Function(
    CellEditor cellEditor);

class SoComponentCreator implements IComponentCreator {
  static final Uuid uuid = Uuid();

  SoComponentCreator();

  Map<String, ComponentWidgetBuilder> standardComponents = {
    'Panel': (ComponentModel componentModel) => CoPanelWidget(
        componentModel: componentModel as ContainerComponentModel),
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
  };

  Map<String, CellEditorWidgetBuilder> standardCellEditors = {
    'TextCellEditor': (CellEditor cellEditor) => CoTextCellEditorWidget(
        cellEditorModel: TextCellEditorModel(cellEditor: cellEditor))
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
    CoCellEditorWidget cellEditor =
        standardCellEditors[toCreateCellEditor.className]!(toCreateCellEditor);

    return cellEditor;
  }

  CoCellEditorWidget? createCellEditorForTable(
      CellEditor toCreateCellEditor, SoComponentData data) {
    CoCellEditorWidget? cellEditor;

    // switch (toCreateCellEditor.className) {
    // case "DateCellEditor":
    //   {
    //     cellEditor = CoDateCellEditorWidget(
    //       cellEditorModel: DateCellEditorModel(toCreatecellEditor)
    //         ..isTableView = true,
    //     );
    //   }
    //   break;
    // case "ChoiceCellEditor":
    //   {
    //     cellEditor = CoChoiceCellEditorWidget(
    //       cellEditorModel: ChoiceCellEditorModel(toCreatecellEditor)
    //         ..isTableView = true,
    //     );
    //   }
    //   break;
    // case "CheckBoxCellEditor":
    //   {
    //     cellEditor = CoCheckboxCellEditorWidget(
    //         cellEditorModel: CheckBoxCellEditorModel(toCreatecellEditor)
    //           ..isTableView = true);
    //   }
    //   break;
    // case "LinkedCellEditor":
    //   {
    //     cellEditor = CoLinkedCellEditorWidget(
    //       cellEditorModel: LinkedCellEditorModel(toCreatecellEditor)
    //         ..isTableView = true
    //         ..referencedData = data,
    //     );
    //   }
    //   break;
    // }

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
