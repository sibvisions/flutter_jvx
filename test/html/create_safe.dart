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

import 'package:flutter_jvx/src/util/html_vault.dart';

void main() async {
  try {
    File sourceFile = File("test/html/template.html");
    File targetFile = File("test/html/safe.html");

    String template = await sourceFile.readAsString();

    String content = '''
<style>
  .custom-table {
    -webkit-overflow-scrolling: touch; 
    overflow-x: auto; 
    width: 100%;
    border-collapse: separate;
    border-spacing: 0;
    border: 1px solid #d1d1d1;
    border-radius: 12px;
    overflow: hidden;
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  }

  .custom-table th, 
  .custom-table td {
    padding: 14px;
    text-align: left;
    border-bottom: 1px solid #d1d1d1;
    border-right: 1px solid #d1d1d1;
  }

  /* remove right border of last column */
  .custom-table th:last-child, 
  .custom-table td:last-child {
    border-right: none;
  }

  /* remove bottom border or last row */
  .custom-table tr:last-child td {
    border-bottom: none;
  }

  /* header */
  .custom-table th {
    background-color: #ececec;
    color: #444;
    font-weight: 600;
  }

  /* odd/even background */
  .custom-table tbody tr:nth-child(odd) {
    background-color: #fcfcfc;
  }

  /* hover for visibility */
  .custom-table tbody tr:hover {
    background-color: #f5f5f5;
  }
  
  p.title {
    margin-top: 0;
    font-size: 17px;
    font-weight: 600;
    margin-bottom: 20px;
  }
</style>

<p class="title">Contacts</p>
<table class="custom-table">
  <tr><th>First name</th><th>Last name</th><th>Last name</th><th>Last name</th><th>Last name</th></tr>
  <tr><td>John</td><td>Doe</td><td>Doe</td><td>Doe</td><td>Doe</td></tr>
  <tr><td>Jane</td><td>Doe</td><td>Doe</td><td>Doe</td><td>Doe</td></tr>
  <tr><td>Marc</td><td>Marc</td><td>Marc</td><td>Marc</td><td>Marc</td></tr>
</table>    
''';

    String result = await HtmlVault.create(htmlContent: content, password: 'test123', template: template);

    await targetFile.writeAsString(result);

    print("Success ${targetFile.path}");
  } catch (e) {
    print("Conversion Error: $e");
  }
}
