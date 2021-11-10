import 'layout_child.dart';

class LayoutParent {
  final String id;
  String layout;
  List<LayoutChild> children;

  LayoutParent({
    required this.id,
    required this.layout,
    required this.children,
  });
}