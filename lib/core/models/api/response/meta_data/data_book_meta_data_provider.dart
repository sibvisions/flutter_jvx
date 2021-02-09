class DataBookMetaDataProvider {
  String name;
  List columnNames;
  List masterColumnNames;

  DataBookMetaDataProvider(
      {this.name, this.columnNames, this.masterColumnNames});

  DataBookMetaDataProvider.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        columnNames = json['columnNames'],
        masterColumnNames = json['masterColumnNames'];

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'columnNames': columnNames,
    'masterColumnNames': masterColumnNames
  };
}
