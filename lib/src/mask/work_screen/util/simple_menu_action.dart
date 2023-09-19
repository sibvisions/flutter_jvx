import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../flutter_ui.dart';
import '../../../service/config/i_config_service.dart';
import '../../../service/ui/i_ui_service.dart';

class SimpleMenuAction extends StatefulWidget {
  const SimpleMenuAction({Key? key}) : super(key: key);

  @override
  State<SimpleMenuAction> createState() => _SimpleMenuActionState();
}

class _SimpleMenuActionState extends State<SimpleMenuAction> {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => IconButton(
        onPressed: () {
          if (IConfigService().singleAppMode.value) {
            IUiService().routeToSettings();
          } else {
            _showMenu(context);
          }
        },
        icon: const FaIcon(
          FontAwesomeIcons.ellipsisVertical,
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
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
    ).then((value) {
      if (value == 0) {
        IUiService().routeToSettings();
      } else if (value == 1) {
        IUiService().routeToAppOverview();
      }
    });
  }
}
