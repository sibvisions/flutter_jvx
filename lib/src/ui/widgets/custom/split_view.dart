library split_view;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterclient/src/ui/component/component_widget.dart';
import 'package:flutterclient/src/ui/container/co_scroll_panel_layout.dart';

/// SplitView
class SplitView extends StatefulWidget {
  final key;
  final ComponentWidget view1;
  final ComponentWidget view2;
  final SplitViewMode viewMode;
  final double gripSize;
  final double initialWeight;
  final Color gripColor;
  final Color handleColor;
  final double positionLimit;
  final bool showHandle;
  final ValueChanged<double>? onWeightChanged;
  final ScrollController scrollControllerView1;
  final ScrollController scrollControllerView2;

  SplitView(
      {required this.key,
      required this.view1,
      required this.view2,
      required this.viewMode,
      this.gripSize = 7.0,
      this.initialWeight = 0.5,
      this.gripColor = Colors.grey,
      this.handleColor = Colors.white,
      this.positionLimit = 20.0,
      this.showHandle = true,
      this.onWeightChanged,
      required this.scrollControllerView1,
      required this.scrollControllerView2});

  @override
  State createState() => _SplitViewState();
}

class _SplitViewState extends State<SplitView> {
  late ValueNotifier<double> weight;
  double? _prevWeight;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    weight = ValueNotifier(widget.initialWeight);
    _prevWeight = widget.initialWeight;

    return LayoutBuilder(
      //key: widget.key,
      builder: (context, constraints) {
        return ValueListenableBuilder<double>(
          valueListenable: weight,
          builder: (_, w, __) {
            if (widget.onWeightChanged != null && _prevWeight != w) {
              _prevWeight = w;
              widget.onWeightChanged!(w);
            }
            if (widget.viewMode == SplitViewMode.Vertical) {
              return _buildVerticalView(context, constraints, w);
            } else {
              return _buildHorizontalView(context, constraints, w);
            }
          },
        );
      },
    );
  }

  void updatePreferredSize(Widget view, Size size) {
    if (view is CoScrollPanelLayout) {
      List<CoScrollPanelLayoutId>? children =
          view.children as List<CoScrollPanelLayoutId>?;
      if (children != null && children.length > 0) {
        CoScrollPanelConstraints viewConstraints = children[0].constraints;
        viewConstraints.preferredSize = size;
      }
    }
  }

  Stack _buildVerticalView(
      BuildContext context, BoxConstraints constraints, double w) {
    final double maxWidth = constraints.maxWidth == double.infinity
        ? MediaQuery.of(context).size.width
        : constraints.maxWidth;
    final double maxHeight = constraints.maxHeight == double.infinity
        ? MediaQuery.of(context).size.height
        : constraints.maxHeight;

    double top = maxHeight * w;
    double bottom = maxHeight * (1.0 - w);

    BoxConstraints view1Constraints = BoxConstraints(
        minHeight: top,
        maxHeight: top,
        minWidth:
            constraints.maxWidth == double.infinity ? 0 : constraints.maxWidth,
        maxWidth:
            constraints.maxWidth == double.infinity ? 0 : constraints.maxWidth);

    BoxConstraints view2Constraints = BoxConstraints(
        minHeight: bottom,
        maxHeight: bottom,
        minWidth:
            constraints.maxWidth == double.infinity ? 0 : constraints.maxWidth,
        maxWidth:
            constraints.maxWidth == double.infinity ? 0 : constraints.maxWidth);

    List<Widget> children = <Widget>[];

    this.updatePreferredSize(widget.view1, Size(maxWidth, top));
    this.updatePreferredSize(widget.view2, Size(maxWidth, bottom));

    children.add(Positioned(
        top: 0,
        left: 0,
        right: 0,
        height: top,
        child: Container(
          color: Colors.white,
          child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              controller: widget.scrollControllerView1,
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: CoScrollPanelLayout(
                    preferredConstraints: CoScrollPanelConstraints(constraints,
                        widget.view1.componentModel, view1Constraints.biggest),
                    container: null,
                    children: [
                      CoScrollPanelLayoutId(
                          constraints: CoScrollPanelConstraints(
                              constraints,
                              widget.view1.componentModel,
                              view1Constraints.biggest),
                          child: widget.view1)
                    ],
                  ))),
        )));

    children.add(Positioned(
        top: top,
        left: 0,
        right: 0,
        height: bottom,
        child: Container(
          color: Colors.white,
          child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              controller: widget.scrollControllerView2,
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: CoScrollPanelLayout(
                    preferredConstraints: CoScrollPanelConstraints(constraints,
                        widget.view2.componentModel, view2Constraints.biggest),
                    children: [
                      CoScrollPanelLayoutId(
                          constraints: CoScrollPanelConstraints(
                              constraints,
                              widget.view2.componentModel,
                              view2Constraints.biggest),
                          child: widget.view2)
                    ],
                  ))),
        )));

    if (widget.showHandle) {
      children.add(Positioned(
        top: top - widget.gripSize,
        left: 0,
        right: 0,
        bottom: bottom,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onVerticalDragUpdate: (detail) {
            final RenderBox container = context.findRenderObject() as RenderBox;
            final pos = container.globalToLocal(detail.globalPosition);
            if (pos.dy > widget.positionLimit &&
                pos.dy < (container.size.height - widget.positionLimit)) {
              weight.value = pos.dy / container.size.height;
            }
          },
          child: Container(
              color: widget.gripColor,
              child: Center(
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: Container(
                        height: 4,
                        color: widget.handleColor,
                        width: 40,
                      )))),
        ),
      ));
    } else {
      children.add(
        Positioned(
          top: top - widget.gripSize,
          left: 0,
          right: 0,
          bottom: bottom,
          child: Container(
            color: widget.gripColor,
          ),
        ),
      );
    }

    return Stack(
      children: children,
    );
  }

  Widget _buildHorizontalView(
      BuildContext context, BoxConstraints constraints, double w) {
    final double maxWidth = constraints.maxWidth == double.infinity
        ? (MediaQuery.of(context).size.width - widget.positionLimit)
        : constraints.maxWidth;
    final double maxHeight = constraints.maxHeight == double.infinity
        ? MediaQuery.of(context).size.height
        : constraints.maxHeight;

    final double left = maxWidth * w;
    final double right = maxWidth * (1.0 - w);

    BoxConstraints view1Constraints = BoxConstraints(
        minHeight: constraints.maxHeight == double.infinity
            ? 0
            : constraints.maxHeight,
        maxHeight: constraints.maxHeight == double.infinity
            ? 0
            : constraints.maxHeight,
        minWidth: left,
        maxWidth: left);

    BoxConstraints view2Constraints = BoxConstraints(
        minHeight: constraints.maxHeight == double.infinity
            ? 0
            : constraints.maxHeight,
        maxHeight: constraints.maxHeight == double.infinity
            ? 0
            : constraints.maxHeight,
        minWidth: right,
        maxWidth: right);

    List<Widget> children = <Widget>[];

    this.updatePreferredSize(widget.view1, Size(left, maxHeight));
    this.updatePreferredSize(widget.view2, Size(right, maxHeight));

    children.add(Positioned(
      top: 0,
      left: 0,
      right: right,
      bottom: 0,
      child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          controller: widget.scrollControllerView1,
          child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: CoScrollPanelLayout(
                preferredConstraints: CoScrollPanelConstraints(constraints,
                    widget.view1.componentModel, view1Constraints.biggest),
                container: null,
                children: [
                  CoScrollPanelLayoutId(
                      constraints: CoScrollPanelConstraints(
                          constraints,
                          widget.view1.componentModel,
                          view1Constraints.biggest),
                      child: widget.view1)
                ],
              ))),
    ));

    children.add(Positioned(
      top: 0,
      left: left,
      right: 0,
      bottom: 0,
      child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          controller: widget.scrollControllerView2,
          child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: CoScrollPanelLayout(
                preferredConstraints: CoScrollPanelConstraints(constraints,
                    widget.view2.componentModel, view2Constraints.biggest),
                children: [
                  CoScrollPanelLayoutId(
                      constraints: CoScrollPanelConstraints(
                          constraints,
                          widget.view2.componentModel,
                          view2Constraints.biggest),
                      child: widget.view2)
                ],
              ))),
    ));

    if (widget.showHandle) {
      children.add(Positioned(
        top: 0,
        left: left - widget.gripSize,
        right: right,
        bottom: 0,
        child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onVerticalDragUpdate: (detail) {
              final RenderBox container =
                  context.findRenderObject() as RenderBox;
              final pos = container.globalToLocal(detail.globalPosition);
              if (pos.dx > widget.positionLimit &&
                  pos.dx < (container.size.width - widget.positionLimit)) {
                weight.value = pos.dx / container.size.width;
              }
            },
            child: Container(
                color: widget.gripColor,
                child: Center(
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(5.0),
                        child: Container(
                          height: 40,
                          color: widget.handleColor,
                          width: 4,
                        ))))),
      ));
    } else {
      children.add(Positioned(
          top: 0,
          left: left - widget.gripSize,
          right: right,
          bottom: 0,
          child: Container(
            color: widget.gripColor,
          )));
    }
    return Container(
        width: maxWidth,
        height: maxHeight,
        child: Stack(
          children: children,
        ));
  }
}

enum SplitViewMode {
  Vertical,
  Horizontal,
}
