/// The class that defines the constants that are used to identify generic
/// SQL types, called JDBC types.
///
/// This class is never instantiated.
class Types {
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

  static String convertToSQLite(int dataType) {
    switch (dataType) {
      case NULL:
        return "NULL";
      case BIT:
      case TINYINT:
      case SMALLINT:
      case INTEGER:
      case BIGINT:
      case BOOLEAN:
        return "INTEGER";
      case FLOAT:
      case REAL:
      case DOUBLE:
      case NUMERIC:
      case DECIMAL:
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
      case TIMESTAMP:
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
