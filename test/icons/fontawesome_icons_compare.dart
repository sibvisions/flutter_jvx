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

import 'dart:io';

void main() async {
    String homeDir;
    if (Platform.isWindows) {
        homeDir = Platform.environment['USERPROFILE']!;
    } else {
        homeDir = Platform.environment['HOME']!;
    }

    final fileFontAwesome = File('$homeDir/.pub-cache/hosted/pub.dev/font_awesome_flutter-10.12.0/lib/font_awesome_flutter.dart');
    final regexFontAwesome = RegExp(r'static const IconData (\w+)');

    final iconNamesFontAwesome = <String>{};

    final lines = fileFontAwesome.readAsLinesSync();

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      // If previous line contains @Deprecated -> ignore
      if (i > 0 && lines[i - 1].contains('@Deprecated')) {
        continue;
      }

      final match = regexFontAwesome.firstMatch(line);
      if (match != null) {
        iconNamesFontAwesome.add("FontAwesomeIcons.${match.group(1)!}");
      }
    }

    final fileMapping = File('lib/src/util/font_awesome_util.dart');

    // "key": FontAwesomeIcons.xyz,
    final regexMapping = RegExp(r'"([^"]+)"\s*:\s*(FontAwesomeIcons\.[A-Za-z0-9_]+)');
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