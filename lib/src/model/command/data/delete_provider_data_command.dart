import 'package:flutter_client/src/model/command/data/data_command.dart';

class DeleteProviderDataCommand extends DataCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Data provider from which data will be deleted
  final String dataProvider;

  /// Records will be deleted starting from this index
  final int? fromIndex;

  /// Records will be deleted to this index
  final int? toIndex;

  /// If true all other properties will be ignored and
  /// all data in [dataProvider] will be deleted
  final bool? deleteAll;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  DeleteProviderDataCommand({
    required this.dataProvider,
    required String reason,
    this.deleteAll,
    this.fromIndex,
    this.toIndex,
  }) : super(reason: reason);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String get logString =>
      "DeleteProviderDataCommand: dataProvider: $dataProvider, deleteAll: $deleteAll, fromIndex: $fromIndex, toIndex: $toIndex, reason: $reason";
}
