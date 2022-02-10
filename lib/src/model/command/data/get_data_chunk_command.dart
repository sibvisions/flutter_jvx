import 'data_command.dart';

class GetDataChunkCommand extends DataCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Id of the component Requesting data
  final String componentId;

  /// Link to the dataBook containing the data
  final String dataProvider;

  /// List of names of the dataColumns that are being requested
  final List<String> dataColumns;

  /// From which index data is being requested
  final int from;

  /// To which index data is being requested
  final int to;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  GetDataChunkCommand(
      {required String reason,
      required this.dataProvider,
      required this.from,
      required this.to,
      required this.componentId,
      required this.dataColumns})
      : super(reason: reason);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  // TODO: implement logString
  String get logString => throw UnimplementedError();
}
