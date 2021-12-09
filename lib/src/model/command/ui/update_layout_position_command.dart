import 'package:flutter_client/src/model/command/ui/ui_command.dart';
import 'package:flutter_client/src/model/layout/layout_position.dart';

class UpdateLayoutPositionCommand extends UiCommand {


  /// List of position data
  List<LayoutPosition> layoutPosition;


  UpdateLayoutPositionCommand({
    required this.layoutPosition,
    required String reason,
  }) : super(reason: reason);


  @override
  // TODO: implement logString
  String get logString => throw UnimplementedError();

}