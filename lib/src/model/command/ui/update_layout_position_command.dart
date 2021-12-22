import 'dart:collection';

import '../../layout/layout_data.dart';

import 'ui_command.dart';

class UpdateLayoutPositionCommand extends UiCommand {
  /// List of position data
  HashMap<String, LayoutData> layoutDatas;

  UpdateLayoutPositionCommand({
    required this.layoutDatas,
    required String reason,
  }) : super(reason: reason);

  @override
  // TODO: implement logString
  String get logString => throw UnimplementedError();
}
