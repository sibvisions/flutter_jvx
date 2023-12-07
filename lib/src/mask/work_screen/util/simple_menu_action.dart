import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../flutter_ui.dart';
import '../../../service/config/i_config_service.dart';
import '../../../service/ui/i_ui_service.dart';
import '../../apps/app_overview_page.dart';

class SimpleMenuAction extends StatefulWidget {
  const SimpleMenuAction({Key? key}) : super(key: key);

  @override
  State<SimpleMenuAction> createState() => _SimpleMenuActionState();
}

class _SimpleMenuActionState extends State<SimpleMenuAction> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        if (IConfigService().isSingleAppMode() || !IUiService().canRouteToAppOverview()) {
          IUiService().routeToSettings();
        } else {
          _showMenu(context);
        }
      },
      icon: const FaIcon(
        FontAwesomeIcons.ellipsisVertical,
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                alignment: Alignment.center,
                child: FaIcon(
                  FontAwesomeIcons.gear,
                  color: Theme.of(context).iconTheme.color,
                  size: 20,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text(
                  FlutterUI.translate(
                    "Settings",
                  ),
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 1,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                alignment: Alignment.center,
                child: FaIcon(
                  AppOverviewPage.appsIcon,
                  color: Theme.of(context).iconTheme.color,
                  size: 20,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text(
                  FlutterUI.translate(
                    "Apps",
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 0) {
        IUiService().routeToSettings();
      } else if (value == 1) {
        // Wait for popup menu close, mitigates navigator update bug:
        // https://github.com/flutter/flutter/issues/82437
        Future.delayed(const Duration(milliseconds: 350)).then((_) => IUiService().routeToAppOverview());
      }
    });
  }
}
