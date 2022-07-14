import '../../../../api/api_object_property.dart';

class LinkReference {
  List<String> columnNames = <String>[];
  List<String> referencedColumnNames = <String>[];
  late String referencedDataBook;
  late String dataProvider;

  LinkReference();

  LinkReference.fromJson(Map<String, dynamic> json) {
    var jsonColumnNames = json[ApiObjectProperty.columnNames];
    if (jsonColumnNames != null) {
      columnNames = List<String>.from(jsonColumnNames);
    }
    var jsonReferencedColumnNames = json[ApiObjectProperty.referencedColumnNames];
    if (jsonReferencedColumnNames != null) {
      referencedColumnNames = List<String>.from(jsonReferencedColumnNames);
    }
    var jsonReferencedDataBook = json[ApiObjectProperty.referencedDataBook];
    if (jsonReferencedDataBook != null) {
      referencedDataBook = jsonReferencedDataBook;
    }
    var jsonDataProvider = json[ApiObjectProperty.dataProvider];
    if (jsonDataProvider != null) {
      dataProvider = jsonDataProvider;
    } else {
      dataProvider = referencedDataBook;
    }
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'columnNames': columnNames,
        'referencedColumnNames': referencedColumnNames,
        'referencedDataBook': referencedDataBook,
        'dataProvider': dataProvider
      };
}
