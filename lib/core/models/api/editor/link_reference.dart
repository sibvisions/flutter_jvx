class LinkReference {
  List<String> columnNames = <String>[];
  List<String> referencedColumnNames = <String>[];
  String referencedDataBook;
  String dataProvider;

  LinkReference();

  LinkReference.fromJson(Map<String, dynamic> json) {
    if (json['columnNames'] != null)
      columnNames = List<String>.from(json['columnNames']);
    if (json['referencedColumnNames'] != null)
      referencedColumnNames = List<String>.from(json['referencedColumnNames']);
    referencedDataBook = json['referencedDataBook'];
    dataProvider = json['dataProvider'];
    if (dataProvider == null) dataProvider = referencedDataBook;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'columnNames': columnNames,
        'referencedColumnNames': referencedColumnNames,
        'referencedDataBook': referencedDataBook,
        'dataProvider': dataProvider
      };
}
