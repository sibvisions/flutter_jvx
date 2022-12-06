import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../model/component/fl_component_model.dart';
import '../../model/component/icon/fl_icon_model.dart';
import '../../model/layout/layout_data.dart';
import '../../util/image/image_loader.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';
import 'fl_icon_widget.dart';

class FlIconWrapper extends BaseCompWrapperWidget<FlIconModel> {
  const FlIconWrapper({super.key, required super.id});

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
    LayoutData layoutData = pLayoutData.clone();
    layoutData.calculatedSize = model.originalSize;

    layoutData.widthConstrains.forEach((key, value) {
      layoutData.widthConstrains[key] = model.originalSize.height;
    });
    layoutData.heightConstrains.forEach((key, value) {
      layoutData.heightConstrains[key] = model.originalSize.width;
    });

    super.sendCalcSize(pLayoutData: layoutData, pReason: pReason);
  }
}
