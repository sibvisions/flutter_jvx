import '../../../../../isolate/isolate_message.dart';
import '../../../../../../model/command/base_command.dart';
import '../../../../../../model/layout/layout_data.dart';

class ReportPreferredSizeMessage extends IsolateMessage<List<BaseCommand>> {
  final LayoutData layoutData;

  ReportPreferredSizeMessage({required this.layoutData});
}
