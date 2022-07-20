import '../../../../../isolate/isolate_message.dart';
import '../../../../../../model/command/base_command.dart';
import '../../../../../../model/layout/layout_data.dart';

class ReportLayoutMessage extends IsolateMessage<List<BaseCommand>> {
  final LayoutData layoutData;

  ReportLayoutMessage({required this.layoutData});
}
