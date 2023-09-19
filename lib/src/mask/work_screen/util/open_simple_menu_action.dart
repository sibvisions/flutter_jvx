import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../flutter_ui.dart';

class OpenSimpleMenuAction extends StatefulWidget {
  const OpenSimpleMenuAction({Key? key}) : super(key: key);

  @override
  State<OpenSimpleMenuAction> createState() => _OpenSimpleMenuActionState();
}

class _OpenSimpleMenuActionState extends State<OpenSimpleMenuAction> {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => IconButton(
        onPressed: () {
          final RenderBox button = context.findRenderObject() as RenderBox;
          final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
          final RelativeRect position = RelativeRect.fromSize(
            Rect.fromPoints(
              button.localToGlobal(Offset.zero, ancestor: overlay),
              button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
            ),
            overlay.size,
          );

          showMenu(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            position: position,
            items: [
              PopupMenuItem(
                value: 0,
                child: Text(
                  FlutterUI.translate("Settings"),
                ),
              ),
              PopupMenuItem(
                value: 1,
                child: Text(
                  FlutterUI.translate("Apps"),
                ),
              ),
            ],
          );
        },
        icon: FaIcon(
          FontAwesomeIcons.ellipsisVertical,
        ),
      ),
    );
  }
}
