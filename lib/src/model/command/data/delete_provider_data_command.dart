import 'data_command.dart';

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
    this.deleteAll,
    this.fromIndex,
    this.toIndex,
    required super.reason,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return 'DeleteProviderDataCommand{dataProvider: $dataProvider, fromIndex: $fromIndex, toIndex: $toIndex, deleteAll: $deleteAll, ${super.toString()}}';
  }
}
