import 'dart:isolate';

import '../../../../../../model/command/base_command.dart';
import '../../../../../../model/layout/layout_data.dart';
import '../layout_message.dart';

class ReportPreferredSizeMessage extends LayoutMessage<List<BaseCommand>> {
  final LayoutData layoutData;

  ReportPreferredSizeMessage({required this.layoutData});

  @override
  sendResponse({required List<BaseCommand> response, required SendPort sendPort}) {
    sendPort.send(response);
  }
}
