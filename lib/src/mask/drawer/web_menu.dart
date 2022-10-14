import 'package:flutter/material.dart';

import '../../../services.dart';
import '../../../util/parse_util.dart';
import '../../model/menu/menu_model.dart';
import '../../model/response/device_status_response.dart';
import '../menu/app_menu.dart';
import '../menu/list/app_menu_list_grouped.dart';
import '../state/app_style.dart';

class WebMenu extends StatefulWidget {
  final bool showWebMenu;

  final void Function() onSettingsPressed;
  final void Function() onChangePasswordPressed;
  final void Function() onLogoutPressed;

  const WebMenu({
    Key? key,
    this.showWebMenu = true,
    required this.onSettingsPressed,
    required this.onChangePasswordPressed,
    required this.onLogoutPressed,
  }) : super(key: key);

  @override
  State<WebMenu> createState() => _WebMenuState();
}

class _WebMenuState extends State<WebMenu> with SingleTickerProviderStateMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  final TextStyle boldStyle = const TextStyle(
    fontWeight: FontWeight.bold,
  );

  late AnimationController animationController;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      value: widget.showWebMenu ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 246),
      vsync: this,
    )..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      widthFactor: animationController.value,
      child: RepaintBoundary(
        child: ValueListenableBuilder<LayoutMode>(
          valueListenable: IConfigService().getLayoutMode(),
          builder: (context, value, child) => _buildMenu(context, value),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(WebMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showWebMenu != oldWidget.showWebMenu) {
      animationController.fling(velocity: widget.showWebMenu ? 1.0 : -1.0);
    }
  }

  Widget _buildMenu(BuildContext context, LayoutMode value) {
    var appStyle = AppStyle.of(context)!.applicationStyle!;
    Color? tileColor = ParseUtil.parseHexColor(appStyle['web.sidemenu.color']) ?? const Color(0xFF3d3d3d);
    Color? groupTextColor = ParseUtil.parseHexColor(appStyle['web.sidemenu.groupColor']) ?? Colors.white;
    Color? textColor = ParseUtil.parseHexColor(appStyle['web.sidemenu.textColor']) ?? Colors.white;
    Color? selectionColor =
        ParseUtil.parseHexColor(appStyle['web.sidemenu.selectionColor']) ?? Theme.of(context).colorScheme.primary;

    MenuModel menuModel = IUiService().getMenuModel();
    Widget menu = AppMenuListGrouped(
      menuModel: menuModel,
      layoutMode: value,
      textStyle: const TextStyle(fontWeight: FontWeight.normal),
      headerColor: groupTextColor,
      onClick: AppMenu.menuItemPressed,
    );
    if (value != LayoutMode.Full) {
      menu = SizedBox(
        width: 50,
        child: menu,
      );
    }

    return ListTileTheme.merge(
      tileColor: tileColor,
      textColor: textColor,
      iconColor: textColor,
      selectedColor: selectionColor,
      selectedTileColor: tileColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
      horizontalTitleGap: 0,
      child: Theme(
        data: Theme.of(context).copyWith(
          bottomAppBarColor: tileColor,
        ),
        child: IconTheme.merge(
          data: const IconThemeData(size: 16),
          child: DividerTheme(
            data: DividerTheme.of(context).copyWith(
              color: tileColor,
            ),
            child: Material(
              color: tileColor,
              child: menu,
            ),
          ),
        ),
      ),
    );
  }
}
