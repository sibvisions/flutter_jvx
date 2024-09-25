/*
 * Copyright 2022 SIB Visions GmbH
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

extension StringExtension on String {

  ///First character upper-case, all other characters lower-case.
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

  ///First character lower-case, all other characters untouched.
  String firstCharLower() {
    return "${this[0].toLowerCase()}${substring(1)}";
  }

  ///Splits all elements by [delimiter] and supports quoting of elements by '.
  List<String> asList(String delimiter) {
    List<String> list = [];

    int first = 0;
    int last = 0;
    bool quote = false;

    for (int i = 0; i < codeUnits.length; i++, last++) {
      String char = String.fromCharCode(codeUnits[i]);
      if (char == ";") {
        if (!quote) {
          list.add(substring(first, last).replaceAll("'", ""));

          first = i + 1;
          last = i;
        }
      }
      else if (char == "'") {
        quote = !quote;
      }
    }

    return list;
  }
}
