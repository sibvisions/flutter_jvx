/* Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

/// The class that defines the constants that are used to identify generic
/// SQL types, called JDBC types.
///
/// This class is never instantiated.
abstract class Types {
  static const int BIT = -7;

  static const int TINYINT = -6;

  static const int SMALLINT = 5;

  static const int INTEGER = 4;

  static const int BIGINT = -5;

  static const int FLOAT = 6;

  static const int REAL = 7;

  static const int DOUBLE = 8;

  static const int NUMERIC = 2;

  static const int DECIMAL = 3;

  static const int CHAR = 1;

  static const int VARCHAR = 12;

  static const int LONGVARCHAR = -1;

  static const int DATE = 91;

  static const int TIME = 92;

  static const int TIMESTAMP = 93;

  static const int BINARY = -2;

  static const int VARBINARY = -3;

  static const int LONGVARBINARY = -4;

  static const int NULL = 0;

  static const int OTHER = 1111;

  static const int JAVA_OBJECT = 2000;

  static const int DISTINCT = 2001;

  static const int STRUCT = 2002;

  static const int ARRAY = 2003;

  static const int BLOB = 2004;

  static const int CLOB = 2005;

  static const int REF = 2006;

  static const int DATALINK = 70;

  static const int BOOLEAN = 16;

  static const int ROWID = -8;

  static const int NCHAR = -15;

  static const int NVARCHAR = -9;

  static const int LONGNVARCHAR = -16;

  static const int NCLOB = 2011;

  static const int SQLXML = 2009;

  /// Transforms a server given [dataType] to an SQLite-conform datatype.
  static String convertToSQLite(int dataType, {int? scale}) {
    switch (dataType) {
      case NULL:
        return "NULL";
      case BIT:
      case TINYINT:
      case SMALLINT:
      case INTEGER:
      case BIGINT:
      case BOOLEAN:
      case TIMESTAMP:
        return "INTEGER";
      case FLOAT:
      case REAL:
      case DOUBLE:
      case NUMERIC:
      case DECIMAL:
        if (scale == 0) {
          return "INTEGER";
        }
        return "REAL";
      case BINARY:
      case VARBINARY:
      case LONGVARBINARY:
      case JAVA_OBJECT:
      case BLOB:
        return "BLOB";

      //Date/Time
      case DATE:
      case TIME:
      //Text
      case CHAR:
      case VARCHAR:
      case LONGVARCHAR:
      case CLOB:
      case NCHAR:
      case NVARCHAR:
      case LONGNVARCHAR:
      case NCLOB:
      case SQLXML:
      //Fallback
      default:
        return "TEXT";
    }
  }
}
