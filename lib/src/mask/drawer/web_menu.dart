/*
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'package:flutter/material.dart';

import '../../flutter_ui.dart';
import '../../model/menu/menu_model.dart';
import '../../model/response/device_status_response.dart';
import '../../service/ui/i_ui_service.dart';
import '../../util/parse_util.dart';
import '../../util/search_mixin.dart';
import '../menu/list/list_menu.dart';
import '../menu/menu.dart';
import '../state/app_style.dart';

class WebMenu extends StatefulWidget {
  final bool showWebMenu;
  final bool inDrawer;

  const WebMenu({
    super.key,
    required this.showWebMenu,
    required this.inDrawer,
  });

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
          valueListenable: IUiService().layoutMode,
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
    AppStyle appStyle = AppStyle.of(context);
    Color? tileColor = ParseUtil.parseHexColor(appStyle.style(context, 'web.sidemenu.color')) ?? const Color(0xFF3d3d3d);
    Color? groupTextColor = ParseUtil.parseHexColor(appStyle.style(context, 'web.sidemenu.groupColor')) ?? Colors.white;
    Color? textColor = ParseUtil.parseHexColor(appStyle.style(context, 'web.sidemenu.textColor')) ?? Colors.white;
    Color? selectionColor =
        ParseUtil.parseHexColor(appStyle.style(context, 'web.sidemenu.selectionColor')) ?? Theme.of(context).colorScheme.primary;

    final MenuModel originalMenu = IUiService().getMenuModel();
    var menuModel = applyMenuFilter(originalMenu, (item) => item.alternativeLabel ?? item.label);

    Widget menu = Column(
      children: [
        if (originalMenu.count >= 12 && layoutMode != LayoutMode.Small) _buildSearchField(textColor: textColor),
        Expanded(
          child: ListMenu(
            key: const PageStorageKey('WebMenu'),
            menuModel: menuModel,
            onClick: Menu.menuItemPressed,
            onClose: Menu.getCloseScreenAction,
            sticky: layoutMode != LayoutMode.Small,
            layoutMode: layoutMode,
            textStyle: const TextStyle(fontWeight: FontWeight.normal),
            headerColor: groupTextColor,
            decreasedDensity: true,
            useAlternativeLabel: true,
            grouped: true,
          ),
        ),
      ],
    );

    // Drawer Menu always stays the same size
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
    );
  }

  Widget _buildSearchField({required Color textColor}) {
    return SizedBox(
      height: 48,
      child: TextField(
        textAlignVertical: TextAlignVertical.center,
        cursorColor: textColor,
        style: TextStyle(
          fontSize: 20,
          color: textColor,
        ),
        decoration: InputDecoration(
          hintText: FlutterUI.translate("Search"),
          hintStyle: TextStyle(
            color: textColor.withOpacity(0.4),
          ),
          // Needed to keep vertical align centered
          contentPadding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
          focusedBorder: _createSearchBorder(),
          enabledBorder: _createSearchBorder(),
          border: _createSearchBorder(),
          suffixIcon: menuSearchController.text.isNotEmpty
              ? IconButton(
                  tooltip: FlutterUI.translate("Clear"),
                  splashRadius: kToolbarHeight / 2,
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
      ),
    );
  }

  InputBorder _createSearchBorder() {
    return const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.transparent),
    );
  }
}
