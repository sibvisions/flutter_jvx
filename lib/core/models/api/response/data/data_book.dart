import '../../response_object.dart';
import 'filter.dart';

class DataBook extends ResponseObject {
  int selectedRow;
  bool isAllFetched;
  String dataProvider;
  List<dynamic> records = <dynamic>[];
  List<dynamic> columnNames;
  int from;
  int to;

  DataBook(
      {this.selectedRow,
      this.isAllFetched,
      this.dataProvider,
      this.records,
      this.columnNames});

  List<dynamic> getRow([int rowIndex, List<String> pColumnNames]) {
    List<dynamic> row = <dynamic>[];

    if (rowIndex != null) rowIndex = selectedRow;

    if (rowIndex < this.records.length) {
      if (pColumnNames == null)
        pColumnNames = List<String>.from(this.columnNames);
      List<int> columnIndexes = <int>[];

      pColumnNames.forEach((c) {
        int index = this.columnNames.indexOf(c);
        if (index >= 0) columnIndexes.add(index);
      });

      columnIndexes.forEach((i) {
        row.add(this.records[rowIndex][i]);
      });
    }

    return row;
  }

  List<int> getColumnIndexes(List<dynamic> columnNames) {
    List<int> visibleColumnsIndex = <int>[];
    this.columnNames.asMap().forEach((i, v) {
      if (columnNames != null) {
        if (columnNames.contains(v)) {
          visibleColumnsIndex.add(i);
        }
      }
    });

    return visibleColumnsIndex;
  }

  int getColumnIndex(dynamic columnName) {
    this.columnNames.asMap().forEach((i, v) {
      if (columnName != null && columnName == v) {
        return i;
      }
    });

    return -1;
  }

  T getValue<T>(dynamic columnName, [int rowIndex]) {
    int columnIndex = getColumnIndex(columnName);
    dynamic value;

    if (rowIndex != null) rowIndex = selectedRow;

    if (columnIndex >= 0) {
      value = records[rowIndex][columnIndex];

      if (value is String) {
        if (T == bool) {
          return (value.toLowerCase() == 'true') as T;
        } else if (T == String) {
          if (value != null) return value as T;
        }
      } else if (value is bool) {
        if (T == int) {
          if (value)
            return 1 as T;
          else
            return 0 as T;
        }
      }
    }

    return value;
  }

  List<dynamic> getValues<T>(List<dynamic> columnNames, [int rowIndex]) {
    List<int> columnIndexes = getColumnIndexes(columnNames);
    List<dynamic> values = new List<dynamic>();

    if (rowIndex != null) rowIndex = selectedRow;

    columnIndexes.forEach((columnIndex) {
      values.add(records[rowIndex][columnIndex]);
    });

    return values;
  }

  int getRowIndexWithFilter(Filter filter) {
    int rowIndex = -1;
    if (this.records != null &&
        filter.values != null &&
        filter.columnNames != null &&
        filter.values.length == filter.columnNames.length) {
      List<int> columnIndex = this.getColumnIndexes(filter.columnNames);
      for (int i = 0; i < this.records.length; i++) {
        dynamic r = this.records[i];
        if (r is List) {
          bool found = true;
          columnIndex.asMap().forEach((j, ci) {
            found = (r[ci] == filter.values[j]) & found;
          });

          if (found) {
            rowIndex = i;
            break;
          }
        }
      }
    }

    return rowIndex;
  }

  bool deleteLocalRecord(Filter filter) {
    int index = this.getRowIndexWithFilter(filter);
    if (index >= 0) {
      this.records.removeAt(index);
      return true;
    }

    return false;
  }

  DataBook.fromJson(Map<String, dynamic> json)
      : selectedRow = json['selectedRow'],
        isAllFetched = json['isAllFetched'],
        dataProvider = json['dataProvider'],
        records = json['records'],
        columnNames = json['columnNames'],
        from = json['from'],
        to = json['to'],
        super.fromJson(json);
}
