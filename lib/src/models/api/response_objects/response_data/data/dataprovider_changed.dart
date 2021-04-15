import '../../../response_object.dart';

class DataproviderChanged extends ResponseObject {
  String? dataProvider;
  int? reload;
  int? selectedRow;
  List<String>? columnNames;
  bool? readOnly;
  bool? deleteEnabled;
  bool? updateEnabled;
  bool? insertEnabled;
  List<String>? changedColumnNames;

  DataproviderChanged(
      {required String name,
      this.dataProvider,
      this.reload,
      this.selectedRow,
      this.columnNames})
      : super(name: name);

  DataproviderChanged.fromJson({required Map<String, dynamic> map})
      : super.fromJson(map: map) {
    dataProvider = map['dataProvider'];
    reload = map['reload'];
    selectedRow = map['selectedRow'];
    columnNames = map['columnNames'];
    readOnly = map['readOnly'];
    deleteEnabled = map['deleteEnabled'];
    updateEnabled = map['updateEnabled'];
    insertEnabled = map['insertEnabled'];
    changedColumnNames = map['changedColumnNames'];
  }
}
