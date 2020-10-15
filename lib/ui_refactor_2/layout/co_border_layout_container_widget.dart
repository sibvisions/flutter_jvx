import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/component_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/container/co_container_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/layout/co_layout.dart';
import 'package:jvx_flutterclient/ui_refactor_2/layout/widgets/co_border_layout_constraint.dart';

import 'widgets/co_border_layout_widget.dart';

class CoBorderLayoutContainerWidget extends StatelessWidget
    with CoLayout<CoBorderLayoutConstraints> {
  Key key = UniqueKey();

  /// the north component.
  ComponentWidget _north;

  /// the south component.
  ComponentWidget _south;

  /// the east component.
  ComponentWidget _east;

  /// the west component.
  ComponentWidget _west;

  /// the center component. */
  ComponentWidget _center;

  CoBorderLayoutContainerWidget(Key key) {
    super.key = key;
  }

  CoBorderLayoutContainerWidget.fromLayoutString(
      CoContainerWidget pContainer, String layoutString, String layoutData) {
    updateLayoutString(layoutString);
    super.container = pContainer;
  }

  @override
  void updateLayoutString(String layoutString) {
    super.updateLayoutString(layoutString);
    parseFromString(layoutString);
  }

  void removeLayoutComponent(ComponentWidget pComponent) {
    if (_center != null &&
        pComponent.componentModel.componentId ==
            _center.componentModel.componentId) {
      if (setState != null)
        setState(() => _center = null);
      else
        _center = null;
    } else if (_north != null &&
        pComponent.componentModel.componentId ==
            _north.componentModel.componentId) {
      if (setState != null)
        setState(() => _north = null);
      else
        _north = null;
    } else if (_south != null &&
        pComponent.componentModel.componentId ==
            _south.componentModel.componentId) {
      if (setState != null)
        setState(() => _south = null);
      else
        _south = null;
    } else if (_east != null &&
        pComponent.componentModel.componentId ==
            _east.componentModel.componentId) {
      if (setState != null)
        setState(() => _east = null);
      else
        _east = null;
    } else if (_west != null &&
        pComponent.componentModel.componentId ==
            _west.componentModel.componentId) {
      if (setState != null)
        setState(() => _west = null);
      else
        _west = null;
    }
  }

  void addLayoutComponent(
      ComponentWidget pComponent, CoBorderLayoutConstraints pConstraints) {
    if (pConstraints == null ||
        pConstraints == CoBorderLayoutConstraints.Center) {
      if (setState != null)
        setState(() => _center = pComponent);
      else
        _center = pComponent;
    } else if (pConstraints == CoBorderLayoutConstraints.North) {
      if (setState != null)
        setState(() => _north = pComponent);
      else
        _north = pComponent;
    } else if (pConstraints == CoBorderLayoutConstraints.South) {
      if (setState != null)
        setState(() => _south = pComponent);
      else
        _south = pComponent;
    } else if (pConstraints == CoBorderLayoutConstraints.East) {
      if (setState != null)
        setState(() => _east = pComponent);
      else
        _east = pComponent;
    } else if (pConstraints == CoBorderLayoutConstraints.West) {
      if (setState != null)
        setState(() => _west = pComponent);
      else
        _west = pComponent;
    } else {
      throw new ArgumentError("cannot add to layout: unknown constraint: " +
          pConstraints.toString());
    }
  }

  CoBorderLayoutConstraints getConstraints(ComponentWidget comp) {
    if (comp?.componentModel?.componentId ==
        _center?.componentModel?.componentId) {
      return CoBorderLayoutConstraints.Center;
    } else if (comp?.componentModel?.componentId ==
        _north?.componentModel?.componentId) {
      return CoBorderLayoutConstraints.North;
    } else if (comp?.componentModel?.componentId ==
        _south?.componentModel?.componentId) {
      return CoBorderLayoutConstraints.South;
    } else if (comp?.componentModel?.componentId ==
        _west?.componentModel?.componentId) {
      return CoBorderLayoutConstraints.West;
    } else if (comp?.componentModel?.componentId ==
        _east?.componentModel?.componentId) {
      return CoBorderLayoutConstraints.East;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        super.setState = setState;

        List<CoBorderLayoutId> children = new List<CoBorderLayoutId>();

        if (_center != null && _center.componentModel.isVisible) {
          children.add(CoBorderLayoutId(
              key: ValueKey(_center.componentModel.componentId),
              child: _center,
              pConstraints: CoBorderLayoutConstraintData(
                  CoBorderLayoutConstraints.Center, _center)));
        }

        if (_north != null && _north.componentModel.isVisible) {
          children.add(CoBorderLayoutId(
              key: ValueKey(_north.componentModel.componentId),
              child: _north,
              pConstraints: CoBorderLayoutConstraintData(
                  CoBorderLayoutConstraints.North, _north)));
        }

        if (_south != null && _south.componentModel.isVisible) {
          children.add(CoBorderLayoutId(
              key: ValueKey(_south.componentModel.componentId),
              child: _south,
              pConstraints: CoBorderLayoutConstraintData(
                  CoBorderLayoutConstraints.South, _south)));
        }

        if (_west != null && _west.componentModel.isVisible) {
          children.add(CoBorderLayoutId(
              key: ValueKey(_west.componentModel.componentId),
              child: _west,
              pConstraints: CoBorderLayoutConstraintData(
                  CoBorderLayoutConstraints.West, _west)));
        }

        if (_east != null && _east.componentModel.isVisible) {
          children.add(CoBorderLayoutId(
              key: ValueKey(_east.componentModel.componentId),
              child: _east,
              pConstraints: CoBorderLayoutConstraintData(
                  CoBorderLayoutConstraints.East, _east)));
        }

        return Container(
            margin: this.margins,
            child: CoBorderLayoutWidget(
                key: key,
                container: container,
                insMargin: margins,
                iHorizontalGap: horizontalGap,
                iVerticalGap: verticalGap,
                children: children));
      },
    );
  }
}
