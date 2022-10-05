import '../../layout/layout_data.dart';
import 'ui_command.dart';

class UpdateLayoutPositionCommand extends UiCommand {
  /// List of position data
  final List<LayoutData> layoutDataList;

  UpdateLayoutPositionCommand({
    required this.layoutDataList,
    required super.reason,
  });

  @override
  String toString() {
    return "UpdateLayoutPositionCommand{layoutDataList: $layoutDataList, ${super.toString()}}";
  }
}
