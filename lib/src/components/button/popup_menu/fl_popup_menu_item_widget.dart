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

import '../../../model/component/button/fl_popup_menu_item_model.dart';
import '../../../util/image/image_loader.dart';

class FlPopupMenuItemWidget extends PopupMenuItem<String> {
  final String id;

  const FlPopupMenuItemWidget({
    super.key,
    super.value,
    super.onTap,
    super.enabled = true,
    super.height = kMinInteractiveDimension,
    super.padding,
    super.mouseCursor,
    required this.id,
    required super.child,
  });

  factory FlPopupMenuItemWidget.withModel(FlPopupMenuItemModel pModel, bool pForceIconSlot) {
    return FlPopupMenuItemWidget(
      id: pModel.id,
      enabled: pModel.isEnabled,
      value: pModel.name,
      child: pForceIconSlot
          ? Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  alignment: Alignment.center,
                  child: _createIcon(pModel.icon),
                ),
                _createText(pModel),
              ],
            )
          : _createText(pModel),
    );
  }

  static Widget _createText(FlPopupMenuItemModel pModel) {
    return Padding(
      padding: const EdgeInsets.only(left: 5.0),
      child: Text(
        pModel.text,
        style: pModel.createTextStyle(),
      ),
    );
  }

  static Widget _createIcon(String? icon) {
    if (icon == null) {
      return const SizedBox.square(dimension: 16.0);
    } else {
      return ImageLoader.loadImage(
        icon,
        imageProvider: ImageLoader.getImageProvider(icon),
        pWantedSize: const Size.square(16),
      );
    }
  }
}
