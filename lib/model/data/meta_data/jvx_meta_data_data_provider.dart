class JVxMetaDataDataProvider {
  String name;
  List columnNames;
  List masterColumnNames;

  JVxMetaDataDataProvider({this.name, this.columnNames, this.masterColumnNames});

  JVxMetaDataDataProvider.fromJson(Map<String, dynamic> json)
    : name = json['name'],
      columnNames = json['columnNames'],
      masterColumnNames = json['masterColumnNames'];
}