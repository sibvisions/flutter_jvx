import 'dart:developer';

import 'package:beamer/beamer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../mask/camera/qr_scanner_overlay.dart';
import '../../model/command/api/press_button_command.dart';
import '../../model/command/api/set_values_command.dart';
import '../../model/command/base_command.dart';
import '../../model/component/button/fl_button_model.dart';
import '../../model/data/subscriptions/data_record.dart';
import '../../model/data/subscriptions/data_subscription.dart';
import '../../service/ui/i_ui_service.dart';
import '../../util/offline_util.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';
import 'fl_button_widget.dart';

class FlButtonWrapper<T extends FlButtonModel> extends BaseCompWrapperWidget<T> {
  const FlButtonWrapper({super.key, required super.id});

  @override
  FlButtonWrapperState createState() => FlButtonWrapperState();
}

class FlButtonWrapperState<T extends FlButtonModel> extends BaseCompWrapperState<T> {
  FlButtonWrapperState() : super();

  DataRecord? dataRecord;

  @override
  void initState() {
    super.initState();

    if (model.columnName.isNotEmpty && model.dataProvider.isNotEmpty) {
      IUiService().registerDataSubscription(
        pDataSubscription: DataSubscription(
          subbedObj: this,
          dataProvider: model.dataProvider,
          from: 0,
          dataColumns: [model.columnName],
          onSelectedRecord: setSelectedRecord,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final FlButtonWidget buttonWidget = FlButtonWidget(
      onPressDown: (p0) => log("pressed down"),
      onPressUp: (p0) => log("press lifted"),
      onFocusGained: sendFocusGainedCommand,
      onFocusLost: sendFocusLostCommand,
      model: model,
      onPress: sendButtonPressed,
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: buttonWidget);
  }

  void setSelectedRecord(DataRecord? pDataRecord) {
    dataRecord = pDataRecord;

    setState(() {});
  }

  void sendButtonPressed([String? overwrittenButtonPressId]) {
    IUiService()
        .saveAllEditors(
      pId: model.id,
      pFunction: () => _sendButtonCommand(overwrittenButtonPressId),
      pReason: "Button pressed",
    )
        .then((value) {
      if (model.style == "hyperlink") {
        openUrl();
      } else if (!kIsWeb) {
        if (model.classNameEventSourceRef == FlButtonWidget.OFFLINE_BUTTON) {
          goOffline();
        } else if (model.classNameEventSourceRef == FlButtonWidget.QR_SCANNER_BUTTON) {
          openQrCodeScanner();
        } else if (model.classNameEventSourceRef == FlButtonWidget.CALL_BUTTON) {
          callNumber();
        }
      }
    }).catchError(IUiService().handleAsyncError);
  }

  Future<List<BaseCommand>> _sendButtonCommand(String? pOverwrittenButtonPressId) async {
    return [
      PressButtonCommand(
        componentName: pOverwrittenButtonPressId ?? model.name,
        reason: "Button has been pressed",
      ),
    ];
  }

  void openQrCodeScanner() {
    IUiService().openDialog(
      pBuilder: (_) => QRScannerOverlay(callback: sendQrCodeResult),
    );
  }

  void sendQrCodeResult(Barcode pBarcode, MobileScannerArguments? pArguments) {
    IUiService().sendCommand(
      SetValuesCommand(
        componentId: model.id,
        dataProvider: model.dataProvider,
        columnNames: [model.columnName],
        values: [pBarcode.rawValue],
        reason: "Qr code was scanned",
      ),
    );
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
    String workscreenName = state.pathParameters['workScreenName']!;
    OfflineUtil.initOffline(workscreenName);
  }
}
