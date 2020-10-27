import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/component_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/container/co_container_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/layout/new_layout/layout_helper.dart';
import 'package:jvx_flutterclient/ui_refactor_2/layout/new_layout/layout_key_manager.dart';
import 'package:jvx_flutterclient/ui_refactor_2/layout/widgets/co_border_layout_constraint.dart';
import 'package:jvx_flutterclient/ui_refactor_2/layout/widgets/co_border_layout_widget.dart';

class CoBorderLayoutContainerWidget extends StatelessWidget {
  final CoContainerWidget container;

  /// the north component.
  final ComponentWidget north;

  /// the south component.
  final ComponentWidget south;

  /// the east component.
  final ComponentWidget east;

  /// the west component.
  final ComponentWidget west;

  /// the center component. */
  final ComponentWidget center;

  final EdgeInsets margins;
  final int horizontalGap;
  final int verticalGap;

  final LayoutKeyManager keyManager;

  CoBorderLayoutContainerWidget({
    Key key,
    this.north,
    this.south,
    this.east,
    this.west,
    this.center,
    this.container,
    this.keyManager,
    String layoutString,
  })  : margins = LayoutHelper.getMarginsFromString(layoutString),
        horizontalGap = LayoutHelper.getHorizontalGapFromString(layoutString),
        verticalGap = LayoutHelper.getVerticalGapFromString(layoutString),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    List<CoBorderLayoutId> children = <CoBorderLayoutId>[];

    if (center != null && center.componentModel.isVisible) {
      Key key = this
          .keyManager
          .getKeyByComponentId(center.componentModel.componentId);

      if (key == null) {
        key = this.keyManager.createKey(center.componentModel.componentId);
        this.keyManager.keys[center.componentModel.componentId] = key;
      }

      children.add(CoBorderLayoutId(
          key: key,
          child: center,
          pConstraints: CoBorderLayoutConstraintData(
              CoBorderLayoutConstraints.Center, center)));
    }

    if (north != null && north.componentModel.isVisible) {
      Key key =
          this.keyManager.getKeyByComponentId(north.componentModel.componentId);

      if (key == null) {
        key = this.keyManager.createKey(north.componentModel.componentId);
        this.keyManager.keys[north.componentModel.componentId] = key;
      }
      children.add(CoBorderLayoutId(
          key: key,
          child: north,
          pConstraints: CoBorderLayoutConstraintData(
              CoBorderLayoutConstraints.North, north)));
    }

    if (south != null && south.componentModel.isVisible) {
      Key key =
          this.keyManager.getKeyByComponentId(south.componentModel.componentId);

      if (key == null) {
        key = this.keyManager.createKey(south.componentModel.componentId);
        this.keyManager.keys[south.componentModel.componentId] = key;
      }
      children.add(CoBorderLayoutId(
          key: key,
          child: south,
          pConstraints: CoBorderLayoutConstraintData(
              CoBorderLayoutConstraints.South, south)));
    }

    if (west != null && west.componentModel.isVisible) {
      Key key =
          this.keyManager.getKeyByComponentId(west.componentModel.componentId);

      if (key == null) {
        key = this.keyManager.createKey(west.componentModel.componentId);
        this.keyManager.keys[west.componentModel.componentId] = key;
      }
      children.add(CoBorderLayoutId(
          key: key,
          child: west,
          pConstraints: CoBorderLayoutConstraintData(
              CoBorderLayoutConstraints.West, west)));
    }

    if (east != null && east.componentModel.isVisible) {
      Key key =
          this.keyManager.getKeyByComponentId(east.componentModel.componentId);

      if (key == null) {
        key = this.keyManager.createKey(east.componentModel.componentId);
        this.keyManager.keys[east.componentModel.componentId] = key;
      }
      children.add(CoBorderLayoutId(
          key: key,
          child: east,
          pConstraints: CoBorderLayoutConstraintData(
              CoBorderLayoutConstraints.East, east)));
    }

    return Container(
      margin: this.margins,
      child: CoBorderLayoutWidget(
        key: key,
        container: this.container,
        insMargin: this.margins,
        iHorizontalGap: this.horizontalGap,
        iVerticalGap: this.verticalGap,
        children: children,
      ),
    );
  }
}
