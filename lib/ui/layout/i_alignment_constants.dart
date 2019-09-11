class IAlignmentConstants {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	// Constants
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	// Left Align for this element. 
	static final int ALIGN_LEFT		= 0;

	// Center Align for this element. This is used for horizontal and vertical alignment.
	static final int	ALIGN_CENTER	= 1;

	// Right Align for this element. 
	static final int	ALIGN_RIGHT		= 2;

	// Top Align for this element. 
	static final int	ALIGN_TOP		= 0;

	// Bottom Align for this element.
	static final int	ALIGN_BOTTOM	= 2;

	// Stretch Align for this element. This is used for horizontal and vertical alignment. 
	// If stretching is not possible this constant should have the same result as ALIGN_CENTER
	static final int	ALIGN_STRETCH	= 3;

	// Default align is for components, that have the possibility to change align independently. 
	// DEFAULT means, what ever the component want, else use the direct setting.
	static final int	ALIGN_DEFAULT	= -1;
}