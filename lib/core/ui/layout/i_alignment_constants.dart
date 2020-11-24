import 'package:flutter/widgets.dart';

class IAlignmentConstants {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // Left Align for this element.
  static const int ALIGN_LEFT = 0;

  // Center Align for this element. This is used for horizontal and vertical alignment.
  static const int ALIGN_CENTER = 1;

  // Right Align for this element.
  static const int ALIGN_RIGHT = 2;

  // Top Align for this element.
  static const int ALIGN_TOP = 0;

  // Bottom Align for this element.
  static const int ALIGN_BOTTOM = 2;

  // Stretch Align for this element. This is used for horizontal and vertical alignment.
  // If stretching is not possible this constant should have the same result as ALIGN_CENTER
  static const int ALIGN_STRETCH = 3;

  // Default align is for components, that have the possibility to change align independently.
  // DEFAULT means, what ever the component want, else use the direct setting.
  static const int ALIGN_DEFAULT = -1;

  static MainAxisAlignment getMainAxisAlignment(int alignment) {
    switch (alignment) {
      case 0:
        return MainAxisAlignment.start;
      case 1:
        return MainAxisAlignment.center;
      case 2:
        return MainAxisAlignment.end;
      case 3:
        return MainAxisAlignment.spaceBetween;
    }

    return MainAxisAlignment.start;
  }

  static CrossAxisAlignment getCrossAxisAlignment(int alignment) {
    switch (alignment) {
      case 0:
        return CrossAxisAlignment.start;
      case 1:
        return CrossAxisAlignment.center;
      case 2:
        return CrossAxisAlignment.end;
      case 3:
        return CrossAxisAlignment.stretch;
    }

    return CrossAxisAlignment.start;
  }
}
