import 'i_layout.dart';
import '../model/layout/layout_data.dart';
import '../model/layout/layout_position.dart';

class FlowLayout extends ILayout {
  @override
  Map<String, LayoutPosition> calculateLayout(LayoutData pParent) {
    // TODO: implement calculateLayout
    throw UnimplementedError();
  }

  @override
  ILayout clone() {
    // TODO: implement clone
    throw UnimplementedError();
  }

  @override
  // TODO: implement listChildsToRedraw
  List<LayoutData> get listChildsToRedraw => throw UnimplementedError();
}
