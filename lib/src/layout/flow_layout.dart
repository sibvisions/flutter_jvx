import '../model/layout/layout_data.dart';
import '../model/layout/layout_position.dart';
import 'i_layout.dart';

class FlowLayout extends ILayout {
  @override
  ILayout clone() {
    // TODO: implement clone
    throw UnimplementedError();
  }

  @override
  // TODO: implement listChildsToRedraw
  List<LayoutData> get listChildsToRedraw => throw UnimplementedError();

  @override
  Map<String, LayoutPosition> calculateLayout(LayoutData pParent, List<LayoutData> pChildren) {
    // TODO: implement calculateLayout
    throw UnimplementedError();
  }
}
