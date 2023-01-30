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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../flutter_ui.dart';
import '../../../../model/component/fl_component_model.dart';
import '../../../../util/jvx_colors.dart';
import '../../text_field/fl_text_field_widget.dart';

class FlLinkedEditorWidget<T extends FlLinkedEditorModel> extends FlTextFieldWidget<T> {
  const FlLinkedEditorWidget({
    super.key,
    required super.model,
    required super.focusNode,
    required super.textController,
    required super.valueChanged,
    required super.endEditing,
    super.hideClearIcon,
  }) : super(keyboardType: TextInputType.none);

  @override
  List<Widget> createSuffixIconItems([bool pForceAll = false]) {
    List<Widget> oldSuffixItems = super.createSuffixIconItems(pForceAll);

    bool isLight = Theme.of(FlutterUI.getCurrentContext()!).brightness == Brightness.light;

    oldSuffixItems.add(
      SizedBox(
        width: FlTextFieldWidget.iconAreaSize,
        height: FlTextFieldWidget.iconAreaSize,
        child: Center(
          child: Icon(
            FontAwesomeIcons.caretDown,
            size: FlTextFieldWidget.iconSize,
            color: isLight ? JVxColors.COMPONENT_DISABLED : JVxColors.COMPONENT_DISABLED_LIGHTER,
          ),
        ),
      ),
    );

    return oldSuffixItems;
  }
}
