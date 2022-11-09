import 'package:flutter/material.dart';

import '../../../flutter_jvx.dart';
import '../../../services.dart';
import '../../../util/parse_util.dart';
import '../../model/menu/menu_model.dart';
import '../../model/response/device_status_response.dart';
import '../../util/search_mixin.dart';
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

class _WebMenuState extends State<WebMenu> with SingleTickerProviderStateMixin, SearchMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  final TextStyle boldStyle = const TextStyle(
    fontWeight: FontWeight.bold,
  );

  late AnimationController animationController;

  @override
  void initState() {
    super.initState();

    isMenuSearchEnabled = true;

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
          builder: (context, layoutMode, child) {
            return ValueListenableBuilder<MenuModel>(
              valueListenable: IUiService().getMenuNotifier(),
              builder: (context, _, child) => _buildMenu(context, layoutMode),
            );
          },
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

    final MenuModel originalMenu = IUiService().getMenuModel();
    var menuModel = applyMenuFilter(originalMenu, (item) => item.alternativeLabel ?? item.label);

    Widget menu = Column(
      children: [
        if (originalMenu.count > 10 && layoutMode != LayoutMode.Small) _buildSearchField(textColor: textColor),
        Expanded(
          child: AppMenuListGrouped(
            menuModel: menuModel,
            layoutMode: layoutMode,
            textStyle: const TextStyle(fontWeight: FontWeight.normal),
            headerColor: groupTextColor,
            onClick: AppMenu.menuItemPressed,
            decreasedDensity: true,
            useAlternativeLabel: true,
          ),
        ),
      ],
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

  Widget _buildSearchField({required Color textColor}) {
    return TextField(
      textAlignVertical: TextAlignVertical.center,
      cursorColor: textColor,
      style: TextStyle(
        fontSize: 20,
        color: textColor,
      ),
      decoration: InputDecoration(
        hintText: FlutterJVx.translate("Search"),
        focusedBorder: _createSearchBorder(),
        enabledBorder: _createSearchBorder(),
        border: _createSearchBorder(),
        suffixIcon: menuSearchController.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  menuSearchController.clear();
                  setState(() {});
                },
                icon: Icon(
                  Icons.clear,
                  size: 20,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              )
            : const SizedBox.shrink(),
      ),
      controller: menuSearchController,
    );
  }

  InputBorder _createSearchBorder() {
    return const OutlineInputBorder(
      borderSide: BorderSide(width: 3, color: Colors.transparent),
    );
  }
}
