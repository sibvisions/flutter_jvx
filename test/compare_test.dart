/*
 * Copyright 2025 SIB Visions GmbH
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

    if (kDebugMode) {
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
}