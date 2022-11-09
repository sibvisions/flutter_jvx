import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:universal_io/io.dart';

import '../../../custom/app_manager.dart';
import '../../../custom/custom_component.dart';
import '../../../custom/custom_screen.dart';
import '../../mask/error/message_dialog.dart';
import '../../mask/frame_dialog.dart';
import '../../model/component/component_subscription.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/component/panel/fl_panel_model.dart';
import '../../model/data/subscriptions/data_chunk.dart';
import '../../model/data/subscriptions/data_record.dart';
import '../../model/data/subscriptions/data_subscription.dart';
import '../../model/layout/layout_data.dart';
import '../../model/response/dal_meta_data_response.dart';
import '../command/i_command_service.dart';
import '../service.dart';

/// Defines the base construct of a [IUiService]
/// Used to manage all interactions to and from the ui.
abstract class IUiService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  factory IUiService() => services<IUiService>();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Basically resets the service
  void clear();

  static String getErrorMessage(Object error) {
    if (error is TimeoutException) {
      return "Connection to remote server timed out";
    } else if (error is SocketException) {
      return "Could not connect to remote server";
    } else {
      return error.toString();
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Communication with other services
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Sends [command] to [ICommandService].
  ///
  /// ## Do not use any future functions except await because errors are swallowed!
  /// Alternatively use [ICommandService.sendCommand] to get an unmodified future.
  Future<void> sendCommand(BaseCommand command);

  ///Can be used to handle an async error
  handleAsyncError(Object error, StackTrace stackTrace);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Routing
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Route to meu page
  /// pReplaceRoute - true if the route should replace the route in its history
  /// false if it should add to it
  void routeToMenu({bool pReplaceRoute = false});

  /// Route to work screen page
  void routeToWorkScreen({required String pScreenName, bool pReplaceRoute = false});

  /// Route to settings page
  void routeToSettings({bool pReplaceRoute = false});

  /// Route to Login page
  void routeToLogin({String mode, required Map<String, String?> pLoginProps});

  /// Route to the provided full path, used for routing to offline screens
  void routeToCustom({required String pFullPath});

  /// Gets the current custom manager
  AppManager? getAppManager();

  /// Sets the current custom manager
  void setAppManager(AppManager? pAppManager);

  /// Opens a [Dialog]
  Future<T?> openDialog<T>({
    required WidgetBuilder pBuilder,
    BuildContext? context,
    bool pIsDismissible = true,
    Locale? pLocale,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Meta data management
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns the current menu, if none was found - throws exception
  MenuModel getMenuModel();

  /// Set menu model to be used when opening the menu
  void setMenuModel(MenuModel? pMenuModel);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Management of component models
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns all [FlComponentModel] children of provided id.
  List<FlComponentModel> getChildrenModels(String id);

  /// Returns all [FlComponentModel] descendants of provided id.
  List<FlComponentModel> getDescendantModels(String id);

  /// Returns component model with matching componentId,
  /// if none was found returns null
  FlComponentModel? getComponentModel({required String pComponentId});

  /// Get the screen (top-most-parent)
  FlComponentModel? getComponentByName({required String pComponentName});

  /// Returns the top-most panel if a work screen is open
  FlPanelModel? getComponentByScreenName({required String pScreenLongName});

  /// Returns the top-most panel if a work screen is open
  FlPanelModel? getComponentByClassName({required String pScreenClassName});

  /// Save new components to active components,
  /// used for saving components which have not been previously been rendered.
  void saveNewComponents({required List<FlComponentModel> newModels});

  /// Called when the current workScreen is closed, will delete all relevant data(models, subscriptions,...) from [IUiService]
  void closeScreen({required String pScreenName, required bool pBeamBack});

  /// Gets all children and the children below recursively.
  List<FlComponentModel> getAllComponentsBelow(String id);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // LayoutData management
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Notify component of new [LayoutData].
  void setLayoutPosition({required LayoutData layoutData});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Component registration management
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Register as an active component, callback will be called when model
  void registerAsLiveComponent({required ComponentSubscription pComponentSubscription});

  /// Register to receive a subscriptions of data from a specific dataProvider
  void registerDataSubscription({required DataSubscription pDataSubscription, bool pShouldFetch = true});

  /// Not to be used from ui, only used when components are no l onger to be displayed in UI
  void deleteInactiveComponent({required Set<String> inactiveIds});

  /// Removes all active subscriptions
  void disposeSubscriptions({required Object pSubscriber});

  /// Removes [DataSubscription] from [IUiService]
  void disposeDataSubscription({required Object pSubscriber, String? pDataProvider});

  /// Collects all commands to do to save all editors.
  List<BaseCommand> collectAllEditorSaveCommands(String? pId);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Methods to notify components about changes to themselves
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Notify affected parents that their children changed, should only be used
  /// when parent model hasn't been changed as well.
  void notifyAffectedComponents({required Set<String> affectedIds});

  /// Notify changed live components that their model has changed, will give
  /// them their new model.
  void notifyChangedComponents({required List<FlComponentModel> updatedModels});

  /// Notify all components belonging to [pDataProvider] that their underlying
  /// data may have changed.
  void notifyDataChange({
    required String pDataProvider,
  });

  /// Notify all components belonging to [pDataProvider] that their underlying
  /// meta data may have changed.
  void notifyMetaDataChange({
    required String pDataProvider,
  });

  /// Calls the callback of all subscribed [DataSubscription]s which are subscribed to [pDataProvider]
  void setSelectedData({
    required String pSubId,
    required String pDataProvider,
    required DataRecord? pDataRow,
  });

  /// Calls the callback of all subscribed [DataSubscription]s
  void setChunkData({
    required String pSubId,
    required String pDataProvider,
    required DataChunk pDataChunk,
  });

  void setMetaData({
    required String pSubId,
    required String pDataProvider,
    required DalMetaDataResponse pMetaData,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Custom
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// If this screen beams or sends an open workscreen command first.
  bool usesNativeRouting({required String pScreenLongName});

  /// Gets replace-type screen by screenName
  CustomScreen? getCustomScreen({required String pScreenLongName});

  /// Gets a custom component with given name (ignores screen)
  CustomComponent? getCustomComponent({required String pComponentName});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Unsorted method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Map<String, MessageDialog> getFrames();

  void showFrame({
    required String componentId,
    required MessageDialog pDialog,
  });

  void closeFrame({required String componentId});

  void closeFrames();

  List<FrameDialog> getFrameDialogs();

  void showFrameDialog(FrameDialog pDialog);

  void closeFrameDialog(FrameDialog pDialog);

  void closeFrameDialogs();

  Future<void> saveAllEditors(String? pId, String pReason);

  void saveAllEditorsThen(String? pId, Function? pFunction, String pReason);
}
