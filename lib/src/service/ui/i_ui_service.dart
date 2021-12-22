import 'dart:async';

import '../../../util/type_def/callback_def.dart';
import '../../model/command/base_command.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/layout/layout_data.dart';
import '../../model/layout/layout_position.dart';
import '../../model/menu/menu_model.dart';
import '../../model/routing/route_to_menu.dart';
import '../../model/routing/route_to_work_screen.dart';
import '../command/i_command_service.dart';

/// Defines the base construct of a [IUiService]
/// Used to manage all interactions to and from the ui.
// Author: Michael Schober
abstract class IUiService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Sends [command] to [ICommandService]
  void sendCommand(BaseCommand command);

  /// Sends out [RouteToMenu] event on routeChangeStream,
  /// provided [menuModel] will be displayed and saved.
  void routeToMenu(MenuModel menuModel);

  /// Sends out [RouteToWorkScreen] event on routeChangeStream.
  /// provided [FlComponentModel]s will be displayed and saved.
  void routeToWorkScreen(List<FlComponentModel> screenComponents);

  /// Returns broadcast [Stream] on which routing events will take place.
  Stream getRouteChangeStream();

  /// Returns all [FlComponentModel] children of provided id.
  List<FlComponentModel> getChildrenModels(String id);

  /// Register as an active Component, callback will be called when model changes or children should be rebuilt.
  void registerAsLiveComponent({required String id, required ComponentCallback callback});

  /// Notify affected Parents that their children changed, should only be used when parent model hasn't been changed as well.
  void notifyAffectedComponents({required Set<String> affectedIds});

  /// Notify changed Live components that their model has changed, will give them their new model.
  void notifyChangedComponents({required List<FlComponentModel> updatedModels});

  /// Save new Components to active components, used for saving components which have not been previously been rendered.
  void saveNewComponents({required List<FlComponentModel> newModels});

  /// Deletes unused component models from local cache.
  void deleteInactiveComponent({required Set<String> inactiveIds});

  /// Notify component of new [LayoutPosition].
  void setLayoutPosition({required String id, required LayoutData layoutData});
}
