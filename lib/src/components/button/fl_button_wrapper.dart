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

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:action_slider/action_slider.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../flutter_ui.dart';
import '../../mask/error/error_dialog.dart';
import '../../model/command/api/press_button_command.dart';
import '../../model/command/api/set_values_command.dart';
import '../../model/command/base_command.dart';
import '../../model/command/config/save_download_command.dart';
import '../../model/command/ui/set_focus_command.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/data/subscriptions/data_record.dart';
import '../../model/data/subscriptions/data_subscription.dart';
import '../../routing/locations/main_location.dart';
import '../../service/api/shared/api_object_property.dart';
import '../../service/command/i_command_service.dart';
import '../../service/storage/i_storage_service.dart';
import '../../service/ui/i_ui_service.dart';
import '../../util/auth/auth_service.dart';
import '../../util/data_book_util.dart';
import '../../util/jvx_colors.dart';
import '../../util/jvx_logger.dart';
import '../../util/offline_util.dart';
import '../../util/parse_util.dart';
import '../../util/widgets/embedded_code_scanner.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';
import 'fl_button_widget.dart';
import 'fl_slide_button_widget.dart';

class FlButtonWrapper<T extends FlButtonModel> extends BaseCompWrapperWidget<T> {
  const FlButtonWrapper({super.key, required super.model});

  @override
  FlButtonWrapperState createState() => FlButtonWrapperState();
}

class FlButtonWrapperState<T extends FlButtonModel> extends BaseCompWrapperState<T> {
  FlButtonWrapperState() : super();

  DataRecord? dataRecord;

  FocusNode buttonFocusNode = FocusNode();

  ActionSliderController actionSliderController = ActionSliderController();

  LocalAuthentication? _auth;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    layoutData.isFixedSize = model.isSlideStyle;

    if (model.columnName.isNotEmpty && model.dataProvider.isNotEmpty) {
      IUiService().registerDataSubscription(
        dataSubscription: DataSubscription(
          subbedObj: this,
          dataProvider: model.dataProvider,
          dataColumns: [model.columnName],
          onSelectedRecord: setSelectedRecord,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget buttonWidget;

    if (model.isSlideStyle) {
      buttonWidget = FlSlideButtonWidget(
        model: model,
        controller: actionSliderController,
        onSlide: (controller) {
          controller.loading();
          sendButtonPressed()
              .then((result) {
                if (result.success) {
                  controller.success();
                } else {
                  controller.failure();
                }
              })
              .catchError((Object error, StackTrace stackTrace) {
                controller.failure();
              })
              .whenComplete(() => Future.delayed(const Duration(milliseconds: 1500)))
              .whenComplete(() {
                if (controller.value.mode == SliderMode.failure || (model.isSliderResetable && model.isSliderAutoResetting)) {
                  controller.reset();
                }
              });
        },
      );
    }
    else {
      buttonWidget = FlButtonWidget(
        onFocusGained: focus,
        onFocusLost: unfocus,
        model: model,
        focusNode: buttonFocusNode,
        loading: isLoading,
        onPress: () {
          sendButtonPressed();
        },
      );
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return wrapWidget(context, buttonWidget);
  }

  @override
  void dispose() {
    buttonFocusNode.dispose();
    actionSliderController.dispose();
    super.dispose();
  }

  @override
  modelUpdated() {
    layoutData.isFixedSize = model.isSlideStyle;

    if (model.isSlideStyle && model.lastChangedProperties.contains(ApiObjectProperty.style)) {
      if (actionSliderController.value.mode == SliderMode.success || actionSliderController.value.mode == SliderMode.failure) {
        actionSliderController.reset();
      }
    }

    super.modelUpdated();
  }

  @override
  Size calculateSize(BuildContext context) {
    if (model.isSlideStyle) {
      Size? size = model.preferredSize;

      if (size == null) {
        size = model.minimumSize;

        double textWidth = ParseUtil.getTextWidth(text: model.labelModel.text, style: model.labelModel.createTextStyle());

        if (size != null) {
          if (textWidth < size.width) {
            textWidth = size.width;
          }
        }

        return Size(textWidth + 55 + JVxColors.componentHeight() + 2, JVxColors.componentHeight());
      }
    }

    Size calcSize = super.calculateSize(context);

    if (model.preferredSize == null) {
      double height = JVxColors.componentHeight();

      if (calcSize.width < height || calcSize.height < height) {
        return Size(max(calcSize.width, height), max(calcSize.height, height));
      }
    }

    return calcSize;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void setSelectedRecord(DataRecord? newDataRecord) {
    dataRecord = newDataRecord;

    setState(() {});
  }

  Future<CommandResult> sendButtonPressed([FlButtonModel? pressModel]) {
    if (model.isSecure) {
      return _authenticateUser().then((authenticated) async {
        await AuthService.hideBlur();

        if (authenticated == null) {
          IUiService().showJVxDialog(ErrorDialog(title:
            FlutterUI.translate("Error"),
            message: FlutterUI.translate("This application requires the use of biometrics or a PIN to proceed."),
            dismissible: true));

          return CommandResult(success: false);
        }
        else if (authenticated) {
          return _sendButtonPressedImmediate(pressModel);
        }

        return CommandResult(success: false);
      }).catchError((error, stack) {
        FlutterUI.log.e(error, error:error, stackTrace: stack);

        return CommandResult(success: false);
      });
    } else {
      return _sendButtonPressedImmediate(pressModel);
    }
  }

  Future<bool?> _authenticateUser() async {
    if (kIsWeb) {
      return false;
    }

    _auth ??= LocalAuthentication();

    try {
      bool isSupported = await _auth!.isDeviceSupported();

      if (isSupported) {
        bool canCheck = await _auth!.canCheckBiometrics;

        if (canCheck) {
          List<BiometricType> biometricTypes = await _auth!.getAvailableBiometrics();

          if (!AuthService.biometricOnly || biometricTypes.isNotEmpty) {
            return await _auth!.authenticate(
              localizedReason: FlutterUI.translate(AuthService.title),
              persistAcrossBackgrounding: true,
              biometricOnly: AuthService.biometricOnly,
            );
          }
        }
      }

      return null;
    } catch (e) {
      FlutterUI.log.d(e);

      return false;
    }
  }

  Future<CommandResult> _sendButtonPressedImmediate([FlButtonModel? pressModel]) {
    return IUiService().saveAllEditors(id: model.id, reason: "Button [${model.id} pressed").then((result) async {
      if (!result.success) {
        return result;
      }

      List<BaseCommand> commands = await _createButtonCommands(pressModel);

      if (commands.isNotEmpty) {
        return ICommandService().sendCommands(commands);
      }
      else {
        return CommandResult(success: false);
      }
    }).then((result) {
      if (!result.success) {
        return result;
      }

      if (model.isHyperLink) {
        _openUrl();
      } else if (!kIsWeb) {
        if (model.classNameEventSourceRef == FlButtonWidget.OFFLINE_BUTTON ||
            pressModel?.classNameEventSourceRef == FlButtonWidget.OFFLINE_ITEM) {
          _goOffline();
        } else if (pressModel?.classNameEventSourceRef == FlButtonWidget.SCANNER_ITEM ||
                   pressModel?.classNameEventSourceRef == FlButtonWidget.QR_SCANNER_ITEM) {
          _openScanner(pressModel!);
        } else if (model.classNameEventSourceRef == FlButtonWidget.SCANNER_BUTTON ||
                   model.classNameEventSourceRef == FlButtonWidget.QR_SCANNER_BUTTON) {
          _openScanner(model);
        } else if (model.classNameEventSourceRef == FlButtonWidget.CALL_BUTTON ||
                   model.classNameEventSourceRef == FlButtonWidget.CALL_ITEM) {
          _callNumber();
        } else if (pressModel?.classNameEventSourceRef == FlButtonWidget.EXPORT_ON_DEVICE_ITEM) {
          setState(() => isLoading = true);

          _exportOnDevice(pressModel!);
        }
        } else if (model.classNameEventSourceRef == FlButtonWidget.EXPORT_ON_DEVICE_BUTTON) {
          setState(() => isLoading = true);

          _exportOnDevice(model);
      }

      return CommandResult(success: true);
    });
  }

  Future<List<BaseCommand>> _createButtonCommands([FlButtonModel? pressModel]) async {
    List<BaseCommand> commands = [];

    BaseCommand? commandAfterPress;

    if (model.classNameEventSourceRef == FlButtonWidget.GEO_LOCATION_BUTTON ||
        pressModel?.classNameEventSourceRef == FlButtonWidget.GEO_LOCATION_ITEM) {
      commandAfterPress = await _locateDevice();

      if (commandAfterPress == null) {
        return commands;
      }
    }

    var oldFocus = IUiService().getFocus();
    commands.add(SetFocusCommand(componentId: model.id, focus: true, reason: "Button clicked Focus"));

    commands.add(
      PressButtonCommand(
        componentName: pressModel?.name ?? model.name,
        reason: "Button has been pressed",
      ),
    );

    if (commandAfterPress != null) {
      commands.add(commandAfterPress);
    }

    commands.add(SetFocusCommand(componentId: oldFocus?.id, focus: true, reason: "Button clicked focus"));

    return commands;
  }

  void _openScanner(FlButtonModel itemModel) {
    IUiService().openDialogFullScreen(
      transitionDuration: Duration.zero,
      isDismissible: true,
      builder: (_) => EmbeddedCodeScanner(formats: itemModel.scanFormats ?? const [BarcodeFormat.all], callback: (barcodes) {
        _sendScannerResult(itemModel, barcodes);
      }),
    );
  }

  void _sendScannerResult(FlButtonModel itemModel, List<Barcode> barcodes) {
    if (barcodes.isNotEmpty) {
      ICommandService().sendCommand(
        SetValuesCommand(
          dataProvider: itemModel.dataProvider,
          editorColumnName: itemModel.columnName,
          columnNames: [itemModel.columnName],
          values: [barcodes.first.rawValue],
          reason: "Code was scanned",
        ),
      );
    }
  }

  void _callNumber() {
    String tel = "";
    if (dataRecord != null) {
      tel = dataRecord!.values[0];
    }
    launchUrlString("tel://$tel");
  }

  void _openUrl() {
    String url = model.labelModel.text;

    if (!url.startsWith("http")) {
      url = "https://$url";
    }
    launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  void _goOffline() {
    BeamState state = context.currentBeamLocation.state as BeamState;
    String workScreenName = state.pathParameters[MainLocation.screenNameKey]!;
    FlPanelModel? screenModel = IStorageService().getComponentByNavigationName(workScreenName);

    OfflineUtil.initOffline(screenModel!.name);
  }

  Future<BaseCommand?> _locateDevice() async {
    Position? position;

    try {
      position = await _getPosition();
      if (FlutterUI.logUI.cl(Lvl.d)) {
        FlutterUI.logUI.d("Received geolocation data: $position");
      }

      return SetValuesCommand(
        dataProvider: model.dataProvider,
        editorColumnName: model.columnName,
        columnNames: [model.latitudeColumnName, model.longitudeColumnName],
        values: [position.latitude, position.longitude],
        reason: "Location was determined",
      );
    }
    catch (e, stack) {
      IUiService().showErrorDialog(title: "Device access", error: e, stackTrace: stack);
    }

    return null;
  }

  /// Exports records as html vault and saves the file
  static Future<void> exportOnDevice(String title, String dataProvider, List<String>? columnNames, String? fileName) async {
    String? htmlEncrypted = await DataBookUtil.exportAsHtmlVault(
      title,
      dataProvider,
      columnNames,
      null
    );

    if (htmlEncrypted != null) {
      String formattedDate = DateFormat('dd_MM_yyyy').format(DateTime.now());

      fileName ??= "export_$formattedDate.html";

      if (!fileName.contains(".")) {
        fileName = "$fileName.html";
      }

      await ICommandService().sendCommand(SaveOrShowFileCommand(
          fileId: "exportOnDevice",
          fileName: fileName,
          content: utf8.encode(htmlEncrypted),
          showFile: false,
          reason: "Export on device"
      ));
    }
  }

  /// Exports records as html vault and saves the file
  Future<void> _exportOnDevice(FlButtonModel exportModel) async {
    try
    {
      List<dynamic>? cols = exportModel.jsonMerge[ApiObjectProperty.columnNames];

      List<String>? columnNames;

      if (cols != null) {
        columnNames = List<String>.from(cols);
      }

      await exportOnDevice(
        exportModel.jsonMerge[ApiObjectProperty.title],
        exportModel.dataProvider,
        columnNames,
        exportModel.jsonMerge[ApiObjectProperty.fileName]
      );
    }
    finally {
      setState(() => isLoading = false);
    }
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _getPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permissions are denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      throw Exception("Location permissions are permanently denied");
    }

    return Geolocator.getCurrentPosition();
  }

}
