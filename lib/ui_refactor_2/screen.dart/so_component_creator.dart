import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/model/cell_editor.dart';
import 'package:jvx_flutterclient/model/changed_component.dart';
import 'package:jvx_flutterclient/model/properties/component_properties.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/co_button_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/co_label_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/component_model.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/component_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/container/co_container_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/container/co_panel_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/container/container_component_model.dart';
import 'package:jvx_flutterclient/ui_refactor_2/editor/celleditor/co_cell_editor_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/editor/celleditor/co_checkbox_cell_editor_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/editor/celleditor/co_number_cell_editor_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/editor/celleditor/co_text_cell_editor_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/editor/co_editor_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/layout/co_border_layout.dart';
import 'package:jvx_flutterclient/ui_refactor_2/layout/i_layout.dart';

import 'i_component_creator.dart';

class SoComponentCreator implements IComponentCreator {
  BuildContext context;

  SoComponentCreator([this.context]);

  Map<String, ComponentWidget Function(ChangedComponent changedComponent)>
      standardComponents = {
    'Label': (ChangedComponent changedComponent) => CoLabelWidget(
          key: GlobalKey(debugLabel: changedComponent.id),
          text: '',
          componentModel:
              ComponentModel(currentChangedComponent: changedComponent),
        ),
    'Panel': (ChangedComponent changedComponent) => CoPanelWidget(
          key: GlobalKey(debugLabel: changedComponent.id),
          componentModel: ContainerComponentModel(
              currentChangedComponent: changedComponent),
        ),
    'Button': (ChangedComponent changedComponent) => CoButtonWidget(
          key: GlobalKey(debugLabel: changedComponent.id),
          componentModel:
              ComponentModel(currentChangedComponent: changedComponent),
        ),
  };

  Map<String, CoCellEditorWidget Function(CellEditor cellEditor)>
      standardCellEditors = {
    'CheckBoxCellEditor': (CellEditor cellEditor) => CoCheckboxCellEditorWidget(
          changedCellEditor: cellEditor,
        ),
    'TextCellEditor': (CellEditor cellEditor) => CoTextCellEditorWidget(
          changedCellEditor: cellEditor,
        ),
    'NumberCellEditor': (CellEditor cellEditor) => CoNumberCellEditorWidget(
          changedCellEditor: cellEditor,
        )
  };

  @override
  ComponentWidget createComponent(ChangedComponent changedComponent) {
    ComponentWidget componentWidget;

    if (changedComponent?.className?.isNotEmpty ?? true) {
      if (changedComponent.className == 'Editor') {
        componentWidget = _createEditor(changedComponent);
      } else if (changedComponent.className == null ||
          this.standardComponents[changedComponent.className] == null) {
        componentWidget = _createDefaultComponent(changedComponent);
      } else {
        componentWidget = this
            .standardComponents[changedComponent.className](changedComponent);
      }
    }

    componentWidget.componentModel.parentComponentId =
        changedComponent.getProperty<String>(ComponentProperty.PARENT);

    if (componentWidget is CoContainerWidget)
      (componentWidget.componentModel as ContainerComponentModel).layout =
          _createLayout(componentWidget, changedComponent);

    return componentWidget;
  }

  ComponentWidget _createDefaultComponent(ChangedComponent changedComponent) {
    ComponentWidget componentWidget = CoLabelWidget(
      text: "Undefined Component '" +
          (changedComponent.className != null
              ? changedComponent.className
              : "") +
          "'!",
      componentModel: ComponentModel(currentChangedComponent: changedComponent),
    );

    return componentWidget;
  }

  ILayout _createLayout(
      CoContainerWidget container, ChangedComponent changedComponent) {
    if (changedComponent.hasProperty(ComponentProperty.LAYOUT)) {
      String layoutRaw =
          changedComponent.getProperty<String>(ComponentProperty.LAYOUT);
      String layoutData =
          changedComponent.getProperty<String>(ComponentProperty.LAYOUT_DATA);

      switch (changedComponent.layoutName) {
        case "BorderLayout":
          {
            return CoBorderLayout.fromLayoutString(
                container, layoutRaw, layoutData);
          }
          break;
        /*
        case "FormLayout":
          {
            return CoFormLayout.fromLayoutString(
                container, layoutRaw, layoutData);
          }
          break;
        case "FlowLayout":
          {
            return CoFlowLayout.fromLayoutString(
                container, layoutRaw, layoutData);
          }
          break;
        case "GridLayout":
          {
            return CoGridLayout.fromLayoutString(
                container, layoutRaw, layoutData);
          }
          break;
        */
      }
    }

    return null;
  }

  CoEditorWidget _createEditor(ChangedComponent changedComponent) {
    CoEditorWidget editor = CoEditorWidget(
      cellEditor: createCellEditor(changedComponent.cellEditor),
      key: GlobalKey(debugLabel: changedComponent.id),
      componentModel: ComponentModel(currentChangedComponent: changedComponent),
    );
    return editor;
  }

  CoCellEditorWidget createCellEditor(CellEditor toCreatecellEditor) {
    CoCellEditorWidget cellEditor;

    if (toCreatecellEditor == null) {
      cellEditor = null;
    } else {
      cellEditor = this.standardCellEditors[toCreatecellEditor.className](
          toCreatecellEditor);
    }

    return cellEditor;
  }

  CoCellEditorWidget createCellEditorForTable(CellEditor toCreatecellEditor) {
    CoCellEditorWidget cellEditor;
    switch (toCreatecellEditor.className) {
      /*
      case "DateCellEditor":
        {
          cellEditor = CoDateCellEditor(toCreatecellEditor, context);
        }
        break;
      case "ChoiceCellEditor":
        {
          cellEditor = CoChoiceCellEditor(toCreatecellEditor, context);
        }
        break;
        */
      case "CheckBoxCellEditor":
        {
          cellEditor =
              CoCheckboxCellEditorWidget(changedCellEditor: toCreatecellEditor);
        }
        break;
    }

    // cellEditor?.isTableView = true;

    return cellEditor;
  }
}
