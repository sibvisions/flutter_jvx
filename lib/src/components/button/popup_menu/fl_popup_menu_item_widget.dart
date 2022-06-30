import 'package:flutter/material.dart';
import 'package:flutter_client/src/model/component/button/fl_popup_menu_items_model.dart';
import 'package:flutter_client/util/image/image_loader.dart';

abstract class FlPopupMenuItemWidget {
  static PopupMenuEntry<String> withModel(FlPopupMenuItemModel pModel, bool pForceIconSlot) {
    return PopupMenuItem<String>(
      enabled: pModel.isEnabled,
      value: pModel.name,
      child: pForceIconSlot
          ? Row(
              children: [
                _createIcon(pModel.icon),
                _createText(pModel),
              ],
            )
          : _createText(pModel),
    );
  }

  static Widget _createText(FlPopupMenuItemModel pModel) {
    return Padding(padding: const EdgeInsets.only(left: 5.0), child: Text(pModel.text, style: pModel.getTextStyle()));
  }

  static Widget _createIcon(String? icon) {
    if (icon == null) {
      return const SizedBox.square(dimension: 16.0);
    } else {
      return ImageLoader.loadImage(icon, pWantedSize: const Size.square(16));
    }
  }
}
