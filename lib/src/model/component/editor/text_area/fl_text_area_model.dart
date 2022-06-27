import '../../../layout/alignments.dart';
import '../text_field/fl_text_field_model.dart';

class FlTextAreaModel extends FlTextFieldModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlTextAreaModel() : super() {
    rows = 5;
    verticalAlignment = VerticalAlignment.TOP;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlTextAreaModel get defaultModel => FlTextAreaModel();
}
