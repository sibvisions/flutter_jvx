import 'package:flutter/cupertino.dart';
import 'package:flutter_jvx/src/models/api/custom/jvx_menu.dart';

class JVxMenuItemWidget extends StatelessWidget {
  final JVxMenuItem jVxMenuItem;

  const JVxMenuItemWidget({
    Key? key,
    required this.jVxMenuItem
  }) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return Container(
      width: 182,
      child: (
        GestureDetector(
          child: Text(jVxMenuItem.label),
        )
      ),
    );
  }
}