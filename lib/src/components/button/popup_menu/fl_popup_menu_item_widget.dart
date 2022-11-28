import 'package:flutter/material.dart';

import '../../../../util/image/image_loader.dart';
import '../../../model/component/button/fl_popup_menu_item_model.dart';

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
      return ImageLoader.loadImage(icon, pWantedSize: const Size.square(16));
    }
  }
}
