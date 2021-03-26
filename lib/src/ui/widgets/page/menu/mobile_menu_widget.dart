import 'package:flutter/material.dart';
import 'package:flutterclient/src/models/api/requests/menu_request.dart';
import 'package:flutterclient/src/models/state/routes/arguments/open_screen_page_arguments.dart';
import 'package:flutterclient/src/services/local/local_database/i_offline_database_provider.dart';
import 'package:flutterclient/src/services/local/local_database/offline_database.dart';
import 'package:flutterclient/src/ui/util/error/error_handler.dart';
import 'package:flutterclient/src/ui/util/inherited_widgets/shared_preferences_provider.dart';
import 'package:flutterclient/src/ui/widgets/page/menu/dialogs/sync_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../injection_container.dart';
import '../../../../models/api/requests/open_screen_request.dart';
import '../../../../models/api/response_objects/menu/menu_item.dart';
import '../../../../models/state/app_state.dart';
import '../../../../models/state/routes/routes.dart';
import '../../../../services/remote/cubit/api_cubit.dart';
import '../../../../util/color/color_extension.dart';
import '../../../../util/translation/app_localizations.dart';
import '../../drawer/menu_drawer_widget.dart';
import 'mobile/menu_grid_view_widget.dart';
import 'mobile/menu_list_view_widget.dart';

class MobileMenuWidget extends StatefulWidget {
  final AppState appState;
  final Function onLogoutPressed;
  final List<MenuItem> menuItems;
  final bool listMenuItemsInDrawer;

  const MobileMenuWidget(
      {Key? key,
      required this.appState,
      required this.onLogoutPressed,
      required this.menuItems,
      this.listMenuItemsInDrawer = true})
      : super(key: key);

  @override
  _MobileMenuWidgetState createState() => _MobileMenuWidgetState();
}

class _MobileMenuWidgetState extends State<MobileMenuWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  void _onPressedMenuItem(MenuItem menuItem) {
    if (widget.appState.screenManager.hasScreen(menuItem.componentId) &&
        !widget.appState.screenManager
            .findScreen(menuItem.componentId)!
            .configuration
            .withServer) {
      Navigator.of(context).pushNamed(Routes.openScreen,
          arguments: OpenScreenPageArguments(
              screen: widget.appState.screenManager
                  .findScreen(menuItem.componentId)!));
    } else {
      OpenScreenRequest request = OpenScreenRequest(
          clientId: widget.appState.applicationMetaData!.clientId,
          componentId: menuItem.componentId);

      sl<ApiCubit>().openScreen(request);
    }
  }

  Widget _getMobileMenuWidget() {
    if (widget.appState.applicationStyle?.menuMode != null) {
      switch (widget.appState.applicationStyle!.menuMode) {
        case 'grid':
          return MenuGridViewWidget(
              items: widget.menuItems,
              groupedMenuMode: false,
              onPressed: _onPressedMenuItem,
              appState: widget.appState);
        case 'grid_grouped':
          return MenuGridViewWidget(
              items: widget.menuItems,
              groupedMenuMode: true,
              onPressed: _onPressedMenuItem,
              appState: widget.appState);
        case 'list':
          return MenuListViewWidget(
              menuItems: widget.menuItems,
              groupedMenuMode: false,
              onPressed: _onPressedMenuItem,
              appState: widget.appState);
        case 'list_grouped':
          return MenuListViewWidget(
              menuItems: widget.menuItems,
              groupedMenuMode: true,
              onPressed: _onPressedMenuItem,
              appState: widget.appState);
        default:
          return MenuGridViewWidget(
              items: widget.menuItems,
              groupedMenuMode: false,
              onPressed: _onPressedMenuItem,
              appState: widget.appState);
      }
    } else {
      return Container();
    }
  }

  Widget _getOfflineIcon() {
    return IconButton(
        icon: FaIcon(FontAwesomeIcons.broadcastTower),
        onPressed: () async {
          bool shouldSync = await showSyncDialog(context);

          if (shouldSync) {
            bool syncSuccess =
                await sl<IOfflineDatabaseProvider>().syncOnline(context);

            if (syncSuccess) {
              await (sl<IOfflineDatabaseProvider>() as OfflineDatabase)
                  .cleanupDatabase();

              setState(() {
                widget.appState.isOffline = false;
              });

              SharedPreferencesProvider.of(context)!.manager.isOffline = false;

              sl<ApiCubit>().menu(MenuRequest(
                  clientId: widget.appState.applicationMetaData!.clientId));
            } else {
              if ((sl<IOfflineDatabaseProvider>() as OfflineDatabase)
                      .responseError !=
                  null) {
                ErrorHandler.handleError(
                    ApiError(
                        failure:
                            (sl<IOfflineDatabaseProvider>() as OfflineDatabase)
                                .responseError!),
                    context);
              }
            }
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        endDrawer: MenuDrawerWidget(
          appState: widget.appState,
          menuItems: widget.menuItems,
          onMenuItemPressed: _onPressedMenuItem,
          onLogoutPressed: () => widget.onLogoutPressed(),
          onSettingsPressed: () =>
              Navigator.of(context).pushNamed(Routes.settings),
          listMenuItems: widget.listMenuItemsInDrawer,
          title: '',
        ),
        appBar: AppBar(
          actionsIconTheme:
              IconThemeData(color: Theme.of(context).primaryColor.textColor()),
          title: Text(
            AppLocalizations.of(context)!.text('Menu'),
            style: TextStyle(color: Theme.of(context).primaryColor.textColor()),
          ),
          actions: [
            if (widget.appState.isOffline) _getOfflineIcon(),
            IconButton(
                icon: FaIcon(FontAwesomeIcons.ellipsisV),
                onPressed: () {
                  if (scaffoldKey.currentState != null)
                    scaffoldKey.currentState!.openEndDrawer();
                })
          ],
        ),
        body: _getMobileMenuWidget());
  }
}
