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

import 'package:flutter/material.dart';

import '../../../components.dart';
import '../../../model/command/api/press_button_command.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../model/layout/alignments.dart';
import '../../../service/api/shared/api_object_property.dart';
import '../../../service/command/i_command_service.dart';
import '../../base_wrapper/base_comp_wrapper_widget.dart';
import '../../button/fl_button_wrapper.dart';
import '../../button/toggle/fl_toggle_button_wrapper.dart';

class FlButtonGroupWidget<T extends FlPanelModel> extends FlStatelessWidget<T> {

  final Key? buttonKey;

  final List<Widget> children;

  final HorizontalAlignment horizontalAlignment;

  const FlButtonGroupWidget({
    super.key,
    this.buttonKey,
    required super.model,
    required this.children,
    this.horizontalAlignment = HorizontalAlignment.LEFT
  });

  @override
  Widget build(BuildContext context) {
    List<bool> selected = [];
    List<Widget> widgets = [];

    for (Widget w in children) {
      if (w is FlButtonWrapper) {
        Widget button = FlButtonWidget.createChildWidget(context, w.model, FlButtonWidget.getImage(w.model)) ?? Text("");

        widgets.add(Padding(
            padding: EdgeInsets.only(left: 8, right: 8),
            child: button
        ));

        selected.add(w is FlToggleButtonWrapper ? w.model.selected : false);
      }
    }


    Widget buttonWidget = Column(
      mainAxisAlignment: MainAxisAlignment.start,
        children: [LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(scrollDirection: Axis.horizontal,
              child: ToggleButtons(
                key: buttonKey,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                onPressed: (int index) {
                  ICommandService().sendCommand(PressButtonCommand(componentName: (children[index] as BaseCompWrapperWidget).model.name, reason: "ButtonGroup pressed button"));
                },
              isSelected: selected,
              children: widgets
          ));
        })]);

    switch (horizontalAlignment) {
      case HorizontalAlignment.CENTER:
        buttonWidget = Align(alignment: AlignmentGeometry.topCenter, child: buttonWidget);
        break;
      case HorizontalAlignment.RIGHT:
        buttonWidget = Align(alignment: AlignmentGeometry.topEnd, child: buttonWidget);
      default:
        break;
    }

    Color? background = model.background;

    if (model.hasDefaultEditorBackground) {
      background ??= FlTextFieldWidget.defaultBackground(context);
    }

    if (background != null) {
      buttonWidget = DecoratedBox(
        decoration: BoxDecoration(color: background),
        child: buttonWidget,
      );
    }

    if (model.hasStandardBorder) {
      return FlPanelWidget.wrapWithStandardBorder(buttonWidget);
    }

    return buttonWidget;
  }
}

class MyButtonsLayoutDelegate extends SingleChildLayoutDelegate {
  final Function(Size) onSizeMeasured;

  MyButtonsLayoutDelegate({required this.onSizeMeasured});

  @override
  Size getSize(BoxConstraints constraints) {
    // Das Layout-System fragt hier: "Wie groß soll ich (das Parent) sein?"
    // Wir lassen es standardmäßig die Constraints ausfüllen.
    return super.getSize(constraints);
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    // Wir geben dem Kind unbegrenzten horizontalen Platz
    return constraints.copyWith(
      minWidth: 0,
      maxWidth: double.infinity,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // Hier wird das Kind platziert UND wir kennen endlich seine 'childSize'!
    // Wir nutzen einen PostFrameCallback, um den State-Fehler zu vermeiden.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onSizeMeasured(childSize);
    });

    return Offset.zero; // Standard-Position oben links
  }

  @override
  bool shouldRelayout(MyButtonsLayoutDelegate oldDelegate) => true;
}