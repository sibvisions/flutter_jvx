import '../../util/i_clonable.dart';
import '../model/layout/layout_data.dart';
import 'border_layout.dart';
import 'flow_layout.dart';
import 'form_layout.dart';
import 'grid_layout.dart';
import 'split_layout.dart';

// The states a layout can be in. If a component is dirty, it gets redrawn.

/// Defines the base construct of a [ILayout].
/// It is generally advised to use this class as an interface and not as a superclass.
// Author: Toni Heiss
abstract class ILayout implements ICloneable {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Calculates the constraints and widths and heigths of the children components and those of the [pParent].
  void calculateLayout(LayoutData pParent, List<LayoutData> pChildren);

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
          return BorderLayout(layoutString: pLayout);
        case "FormLayout":
          return FormLayout(layoutData: pLayoutData!, layoutString: pLayout);
        case "GridLayout":
          return GridLayout(layoutString: pLayout);
        case "FlowLayout":
          return FlowLayout(layoutString: pLayout);
        case "SplitLayout":
          return SplitLayout();
        default:
          return null;
      }
    }

    return null;
  }
}
