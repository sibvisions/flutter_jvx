import 'package:flutter/material.dart';

import '../../../component/component_widget.dart';
import '../../../container/co_container_widget.dart';
import '../../widgets/co_grid_layout_constraint.dart';
import '../layout_model.dart';

class GridLayoutModel extends LayoutModel<String> {
  int rows = 1;

  int columns = 1;

  GridLayoutModel.fromLayoutString(
      CoContainerWidget pContainer, String layoutString, String layoutData) {
    updateLayoutString(layoutString);
    container = pContainer;
  }

  @override
  void updateLayoutString(String layoutString) {
    parseFromString(layoutString);
    List<String> parameter = layoutString.split(',');

    rows = int.parse(parameter[7]);
    columns = int.parse(parameter[8]);

    super.updateLayoutString(layoutString);
  }

  @override
  void addLayoutComponent(ComponentWidget pComponent, String pConstraint) {
    if (pConstraint.isEmpty) {
      throw new ArgumentError('Constraint is not allowed!');
    } else {
      super.addLayoutComponent(pComponent, pConstraint);
    }
  }

  CoGridLayoutConstraints? getConstraintsFromString(String pConstraints) {
    List<String> constr = pConstraints.split(";");

    if (constr.length == 5) {
      int? gridX = int.tryParse(constr[0]);
      int? gridY = int.tryParse(constr[1]);
      int? gridHeight = int.tryParse(constr[2]);
      int? gridWidth = int.tryParse(constr[3]);
      EdgeInsets ins = EdgeInsets.zero;

      if (constr[4].length > 0) {
        List<String> insData = constr[4].split(",");

        if (insData.length == 4) {
          double? left = int.tryParse(insData[0])?.toDouble();
          double? top = int.tryParse(insData[1])?.toDouble();
          double? right = int.tryParse(insData[2])?.toDouble();
          double? bottom = int.tryParse(insData[3])?.toDouble();

          ins =
              EdgeInsets.fromLTRB(left ?? 0, top ?? 0, right ?? 0, bottom ?? 0);
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
}
