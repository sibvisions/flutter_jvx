import 'dart:math';

import 'package:flutter/widgets.dart';

import '../../../layout/i_layout.dart';
import '../../../layout/scroll_layout.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../model/component/panel/fl_panel_model.dart';
import '../../../service/ui/i_ui_service.dart';
import '../../base_wrapper/base_comp_wrapper_state.dart';
import '../../base_wrapper/base_comp_wrapper_widget.dart';
import '../../base_wrapper/base_cont_wrapper_state.dart';
import 'fl_scroll_panel_widget.dart';

class FlScrollPanelWrapper extends BaseCompWrapperWidget<FlPanelModel> {
  const FlScrollPanelWrapper({super.key, required super.id});

  @override
  BaseCompWrapperState<FlComponentModel> createState() => _FlScrollPanelWrapperState();
}

class _FlScrollPanelWrapperState extends BaseContWrapperState<FlPanelModel> {
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _vertictalController = ScrollController();

  @override
  void initState() {
    super.initState();

    ILayout originalLayout = ILayout.getLayout(model.layout, model.layoutData)!;
    layoutData.layout = ScrollLayout(originalLayout);
    layoutData.children = IUiService().getChildrenModels(model.id).map((e) => e.id).toList();

    buildChildren(pSetStateOnChange: false);
    registerParent();
  }

  @override
  receiveNewModel(FlPanelModel pModel) {
    ILayout originalLayout = ILayout.getLayout(pModel.layout, pModel.layoutData)!;
    layoutData.layout = ScrollLayout(originalLayout);
    layoutData.children = IUiService().getChildrenModels(pModel.id).map((e) => e.id).toList();
    super.receiveNewModel(pModel);

    buildChildren();
    registerParent();
  }

  @override
  Widget build(BuildContext context) {
    FlScrollPanelWidget panelWidget = FlScrollPanelWidget(
      model: model,
      width: widthOfScrollPanel,
      height: heightOfScrollPanel,
      viewWidth: layoutData.layoutPosition?.width ?? widthOfScrollPanel,
      viewHeight: layoutData.layoutPosition?.height ?? heightOfScrollPanel,
      isScrollable: isScrollable,
      horizontalScrollController: _horizontalController,
      verticalScrollController: _vertictalController,
      children: children.values.toList(),
    );

    return (getPositioned(child: panelWidget));
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _vertictalController.dispose();

    super.dispose();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  double get widthOfScrollPanel {
    double width = ScrollLayout.widthOfScrollPanel(layoutData);

    if (layoutData.hasPosition) {
      width = max(layoutData.layoutPosition!.width, width);
    }

    return width;
  }

  double get heightOfScrollPanel {
    double height = ScrollLayout.heightOfScrollPanel(layoutData);

    // Forces the scroll panel to actually be the size.
    if (layoutData.hasPosition) {
      height = max(layoutData.layoutPosition!.height, height);
    }

    return height;
  }

  bool get isScrollable {
    if (layoutData.hasPosition) {
      return layoutData.layoutPosition!.width < widthOfScrollPanel ||
          layoutData.layoutPosition!.height < heightOfScrollPanel;
    }

    return true;
  }
}
