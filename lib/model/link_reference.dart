class LinkReference {
  List columnNames;
  List referencedColumnNames;
  String referencedDataBook;
  String dataProvider;

  LinkReference();

  LinkReference.fromJson(Map<String, dynamic> json)
    : columnNames = json['columnNames'],
      referencedColumnNames = json['referencedColumnNames'],
      referencedDataBook = json['referencedDataBook'],
      dataProvider = json['dataProvider'];

  Map<String, dynamic> toJson() => <String, dynamic>{
    'columnNames': columnNames,
    'referencedColumnNames': referencedColumnNames,
    'referencedDataBook': referencedDataBook,
    'dataProvider': dataProvider
  };
}