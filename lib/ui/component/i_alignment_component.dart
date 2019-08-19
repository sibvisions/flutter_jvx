
abstract class IAlignmentComponent
{
	///~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	/// Constants
	///~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	/// Left Align for this element.
	static final int	alignLeft = 0;

	/// Center Align for this element. This is used for horizontal and vertical alignment.
	static final int	alignCenter	= 1;

	/// Right Align for this element.
  static final int	alignRight		= 2;

	/// Top Align for this element.
	static final int	alignTop		= 0;

	/// Bottom Align for this element.
	static final int	alignBottom	= 2;

	/// Stretch Align for this element. This is used for horizontal and vertical alignment. 
	///  If stretching is not possible this constant should have the same result as ALIGN_CENTER */
	static final int	alignStretch	= 3;

	/// Default align is for components, that have the possibility to change align independently. 
	///  DEFAULT means, what ever the component want, else use the direct setting. */
	static final int	alignDefault	= -1;

  int horizontalAlignment;

  int verticalAlignment;

}	