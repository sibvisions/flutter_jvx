import 'package:flutter_jvx/src/models/layout/layout_data.dart';
import 'package:flutter_jvx/src/models/layout/layout_position.dart';
import 'package:flutter_jvx/src/util/i_clonable.dart';

import 'border_layout.dart';
import 'flow_layout.dart';
import 'form_layout.dart';
import 'grid_layout.dart';

// The states a layout can be in. If a component is dirty, it gets redrawn.
// enum LayoutState { DIRTY, RENDERED } -> Not sure if needed yet. Value was necessary in old system. {current dev branch needs it}

/// Defines the base construct of a [ILayout].
/// It is generally advised to use this class as an interface and not as a superclass.
// Author: Toni Heiss
abstract class ILayout implements ICloneable {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Calculates the constraints and widths and heigths of the children components and those of the [pParent].
  List<LayoutPosition> calculateLayout(LayoutData pParent);

  @override
  ILayout clone();

  /// Returns the correct [ILayout] implementation depending on the data in [pLayout].
  ///
  /// Current implementations are:
  ///
  /// [BorderLayout] , [FormLayout], [FlowLayout], [GridLayout]
  static ILayout? getLayout(String? pLayout, String? pLayoutData) {
    if (pLayout != null) {
      final list = pLayout.split(",");

      switch (list.first) {
        case "BorderLayout":
          return BorderLayout(pLayout);
        case "FormLayout":
          return FormLayout();
        case "GridLayout":
          return GridLayout();
        case "FlowLayout":
          return FlowLayout();
        default:
          return null;
      }
    }

    return null;
  }
}
