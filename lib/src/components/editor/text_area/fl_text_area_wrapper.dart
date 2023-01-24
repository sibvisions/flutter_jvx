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
import 'package:flutter/scheduler.dart';

import '../../../mask/frame/frame.dart';
import '../../../model/component/editor/text_area/fl_text_area_model.dart';
import '../../base_wrapper/base_comp_wrapper_widget.dart';
import '../text_field/fl_text_field_widget.dart';
import '../text_field/fl_text_field_wrapper.dart';
import 'fl_text_area_widget.dart';

class FlTextAreaWrapper extends BaseCompWrapperWidget<FlTextAreaModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlTextAreaWrapper({super.key, required super.model});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlTextAreaWrapperState createState() => FlTextAreaWrapperState();
}

class FlTextAreaWrapperState extends FlTextFieldWrapperState<FlTextAreaModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    FlTextAreaWidget textAreaWidget = FlTextAreaWidget(
      key: Key("${model.id}_Widget"),
      model: model,
      endEditing: endEditing,
      valueChanged: valueChanged,
      focusNode: focusNode,
      textController: textController,
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: textAreaWidget);
  }

  @override
  Size calculateSize(BuildContext context) {
    Size size = super.calculateSize(context);

    double height = size.height;

    EdgeInsets paddings = Frame.isWebFrame() ? FlTextFieldWidget.WEBFRAME_PADDING : FlTextFieldWidget.MOBILE_PADDING;

    if (model.rows > 1) {
      height -= paddings.vertical;
      height *= model.rows;
      height += paddings.vertical;
    }

    return Size(size.width, height);
  }
}
