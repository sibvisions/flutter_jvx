import 'package:flutter/material.dart';

import '../widgets/co_border_layout_constraint.dart';
import '../widgets/co_border_layout_widget.dart';
import 'border_layout_model.dart';

class CoBorderLayoutContainerWidget extends StatefulWidget {
  final BorderLayoutModel layoutModel;

  const CoBorderLayoutContainerWidget({Key? key, required this.layoutModel})
      : super(key: key);

  @override
  _CoBorderLayoutContainerWidgetState createState() =>
      _CoBorderLayoutContainerWidgetState();
}

class _CoBorderLayoutContainerWidgetState
    extends State<CoBorderLayoutContainerWidget> {
  late GlobalKey layoutKey;

  @override
  void initState() {
    super.initState();

    layoutKey = GlobalKey(
        debugLabel: widget.layoutModel.container?.componentModel.componentId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.layoutModel.margins,
      child: CoBorderLayoutWidget(
        key: layoutKey,
        container: widget.layoutModel.container,
        insMargin: widget.layoutModel.margins,
        iHorizontalGap: widget.layoutModel.horizontalGap,
        iVerticalGap: widget.layoutModel.verticalGap,
        children: [
          if (widget.layoutModel.center != null &&
              widget.layoutModel.center!.componentModel.isVisible)
            CoBorderLayoutId(
                pConstraints: CoBorderLayoutConstraintData(
                    CoBorderLayoutConstraints.Center,
                    widget.layoutModel.center!),
                child: widget.layoutModel.center!),
          if (widget.layoutModel.north != null &&
              widget.layoutModel.north!.componentModel.isVisible)
            CoBorderLayoutId(
                pConstraints: CoBorderLayoutConstraintData(
                    CoBorderLayoutConstraints.Center,
                    widget.layoutModel.north!),
                child: widget.layoutModel.north!),
          if (widget.layoutModel.south != null &&
              widget.layoutModel.south!.componentModel.isVisible)
            CoBorderLayoutId(
                pConstraints: CoBorderLayoutConstraintData(
                    CoBorderLayoutConstraints.Center,
                    widget.layoutModel.south!),
                child: widget.layoutModel.south!),
          if (widget.layoutModel.west != null &&
              widget.layoutModel.west!.componentModel.isVisible)
            CoBorderLayoutId(
                pConstraints: CoBorderLayoutConstraintData(
                    CoBorderLayoutConstraints.Center, widget.layoutModel.west!),
                child: widget.layoutModel.west!),
          if (widget.layoutModel.east != null &&
              widget.layoutModel.east!.componentModel.isVisible)
            CoBorderLayoutId(
                pConstraints: CoBorderLayoutConstraintData(
                    CoBorderLayoutConstraints.Center, widget.layoutModel.east!),
                child: widget.layoutModel.east!),
        ],
      ),
    );
  }
}
