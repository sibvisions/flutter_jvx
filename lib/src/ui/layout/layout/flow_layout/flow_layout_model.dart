import '../../../container/co_container_widget.dart';
import '../../i_alignment_constants.dart';
import '../layout_model.dart';

class FlowLayoutModel extends LayoutModel<String> {
  int horizontalAlignment = IAlignmentConstants.ALIGN_CENTER;

  int verticalAlignment = IAlignmentConstants.ALIGN_CENTER;

  int orientation = 0;

  int horizontalComponentAlignment = IAlignmentConstants.ALIGN_CENTER;

  int verticalComponentAlignment = IAlignmentConstants.ALIGN_CENTER;

  bool autoWrap = false;

  FlowLayoutModel.fromLayoutString(
      CoContainerWidget pContainer, String layoutString, String layoutData) {
    updateLayoutString(layoutString);
    container = pContainer;
  }

  @override
  void updateLayoutString(String layoutString) {
    parseFromString(layoutString);

    List<String> parameter = layoutString.split(',');

    orientation = int.parse(parameter[7]);
    horizontalAlignment = int.parse(parameter[8]);
    verticalAlignment = int.parse(parameter[9]);
    horizontalComponentAlignment = int.parse(parameter[10]);
    autoWrap = (parameter[11] == 'true') ? true : false;
    verticalComponentAlignment = horizontalComponentAlignment;

    super.updateLayoutString(layoutString);
  }
}
