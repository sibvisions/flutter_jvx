import 'package:flutter/foundation.dart';

void main() {
    int one = 1;
    int two = 2;
    int one2 = 1;

    String first = "first";
    String second = "second";
    String first2 = "first";

    List<String> list = ["1", "2", "3"];
    List<String> list2 = ["1", "2", "3"];
    List<String> list3 = ["3", "2", "1"];

    DateTime date = DateTime.fromMillisecondsSinceEpoch(500);
    DateTime date2 = DateTime.fromMillisecondsSinceEpoch(500);

    print("== checks");
    print("${one == one2} ${one == two}");
    print("${first == first2} ${second == first2}");
    print("${list == list2} ${listEquals(list, list2)} ${listEquals(list, list3)}");
    print("${date == date2}");
    print("${null == null} ${null != null}");

    print("");
    print("Identical checks");
    print("${identical(one, one2)}");
    print("${identical(null, null)}");
    print("${identical(first, first2)}");
    print("${identical(date, date2)}");
}