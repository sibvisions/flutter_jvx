import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/ui/component/jvx_component.dart';

class GridLayoutConstraints {
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// Class members
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		
		// The position on the x-axis. 
		int	_gridX;

		// The position on the y-axis.
		int	_gridY;

		// The width of the component in grids.
		int _gridWidth;

		// The height of the component in grids.
		int _gridHeight;

		// The specified insets of the component. 
		EdgeInsets _insets;

    JVxComponent comp;

		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// Initialization
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		
		/*
		 * Constructs a new CellConstraint.
		 */
		GridLayoutConstraints()
		{
			GridLayoutConstraints.fromGridPosition(0, 0);
		}

		/*
		 * Constructs a new CellConstraint with the given parameters.
		 * 
		 * @param pGridX the position on the x-axis
		 * @param pGridY the position on the y-axis
		 */
		GridLayoutConstraints.fromGridPosition(int pGridX, int pGridY)
		{
			GridLayoutConstraints.fromGridPositionAndSizeAndInsets(pGridX, pGridY, 1, 1, null);
		}
		
		/*
		 * Constructs a new CellConstraint with the given parameters.
		 * 
		 * @param pGridX the position on the x-axis
		 * @param pGridY the position on the y-axis
		 * @param pWidth the width of the component
		 * @param pHeight the height of the component
		 */
		GridLayoutConstraints.fromGridPositionAndSize(int pGridX, int pGridY, int pWidth, int pHeight)
		{
			GridLayoutConstraints.fromGridPositionAndSizeAndInsets(pGridX, pGridY, pWidth, pHeight, null);
		}

		/*
		 * Constructs a new CellConstraint with the given parameters.
		 * 
		 * @param pGridX the position on the x-axis
		 * @param pGridY the position on the y-axis
		 * @param pGridWidth the width of the component
		 * @param pGridHeight the height of the component
		 * @param pInsets the specified insets
		 */
		GridLayoutConstraints.fromGridPositionAndSizeAndInsets(int pGridX, int pGridY, int pGridWidth, int pGridHeight, EdgeInsets pInsets)
		{ 
			setGridX(pGridX);
			setGridY(pGridY);
			setGridWidth(pGridWidth);
			setGridHeight(pGridHeight);
			setInsets(pInsets);
		}

		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// User-defined methods
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		
		/*
		 * Returns the x-position on the grid.
		 *
		 * @return the x-position
		 */
		int getGridX() {
      return _gridX;
    }

		/*
		 * Sets the x-position on the GridLayout.
		 *
		 * @param pGridX the x-position to set
		 */
		void setGridX(int pGridX)
		{
            if (pGridX < 0)
            {
                throw new RangeError("The grid x must be a positive number.");
            }
            
			_gridX = pGridX;
		}

		/*
		 * Returns the y-position on the GridLayout.
		 *
		 * @return the y-position
		 */
		int getGridY() {
      return _gridY;
    } 

		/*
		 * Sets the y-position on the GridLayout.
		 *
		 * @param pGridY the x-position to set
		 */
		void setGridY(int pGridY)
		{
      if (pGridY < 0)
      {
          throw new RangeError("The grid y must be a positive number.");
      }
            
			_gridY = pGridY;
		}

		/*
		 * Returns the width on the GridLayout.
		 *
		 * @return the width
		 */
		int getGridWidth() {
      return _gridWidth;
    }

		/*
		 * Sets the width on the GridLayout.
		 *
		 * @param pGridWidth the height to set
		 */
		void setGridWidth(int pGridWidth)
		{
      if (pGridWidth <= 0)
      {
          throw new RangeError("The grid width must be a positive number.");
      }

			_gridWidth = pGridWidth;	
		}

		/*
		 * Returns the height on the GridLayout.
		 *
		 * @return the height
		 */
		int getGridHeight() {
      return _gridHeight;
    }

		/*
		 * Sets the height on the GridLayout.
		 *
		 * @param pGridHeight the height to set
		 */
		void setGridHeight(int pGridHeight)
		{
      if (pGridHeight <= 0)
      {
          throw new RangeError("The grid height must be a positive number.");
      }

			_gridHeight = pGridHeight;
		}

		/*
		 * Returns the insets on the GridLayout.
		 *
		 * @return the insets
		 */
		EdgeInsets getInsets() {
      return _insets;
    } 
		
		/*
		 * Sets the width on the GridLayout.
		 *
		 * @param pInsets the insets to set
		 */
		void setInsets(EdgeInsets pInsets)
		{
			if (pInsets == null)
			{
				_insets = new EdgeInsets.all(0);
			}
			else
			{
				_insets = pInsets;
			}
		}
}