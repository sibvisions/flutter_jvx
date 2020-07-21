import 'package:flutter/widgets.dart';
import '../container/i_container.dart';
import '../component/i_component.dart';
import '../component/component.dart';
import 'widgets/co_grid_layout.dart';
import 'co_layout.dart';
import 'widgets/co_grid_layout_constraint.dart';

class CoGridLayout extends CoLayout<String> {
  // The number of rows.
  int rows = 1;

  // The number of columns.
  int columns = 1;

  /// stores all constraints. */
  Map<Component, String> _constraintMap = <Component, String>{};

  CoGridLayout(Key key) : super(key);

  @override
  CoGridLayout.fromLayoutString(
      IContainer pContainer, String layoutString, String layoutData)
      : super.fromLayoutString(pContainer, layoutString, layoutData) {
    updateLayoutString(layoutString);
  }

  void updateLayoutString(String layoutString) {
    super.updateLayoutString(layoutString);
    parseFromString(layoutString);
    List<String> parameter = layoutString?.split(",");

    rows = int.parse(parameter[7]);
    columns = int.parse(parameter[8]);
  }

  void addLayoutComponent(IComponent pComponent, String pConstraint) {
    if (pConstraint == null || pConstraint.isEmpty) {
      throw new ArgumentError(
          "Constraint " + pConstraint.toString() + " is not allowed!");
    } else {
      _constraintMap.putIfAbsent(pComponent, () => pConstraint);
    }
  }

  void removeLayoutComponent(IComponent pComponent) {
    _constraintMap.removeWhere((c, s) =>
        c.componentId.toString() == pComponent.componentId.toString());
  }

  @override
  String getConstraints(IComponent comp) {
    return _constraintMap[comp];
  }

  CoGridLayoutConstraints getConstraintsFromString(String pConstraints) {
    List<String> constr = pConstraints.split(";");

    if (constr.length == 5) {
      int gridX = int.tryParse(constr[0]);
      int gridY = int.tryParse(constr[1]);
      int gridHeight = int.tryParse(constr[2]);
      int gridWidth = int.tryParse(constr[3]);
      EdgeInsets ins = EdgeInsets.zero;

      if (constr[4].length > 0) {
        List<String> insData = constr[4].split(",");

        if (insData.length == 4) {
          double left = int.tryParse(insData[0]).toDouble();
          double top = int.tryParse(insData[1]).toDouble();
          double right = int.tryParse(insData[2]).toDouble();
          double bottom = int.tryParse(insData[3]).toDouble();

          ins = EdgeInsets.fromLTRB(left, top, right, bottom);
        }
      }

      if (gridX != null &&
          gridY != null &&
          gridHeight != null &&
          gridWidth != null) {
        return CoGridLayoutConstraints.fromGridPositionAndSizeAndInsets(
            gridX, gridY, gridHeight, gridWidth, ins);
      }
    }

    return null;
  }

  Widget getWidget() {
    List<CoGridLayoutConstraintData> children =
        new List<CoGridLayoutConstraintData>();

    this._constraintMap.forEach((k, v) {
      if (k.isVisible) {
        CoGridLayoutConstraints constraint = this.getConstraintsFromString(v);

        if (constraint != null) {
          constraint.comp = k;
          children.add(new CoGridLayoutConstraintData(
              child: k.getWidget(), id: constraint));
        }
      }
    });

    return Container(
        child: CoGridLayoutWidget(
      key: key,
      children: children,
      rows: rows,
      columns: columns,
      margins: margins,
      horizontalGap: horizontalGap,
      verticalGap: verticalGap,
    ));
  }
}
