import 'package:beamer/beamer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../util/logging/flutter_logger.dart';
import '../../mask/camera/qr_scanner_overlay.dart';
import '../../model/command/api/press_button_command.dart';
import '../../model/command/api/set_values_command.dart';
import '../../model/component/button/fl_button_model.dart';
import '../../model/data/subscriptions/data_record.dart';
import '../../model/data/subscriptions/data_subscription.dart';
import '../../service/ui/i_ui_service.dart';
import '../../util/offline_util.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';
import 'fl_button_widget.dart';

class FlButtonWrapper<T extends FlButtonModel> extends BaseCompWrapperWidget<T> {
  const FlButtonWrapper({Key? key, required String id}) : super(key: key, id: id);

  @override
  FlButtonWrapperState createState() => FlButtonWrapperState();
}

class FlButtonWrapperState<T extends FlButtonModel> extends BaseCompWrapperState<T> {
  /// If anything has a focus, the button pressed event must be added as a listener.
  /// As to send it last.
  FocusNode? currentObjectFocused;

  String? _overwrittenButtonPressId;

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
    _overwrittenButtonPressId = overwrittenButtonPressId;
    currentObjectFocused = FocusManager.instance.primaryFocus;
    if (currentObjectFocused == null || currentObjectFocused!.parent == null) {
      LOGGER.logI(pType: LogType.UI, pMessage: "Button pressed");
      _sendButtonCommand();
    } else {
      LOGGER.logI(pType: LogType.UI, pMessage: "Button will be pressed");
      currentObjectFocused!.addListener(delayedSendButtonPressed);
      currentObjectFocused!.unfocus();
    }
  }

  void delayedSendButtonPressed() {
    LOGGER.logI(pType: LogType.UI, pMessage: "Delayed button pressed");
    _sendButtonCommand();
    currentObjectFocused!.removeListener(delayedSendButtonPressed);
    currentObjectFocused = null;
  }

  void _sendButtonCommand() {
    IUiService()
        .sendCommand(PressButtonCommand(
      componentName: _overwrittenButtonPressId ?? model.name,
      reason: "Button has been pressed",
    ))
        .then((value) {
      if (!kIsWeb) {
        if (model.classNameEventSourceRef == FlButtonWidget.OFFLINE_BUTTON) {
          goOffline();
        } else if (model.classNameEventSourceRef == FlButtonWidget.QR_SCANNER_BUTTON) {
          openQrCodeScanner();
        } else if (model.classNameEventSourceRef == FlButtonWidget.CALL_BUTTON) {
          callNumber();
        }
      }
    });
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

  void goOffline() {
    BeamState state = context.currentBeamLocation.state as BeamState;
    String workscreenName = state.pathParameters['workScreenName']!;
    OfflineUtil.initOffline(workscreenName);
  }
}
