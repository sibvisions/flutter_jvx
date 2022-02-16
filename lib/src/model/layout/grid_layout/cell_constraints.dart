import 'package:flutter_client/src/model/layout/margins.dart';

/// Constraints of a cell in a gridLayout
class CellConstraint {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The position on the x-axis
  int gridX;
  /// The position on the y-axis
  int gridY;
  /// The width of the component in grids
  int gridWidth;
  /// The height of the component in grids
  int gridHeight;
  /// The margins of the component
  Margins margins;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Creates a [CellConstraint] instance
  CellConstraint({
    required this.margins,
    required this.gridHeight,
    required this.gridWidth,
    required this.gridX,
    required this.gridY
  });
}