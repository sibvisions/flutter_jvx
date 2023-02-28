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

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../model/component/fl_component_model.dart';
import '../../model/layout/layout_data.dart';
import '../../util/image/image_loader.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';
import 'fl_icon_widget.dart';

class FlIconWrapper extends BaseCompWrapperWidget<FlIconModel> {
  const FlIconWrapper({super.key, required super.model});

  @override
  BaseCompWrapperState<FlComponentModel> createState() => _FlIconWrapperState();
}

class _FlIconWrapperState extends BaseCompWrapperState<FlIconModel> {
  ImageProvider? imageProvider;

  _FlIconWrapperState() : super();

  @override
  void initState() {
    super.initState();
    createImageProvider();
  }

  @override
  void modelUpdated() {
    createImageProvider();
    super.modelUpdated();
  }

  void createImageProvider() {
    imageProvider = ImageLoader.getImageProvider(model.image);
  }

  @override
  Widget build(BuildContext context) {
    final FlIconWidget widget = FlIconWidget(model: model, imageProvider: imageProvider);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: widget);
  }

  @override
  void sendCalcSize({required LayoutData pLayoutData, required String pReason}) {
    Size calcSize = model.image.isNotEmpty ? model.originalSize : Size.zero;

    LayoutData layoutData = pLayoutData.clone();
    layoutData.calculatedSize = calcSize;

    layoutData.widthConstrains.forEach((key, value) {
      layoutData.widthConstrains[key] = calcSize.height;
    });
    layoutData.heightConstrains.forEach((key, value) {
      layoutData.heightConstrains[key] = calcSize.width;
    });

    super.sendCalcSize(pLayoutData: layoutData, pReason: pReason);
  }
}
