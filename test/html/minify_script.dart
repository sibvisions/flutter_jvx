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
import 'package:html/parser.dart' show parse;

// REQUIRES
// npm install -g javascript-obfuscator

void main() async {
  final file = File('test/html/template.html');
  final tempIn = File('test/html/__temp_js_in.js');
  final tempOut = File('test/html/__temp_js_out.js');

  if (!await file.exists()) {
    print("Template not found!");
    return;
  }

  try {
    String htmlContent = await file.readAsString();
    var document = parse(htmlContent);

    var scriptTag = document.querySelector('script');

    if (scriptTag == null) {
      print("No Script-Tag found!");
      return;
    }

    print("Replacing placeholder");

    // Replace placeholder because our $ placeholders are not good
    String preparedJs = scriptTag.text
      .replaceAll('\$salt', 'PLACEHOLDER_SALT')
      .replaceAll('\$iv', 'PLACEHOLDER_IV')
      .replaceAll('\$mac', 'PLACEHOLDER_MAC')
      .replaceAll('\$data', 'PLACEHOLDER_DATA')
      //use unique number
      .replaceAll('\$_iterations', '"PLACEHOLDER_ITER"')
      .replaceAll('\$_bits', '"PLACEHOLDER_BITS"');

    print("Creating temp file ${tempIn.absolute}");

    await tempIn.writeAsString(preparedJs);

    print("Starting javascript-obfuscator ...");

    final result = await Process.run(
      'javascript-obfuscator',
      [
        tempIn.path,
        '--output', tempOut.path,
        '--compact', 'true',
        '--control-flow-flattening', 'true',
        '--control-flow-flattening-threshold', '1',
        '--numbers-to-expressions', 'true',
        '--string-array', 'true',
        '--string-array-encoding', 'base64',
        '--simplify', 'true',
        // Important: keep unlock()
        '--rename-globals', 'false',
        '--identifier-names-generator', 'hexadecimal',
        // don't replace our placeholder
        '--reserved-strings', 'PLACEHOLDER_SALT,PLACEHOLDER_IV,PLACEHOLDER_MAC,PLACEHOLDER_DATA,PLACEHOLDER_ITER,PLACEHOLDER_BITS'
      ],
      runInShell: true
    );

    if (result.exitCode != 0) {
      print("Obfuscator error: ${result.stderr}");
      return;
    }

    // Read result and replace placeholders
    if (await tempOut.exists()) {
      String obfuscatedJs = await tempOut.readAsString();

      String finalJs = obfuscatedJs
        .replaceAll('PLACEHOLDER_SALT', '\$salt')
        .replaceAll('PLACEHOLDER_IV', '\$iv')
        .replaceAll('PLACEHOLDER_MAC', '\$mac')
        .replaceAll('PLACEHOLDER_DATA', '\$data')
        .replaceAll('\'PLACEHOLDER_ITER\'', '\$_iterations')
        .replaceAll('\'PLACEHOLDER_BITS\'', '\$_bits');

      scriptTag.text = finalJs;

      final outputFile = File('test/html/template_new.html');
      await outputFile.writeAsString(document.outerHtml);

      print("Done! Saved to ${outputFile.absolute}");
    }
  } catch (e) {
    print("An error occurred: $e");
  } finally {
    // cleanup
    if (await tempIn.exists()) await tempIn.delete();
    if (await tempOut.exists()) await tempOut.delete();
  }
}