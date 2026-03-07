/*
 * Copyright 2026 SIB Visions GmbH
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

import 'dart:convert';
import 'dart:io';

void main() async {
    final process = await Process.run('flutter', ['--version', '--machine']);
    if (process.exitCode != 0) return null;

    final jsonData = jsonDecode(process.stdout);
    String? flutterDir = jsonData['flutterRoot'] as String?;


    final fileFontAwesome = File('$flutterDir/packages/flutter/lib/src/material/icons.dart');
    final regexFontAwesome = RegExp(r'static const IconData (\w+)');

    final iconNamesFontAwesome = <String>{};

    final lines = fileFontAwesome.readAsLinesSync();

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      final match = regexFontAwesome.firstMatch(line);
      if (match != null) {
        iconNamesFontAwesome.add("Icons.${match.group(1)!}");
      }
    }

    final fileMapping = File('lib/src/util/material_icons_util.dart');

    // 'key': Icons.xyz,
    final regexMapping = RegExp(r"'([^']+)'\s*:\s*(Icons\.[A-Za-z0-9_]+)");
    final iconsMapped = <String, String>{};

    for (final line in fileMapping.readAsLinesSync()) {
      final match = regexMapping.firstMatch(line);
      if (match != null) {
        iconsMapped[match.group(1)!] = match.group(2)!;
      }
    }

    final iconsNamesMissingInMapping = iconNamesFontAwesome.difference(iconsMapped.values.toSet());

    final result = <String, String>{};

    for (final element in iconsNamesMissingInMapping) {
      final name = element.split('.')[1]; // z.B. "zero"

      if (iconsMapped.containsKey(name)) {
        print("Key $name already mapped as ${iconsMapped[name]} instead of $element");
      }
      else {
        result[name] = element; // "zero" -> FontAwesomeIcons.zero
      }
    }

    if (result.isNotEmpty) {
      //Sort keys
      final sortedResultKeys = result.keys.toList()..sort();

      print("\nMissing icons (sorted):\n");

      for (final key in sortedResultKeys) {
        print('"$key": ${result[key]},');
      }
    }

    /*
    //We sort already mapped icon names -> only useful if we don't have ALL icons mapped

    final sortedMappingKeys = iconsMapped.keys.toList()..sort();

    print("\nMapped icons (sorted):\n");

    for (final key in sortedMappingKeys) {
        print('"$key": ${iconsMapped[key]},');
    }
    */
}