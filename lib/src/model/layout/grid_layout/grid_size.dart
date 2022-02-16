/// Describes the number of rows and columns a grid has
class GridSize {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Number of rows the grid has.
  int rows;
  /// Number of columns the grid has.
  int columns;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  GridSize({
    required this.columns,
    required this.rows
  });

  GridSize.fromList({required List<String> list}) :
    rows = int.parse(list[0]),
    columns = int.parse(list[1]);
}