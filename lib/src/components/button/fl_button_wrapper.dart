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
import '../../model/command/api/fetch_command.dart';
import '../../model/command/api/press_button_command.dart';
import '../../model/command/api/set_values_command.dart';
import '../../model/command/base_command.dart';
import '../../model/command/config/save_download_command.dart';
import '../../model/command/ui/set_focus_command.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/data/column_definition.dart';
import '../../model/data/data_book.dart';
import '../../model/data/subscriptions/data_record.dart';
import '../../model/data/subscriptions/data_subscription.dart';
import '../../routing/locations/main_location.dart';
import '../../service/api/shared/api_object_property.dart';
import '../../service/command/i_command_service.dart';
import '../../service/data/i_data_service.dart';
import '../../service/storage/i_storage_service.dart';
import '../../service/ui/i_ui_service.dart';
import '../../util/auth/auth_service.dart';
import '../../util/html_vault.dart';
import '../../util/i_types.dart';
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

  bool _isLoading = false;

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
        loading: _isLoading,
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

  Future<CommandResult> sendButtonPressed([String? overwrittenButtonPressId]) {
    if (model.isSecure) {
      return _authenticateUser().then((authenticated) async {
        if (authenticated == null) {
          IUiService().showJVxDialog(ErrorDialog(title:
            FlutterUI.translate("Error"),
            message: FlutterUI.translate("This application requires the use of biometrics or a PIN to proceed."),
            dismissible: true));

          return CommandResult(success: false);
        }
        else if (authenticated) {
          return _sendButtonPressedImmediate(overwrittenButtonPressId);
        }

        return CommandResult(success: false);
      }).catchError((error, stack) {
        FlutterUI.log.e(error, error:error, stackTrace: stack);

        return CommandResult(success: false);
      });
    } else {
      return _sendButtonPressedImmediate(overwrittenButtonPressId);
    }
  }

  Future<bool?> _authenticateUser() async {
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

  Future<CommandResult> _sendButtonPressedImmediate([String? overwrittenButtonPressId]) {
    return IUiService().saveAllEditors(id: model.id, reason: "Button [${model.id} pressed").then((result) async {
      if (!result.success) {
        return result;
      }

      List<BaseCommand> commands = await _createButtonCommands(overwrittenButtonPressId);

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
        openUrl();
      } else if (!kIsWeb) {
        if (model.classNameEventSourceRef == FlButtonWidget.OFFLINE_BUTTON) {
          goOffline();
        } else if (model.classNameEventSourceRef == FlButtonWidget.SCANNER_BUTTON || model.classNameEventSourceRef == FlButtonWidget.QR_SCANNER_BUTTON) {
          openScanner();
        } else if (model.classNameEventSourceRef == FlButtonWidget.CALL_BUTTON) {
          callNumber();
        } else if (model.classNameEventSourceRef == FlButtonWidget.EXPORT_ON_DEVICE_BUTTON) {
          setState(() => _isLoading = true);

          exportOnDevice();
        }
      }

      return CommandResult(success: true);
    });
  }

  Future<List<BaseCommand>> _createButtonCommands(String? overwrittenButtonPressId) async {
    List<BaseCommand> commands = [];

    BaseCommand? commandAfterPress;

    if (model.classNameEventSourceRef == FlButtonWidget.GEO_LOCATION_BUTTON) {
      commandAfterPress = await locateDevice();

      if (commandAfterPress == null) {
        return commands;
      }
    }

    var oldFocus = IUiService().getFocus();
    commands.add(SetFocusCommand(componentId: model.id, focus: true, reason: "Button clicked Focus"));

    commands.add(
      PressButtonCommand(
        componentName: overwrittenButtonPressId ?? model.name,
        reason: "Button has been pressed",
      ),
    );

    if (commandAfterPress != null) {
      commands.add(commandAfterPress);
    }

    commands.add(SetFocusCommand(componentId: oldFocus?.id, focus: true, reason: "Button clicked focus"));

    return commands;
  }

  void openScanner() {
    IUiService().openDialogFullScreen(
      transitionDuration: Duration.zero,
      isDismissible: true,
      builder: (_) => EmbeddedCodeScanner(formats: model.scanFormats ?? const [BarcodeFormat.all], callback: sendScannerResult),
    );
  }

  void sendScannerResult(List<Barcode> barcodes) {
    if (barcodes.isNotEmpty) {
      ICommandService().sendCommand(
        SetValuesCommand(
          dataProvider: model.dataProvider,
          editorColumnName: model.columnName,
          columnNames: [model.columnName],
          values: [barcodes.first.rawValue],
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

  Future<BaseCommand?> locateDevice() async {
    Position? position;

    try {
      position = await getPosition();
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

  Future<void> exportOnDevice() async {
    try {
      DataBook? book = IDataService().getDataBook(model.dataProvider);

      if (book != null) {
        String? password = await IUiService().getInput("File password", "Password", true, icon: Icons.key);

        if (password == null || password.isEmpty) {
          return;
        }

        List<dynamic>? columnNames = model.jsonMerge[ApiObjectProperty.columnNames];

        if (columnNames != null) {
          if (!book.isAllFetched) {
            await ICommandService().sendCommand(
                FetchCommand(
                    reason: "Fetching data for export on device",
                    dataProvider: book.dataProvider,
                    fromRow: book.records.length,
                    rowCount: -1
                )
            );
          }

          StringBuffer html = StringBuffer();

          html.write(
            '''
            <style>
              .search-wrapper {
                display: flex;
                gap: 10px;
                margin-top: 2rem;
                margin-bottom: 1.5rem;
                width: 100%;
              }
            
              #searchInput {
                flex: 5; 
                background: #f1f5f9 !important; 
                color: #1e293b !important;
                border: 1px solid #cbd5e1 !important;
                margin: 0; 
                padding: 0.75rem;  
                border-radius: 3px;
              }
              
              #searchInput::placeholder {
                color: #94a3b8;
              }
            
              #searchClear {
                flex: 1;
                padding: 0.75rem;
                background: #64748b;
                color: white;
                border: none;
                border-radius: 0.5rem;
                font-weight: 600;
                cursor: pointer;
                white-space: nowrap;     
              }
              
              #searchClear:hover {
                background: #475569;
              }  
            
              .custom-table th.searching {
                background-color: #f0fdf4 !important; 
                border-bottom: 3px solid #22c55e !important; 
                color: #1e293b !important;
                 
                transition: all 0.3s ease;
              }  
            
              .custom-table {
                -webkit-overflow-scrolling: touch; 
                overflow-x: auto; 
                width: 100%;
                border-collapse: separate;
                border-spacing: 0;
                border: 1px solid #d1d1d1;
                border-radius: 12px;
                overflow: hidden;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
              }
            
              .custom-table th, 
              .custom-table td {
                padding: 14px;
                text-align: left;
                border-bottom: 1px solid #d1d1d1;
                border-right: 1px solid #d1d1d1;
              }
            
              /* remove right border of last column */
              .custom-table th:last-child, 
              .custom-table td:last-child {
                border-right: none;
              }
            
              /* remove bottom border or last row */
              .custom-table tr:last-child td {
                border-bottom: none;
              }
            
              /* header */
              .custom-table th {
                background-color: #ececec;
                color: #444;
                font-weight: 600;
              }
            
              /* odd/even background */
              .custom-table tbody tr:nth-child(odd) {
                background-color: #fcfcfc;
              }
            
              /* hover for visibility */
              .custom-table tbody tr:hover {
                background-color: #f5f5f5;
              }
              
              p.title {
                margin-top: 0;
                font-size: 17px;
                font-weight: 600;
                margin-bottom: 20px;
              }
            </style>
            '''
          );

          String? title = model.jsonMerge[ApiObjectProperty.title];

          html.write("<p class='title'>$title</p>");

          //Search

          html.write(
            '''
            <div class="search-wrapper">
            <input type="text" id="searchInput" class="table-search" placeholder="Enter search value">
            <button id="searchClear" class="clear-btn">Clear</button>
            </div>
            '''
          );

          // Header

          List<dynamic> columnNamesCopy = List.of(columnNames);

          List<String> headers = [];
          Map<String, String> alignments = {};

          html.write("<table class='custom-table'><tr>");

          for (String name in columnNamesCopy) {
            if (book.metaData != null) {
              ColumnDefinition? colDef = book.metaData!.columnDefinitions.byName(name);

              if (colDef != null) {
                html.write("<th>${colDef.label}</th>");

                if (colDef.dataTypeIdentifier == ITypes.DECIMAL
                    || colDef.dataTypeIdentifier == ITypes.BIGINT) {
                  alignments[name] = "right";
                }
                else {
                  alignments[name] = "left";
                }
              }
              else {
                //no column definition -> don't export
                columnNames.remove(name);
              }
            }
            else {
              alignments[name] = "left";

              //no metadata -> try to export
              headers.add(name);
            }
          }

          html.write("</tr>");

          // Records
          List<dynamic>? record;

          for (int i = 0; i < book.records.length; i++) {
            record = book.records[i];

            if (record != null) {
              int? idx;

              html.write("<tr>");
              for (String name in columnNames) {
                html.write("<td style='text-align: ${alignments[name]};'>");

                idx = book.metaData?.columnDefinitions.indexByName(name);

                if (idx != null && idx >= 0) {
                  html.write(record[idx] ?? "");
                }
                else {
                  html.write("");
                }

                html.write("</td>");
              }

              html.write("</tr>");
            }
          }

          html.write("</table>");

          html.write(
            '''
            <script>
                (function() {
                    const input = document.getElementById('searchInput');
                    const btn = document.getElementById('searchClear');
                    const table = document.querySelector(".custom-table");
            
                    // Alread initialized or missing elements -> stop
                    if (!input || !table || input.dataset.initialized === "true") {
                        return; 
                    }
            
                    // Mark initialized and avoid multiple initialization
                    input.dataset.initialized = "true";
            
                    const rows = Array.from(table.querySelectorAll("tr")).slice(1);
                    const headers = table.querySelectorAll("th");
            
                    const performFilter = () => {
                        const filter = input.value.toLowerCase();
                        const isSearching = filter.length > 0;
            
                        headers.forEach(th => {
                            isSearching ? th.classList.add('searching') : th.classList.remove('searching');
                        });
            
                        rows.forEach(row => {
                            row.style.display = row.textContent.toLowerCase().includes(filter) ? "" : "none";
                        });
                    };
            
                    input.addEventListener('input', performFilter);
                    
                    if(btn) {
                        btn.addEventListener('click', () => {
                            input.value = '';
                            performFilter();
                            input.focus();
                        });
                    }
                    
                    console.log("Search successfully bound.");
                })();
            </script>             
            '''
          );

          String htmlEncrypted = await HtmlVault.create(htmlContent: html.toString(), password: password);

          String? fileName = model.jsonMerge[ApiObjectProperty.fileName];

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
    }
    finally {
      setState(() => _isLoading = false);
    }
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
