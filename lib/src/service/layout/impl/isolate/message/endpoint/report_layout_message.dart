import '../../../../../../model/command/base_command.dart';
import '../../../../../../model/layout/layout_data.dart';
import '../../../../../isolate/isolate_message.dart';

class ReportLayoutMessage extends IsolateMessage<List<BaseCommand>> {
  final LayoutData layoutData;

  ReportLayoutMessage({required this.layoutData});
}
