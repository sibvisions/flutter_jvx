import 'ui_command.dart';
import '../../layout/layout_position.dart';

class UpdateLayoutPositionCommand extends UiCommand {
  /// List of position data
  Map<String, LayoutPosition> layoutPosition;

  UpdateLayoutPositionCommand({
    required this.layoutPosition,
    required String reason,
  }) : super(reason: reason);

  @override
  // TODO: implement logString
  String get logString => throw UnimplementedError();
}
