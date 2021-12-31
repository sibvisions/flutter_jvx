import 'dart:isolate';

import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/layout/layout_data.dart';
import 'package:flutter_client/src/service/layout/impl/isolate/message/layout_message.dart';

class ReportPreferredSizeMessage extends LayoutMessage<List<BaseCommand>> {


  final LayoutData layoutData;

  ReportPreferredSizeMessage({
    required this.layoutData
  });

  @override
  sendResponse({required List<BaseCommand> response, required SendPort sendPort}) {
    sendPort.send(response);
  }

}