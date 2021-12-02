import 'package:flutter_client/src/model/layout/form_layout/form_layout_anchor.dart';

/// The Constraint stores the top, left, bottom and right Anchor for layouting a component
class FormLayoutConstraints {

  /// The top anchor
  final FormLayoutAnchor topAnchor;

  /// The left anchor
  final FormLayoutAnchor leftAnchor;

  /// The bottom anchor
  final FormLayoutAnchor bottomAnchor;

  /// The right anchor
  final FormLayoutAnchor rightAnchor;


  FormLayoutConstraints({
    required this.bottomAnchor,
    required this.leftAnchor,
    required this.rightAnchor,
    required this.topAnchor
  });


}