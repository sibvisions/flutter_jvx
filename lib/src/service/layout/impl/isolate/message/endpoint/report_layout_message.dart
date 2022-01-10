import 'dart:isolate';

import '../../../../../../model/command/base_command.dart';
import '../../../../../../model/layout/layout_data.dart';
import '../layout_message.dart';

class ReportLayoutMessage extends LayoutMessage<List<BaseCommand>> {
  final LayoutData layoutData;

  ReportLayoutMessage({required this.layoutData});

  @override
  sendResponse({required List<BaseCommand> response, required SendPort sendPort}) {
    sendPort.send(response);
  }
}
