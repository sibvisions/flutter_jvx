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
import 'dart:math';

import 'package:action_slider/action_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../flutter_jvx.dart';
import '../../model/command/ui/set_focus_command.dart';
import '../../util/jvx_logger.dart';
import '../../util/offline_util.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';
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

  @override
  void initState() {
    super.initState();

    layoutData.isFixedSize = model.isSlideStyle;

    if (model.columnName.isNotEmpty && model.dataProvider.isNotEmpty) {
      IUiService().registerDataSubscription(
        pDataSubscription: DataSubscription(
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
              .then((success) {
                if (success) {
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
                if (controller.value.mode == SliderMode.failure ||
                    (model.isSliderResetable && model.isSliderAutoResetting)) {
                  controller.reset();
                }
              });
        },
      );
    } else {
      buttonWidget = FlButtonWidget(
        onFocusGained: focus,
        onFocusLost: unfocus,
        model: model,
        focusNode: buttonFocusNode,
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

  void setSelectedRecord(DataRecord? pDataRecord) {
    dataRecord = pDataRecord;

    setState(() {});
  }

  Future<bool> sendButtonPressed([String? overwrittenButtonPressId]) {
    return IUiService().saveAllEditors(pId: model.id, pReason: "Button [${model.id} pressed").then((success) async {
      if (!success) {
        return false;
      }

      return ICommandService().sendCommands(await _createButtonCommands(overwrittenButtonPressId));
    }).then((success) {
      if (!success) {
        return false;
      }

      if (model.isHyperLink) {
        openUrl();
      } else if (!kIsWeb) {
        if (model.classNameEventSourceRef == FlButtonWidget.OFFLINE_BUTTON) {
          goOffline();
        } else if (model.classNameEventSourceRef == FlButtonWidget.SCANNER_BUTTON ||
            model.classNameEventSourceRef == FlButtonWidget.QR_SCANNER_BUTTON) {
          openScanner();
        } else if (model.classNameEventSourceRef == FlButtonWidget.CALL_BUTTON) {
          callNumber();
        }
      }

      return true;
    });
  }

  Future<List<BaseCommand>> _createButtonCommands(String? pOverwrittenButtonPressId) async {
    List<BaseCommand> commands = [];

    var oldFocus = IUiService().getFocus();
    commands.add(SetFocusCommand(componentId: model.id, focus: true, reason: "Button clicked Focus"));

    commands.add(
      PressButtonCommand(
        componentName: pOverwrittenButtonPressId ?? model.name,
        reason: "Button has been pressed",
      ),
    );

    if (model.classNameEventSourceRef == FlButtonWidget.GEO_LOCATION_BUTTON) {
      commands.add(await locateDevice());
    }

    commands.add(SetFocusCommand(componentId: oldFocus?.id, focus: true, reason: "Button clicked Focus"));

    return commands;
  }

  void openScanner() {
    IUiService().openDialog(
      pBuilder: (_) => JVxScanner(
        formats: model.scanFormats ?? const [BarcodeFormat.all],
        callback: sendScannerResult,
      ),
    );
  }

  void sendScannerResult(List<Barcode> pBarcodes) {
    if (pBarcodes.isNotEmpty) {
      ICommandService().sendCommand(
        SetValuesCommand(
          dataProvider: model.dataProvider,
          editorColumnName: model.columnName,
          columnNames: [model.columnName],
          values: [pBarcodes.first.rawValue],
          reason: "Code was scanned",
        ),
      );
    }
  }

  void callNumber() {
    String tel = "";
    if (dataRecord != null) {
      tel = dataRecord!.values[0];
    }
    launchUrlString("tel://$tel");
  }

  void openUrl() {
    String url = model.labelModel.text;

    if (!url.startsWith("http")) {
      url = "https://$url";
    }
    launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  void goOffline() {
    BeamState state = context.currentBeamLocation.state as BeamState;
    String workScreenName = state.pathParameters[MainLocation.screenNameKey]!;
    FlPanelModel? screenModel = IStorageService().getComponentByNavigationName(workScreenName);
    OfflineUtil.initOffline(screenModel!.name);
  }

  Future<BaseCommand> locateDevice() async {
    Position position = await getPosition();
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

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> getPosition() async {
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
