import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/src/model/component/panel/fl_panel_model.dart';
import 'package:flutter_client/src/model/data/chunk/chunk_data.dart';
import 'package:flutter_client/src/model/data/chunk/chunk_subscription.dart';
import 'package:flutter_client/src/model/menu/menu_model.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../util/type_def/callback_def.dart';
import '../../model/command/base_command.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/data/column_definition.dart';
import '../../model/layout/layout_data.dart';
import '../command/i_command_service.dart';

/// Definition of the callback for the QR-scanner
typedef QRCallback = void Function(Barcode qrValue);

/// Defines the base construct of a [IUiService]
/// Used to manage all interactions to and from the ui.
abstract class IUiService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Communication with other services
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Sends [command] to [ICommandService]
  void sendCommand(BaseCommand command);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Routing
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Route to meu page
  /// pReplaceRoute - true if the route should replace the route in its history
  /// false if it should add to it
  void routeToMenu({bool pReplaceRoute = false});

  /// Route to work screen page
  void routeToWorkScreen();

  /// Route to settings page
  void routeToSettings();

  /// Route to Login page
  void routeToLogin({String? mode});

  /// Sets the buildContext from the current [BeamLocation],
  /// used when server dictates location
  void setRouteContext({required BuildContext pContext});

  /// Opens a [Dialog], the future will complete if the dialog is closed by an
  /// action
  Future<T?> openDialog<T>({required Widget pDialogWidget, required bool pIsDismissible});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Meta data management
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns the current menu, if none was found - throws exception
  MenuModel getMenuModel();

  /// Set menu model to be used when opening the menu
  void setMenuModel({required MenuModel pMenuModel});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Management of component models
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns all [FlComponentModel] children of provided id.
  List<FlComponentModel> getChildrenModels(String id);

  /// Returns component model with matching componentId,
  /// if none was found returns null
  FlComponentModel? getComponentModel({required String pComponentId});

  /// Save new components to active components,
  /// used for saving components which have not been previously been rendered.
  void saveNewComponents({required List<FlComponentModel> newModels});

  /// Get the screen (top-most-parent)
  FlComponentModel getScreenByName({required String pScreenName});

  /// Returns the model of the current open screen, will throw exception if
  /// no screen is open
  FlPanelModel getOpenScreen();

  void closeScreen({required String pScreenName});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // LayoutData management
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Notify component of new [LayoutData].
  void setLayoutPosition({required LayoutData layoutData});

  /// Returns a list of layoutData from all children.
  List<LayoutData> getChildrenLayoutData({required String pParentId});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Component registration management
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Register as an active component, callback will be called when model
  /// changes or children should be rebuilt.
  void registerAsLiveComponent({required String id, required ComponentCallback callback});

  /// Register a an active component in need of data from a dataBook.
  void registerAsDataComponent({
    required String pDataProvider,
    required Function pCallback,
    required Function pColumnDefinitionCallback,
    required String pComponentId,
    required String pColumnName,
  });

  /// Register to receive a chunk of data from a specific dataProvider
  void registerDataChunk({required ChunkSubscription chunkSubscription});

  /// Deletes unused component models from local cache and disposes of all their
  /// active subscriptions.
  void deleteInactiveComponent({required Set<String> inactiveIds});

  /// Removes all active subscriptions as the wrapper has been disposed
  void disposeSubscriptions({required String pComponentId});

  /// Deletes the callback of the registered component on the dataProvider
  void unRegisterDataComponent({required String pComponentId, required String pDataProvider});

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
  void notifyDataChange({required String pDataProvider});

  /// Calls the callback function of the component with [pData]
  void setSelectedData({
    required String pDataProvider,
    required String pComponentId,
    required String pColumnName,
    required dynamic pData,
  });

  /// Calls the callback function of the component with [pColumnDefinition]
  void setSelectedColumnDefinition({
    required String pDataProvider,
    required String pComponentId,
    required String pColumnName,
    required ColumnDefinition pColumnDefinition,
  });

  /// Calls the callback function with [pChunkData] for provided [pId] and [pDataProvider]
  void setChunkData({
    required ChunkData pChunkData,
    required String pId,
    required String pDataProvider,
  });
}
