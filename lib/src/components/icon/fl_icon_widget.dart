import 'package:flutter/material.dart';
import 'package:flutter_client/src/model/component/icon/fl_icon_model.dart';
import 'package:flutter_client/util/constants/i_color.dart';
import 'package:flutter_client/util/image/image_loader.dart';

import '../../model/layout/alignments.dart';
import '../base_wrapper/fl_stateless_widget.dart';

class FlIconWidget<T extends FlIconModel> extends FlStatelessWidget<T> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overrideable widget defaults
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Widget get image {
    return ImageLoader.loadImage(model.image,
        pWantedColor: model.isEnabled ? null : IColorConstants.COMPONENT_DISABLED);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlIconWidget({Key? key, required T model}) : super(key: key, model: model);

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (model.tooltipText != null) {
      child = getTooltipWidget();
    } else {
      child = image;
    }

    if (!model.preserveAspectRatio) {
      child = Expanded(child: child);
    }

    return Container(
      child: child,
      decoration: BoxDecoration(color: model.background),
      alignment: FLUTTER_ALIGNMENT[model.horizontalAlignment.index][model.verticalAlignment.index],
    );
  }

  Tooltip getTooltipWidget() {
    return Tooltip(message: model.tooltipText!, child: image);
  }
}
