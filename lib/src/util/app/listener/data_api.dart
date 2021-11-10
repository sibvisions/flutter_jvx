

// class DataApi {
//   SoComponentData _componentData;
//   BuildContext _context;

//   DataApi(this._componentData, this._context);

//   dynamic getValue(String columnName) {
//     return _componentData.getColumnData(_context, columnName);
//   }

//   List<dynamic> getValues(List<dynamic> columnNames) {
//     List<dynamic> values = [];

//     for (final columnName in columnNames) {
//       values.add(getValue(columnName));
//     }

//     return values;
//   }

//   void setValue(String columnName, dynamic value) {
//     _componentData.setValues(_context, [value], [columnName]);
//   }

//   void setValues(List<dynamic> columnNames, List<dynamic> values) {
//     _componentData.setValues(_context, values, columnNames);
//   }

//   void insertRecord() {
//     _componentData.insertRecord(_context);
//   }

//   void deleteRecord(int index) {
//     _componentData.deleteRecord(_context, index);
//   }

//   void selectRecord(int index) {
//     _componentData.selectRecord(_context, index);
//   }
// }
