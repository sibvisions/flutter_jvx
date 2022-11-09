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
  final bool inDrawer;

  const WebMenu({
    Key? key,
    required this.showWebMenu,
    required this.inDrawer,
  }) : super(key: key);

  static WebMenu? maybeOf(BuildContext? context) => context?.findAncestorWidgetOfExactType<WebMenu>();

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
          builder: (context, newValue, child) => _buildMenu(context, newValue),
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

  Widget _buildMenu(BuildContext context, LayoutMode layoutMode) {
    var appStyle = AppStyle.of(context)!.applicationStyle!;
    Color? tileColor = ParseUtil.parseHexColor(appStyle['web.sidemenu.color']) ?? const Color(0xFF3d3d3d);
    Color? groupTextColor = ParseUtil.parseHexColor(appStyle['web.sidemenu.groupColor']) ?? Colors.white;
    Color? textColor = ParseUtil.parseHexColor(appStyle['web.sidemenu.textColor']) ?? Colors.white;
    Color? selectionColor =
        ParseUtil.parseHexColor(appStyle['web.sidemenu.selectionColor']) ?? Theme.of(context).colorScheme.primary;

    Widget menu = ValueListenableBuilder<MenuModel>(
      valueListenable: IUiService().getMenuNotifier(),
      builder: (context, _, child) => AppMenuListGrouped(
        menuModel: IUiService().getMenuModel(),
        layoutMode: layoutMode,
        textStyle: const TextStyle(fontWeight: FontWeight.normal),
        headerColor: groupTextColor,
        onClick: AppMenu.menuItemPressed,
        decreasedDensity: true,
        useAlternativeLabel: true,
      ),
    );

    //Drawer Menu always stays the same size
    if (!widget.inDrawer && layoutMode != LayoutMode.Full) {
      menu = ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 50),
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
              child: AnimatedSize(
                curve: Curves.easeInOut,
                alignment: Alignment.centerLeft,
                duration: const Duration(milliseconds: 120),
                child: menu,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
