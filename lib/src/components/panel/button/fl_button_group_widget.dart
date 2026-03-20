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

import '../../../model/component/fl_component_model.dart';
import '../../../model/layout/alignments.dart';
import '../../../util/haptic_util.dart';
import '../../base_wrapper/fl_stateless_widget.dart';
import '../../button/fl_button_widget.dart';
import '../../button/fl_button_wrapper.dart';
import '../../button/toggle/fl_toggle_button_wrapper.dart';
import '../../editor/text_field/fl_text_field_widget.dart';
import '../fl_panel_widget.dart';

class FlButtonGroupWidget<T extends FlPanelModel> extends FlStatelessWidget<T> {

  /// The fast-access key for buttons component
  final Key? buttonsKey;

  /// The children
  final List<Widget> children;

  /// The on-pressed listener
  final void Function(int index)? onPressed;

  final HorizontalAlignment horizontalAlignment;

  const FlButtonGroupWidget({
    super.key,
    this.buttonsKey,
    required super.model,
    required this.children,
    this.horizontalAlignment = HorizontalAlignment.LEFT,
    this.onPressed
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
                key: buttonsKey,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                onPressed: (int index) {
                  FlButtonModel butmod = (children[index] as FlButtonWrapper).model;

                  if (butmod.isHapticLight) {
                    HapticUtil.light();
                  } else if (butmod.isHapticMedium) {
                    HapticUtil.medium();
                  } else if (butmod.isHapticHeavy) {
                    HapticUtil.heavy();
                  } else if (butmod.isHapticClick) {
                    HapticUtil.selection();
                  } else if (butmod.isHaptic) {
                    HapticUtil.vibrate();
                  }

                  onPressed?.call(index);
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