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
    File sourceFile = File("test/html/template_new.html");
    File targetFile = File("test/html/safe.html");

    String template = await sourceFile.readAsString();

    String content = '''
<style>
  .search-wrapper {
    display: flex;
    gap: 10px;
    margin-top: 2rem;
    margin-bottom: 1.5rem;
    width: 100%;
  }

  #searchInput {
    flex: 5; 
    background: #f1f5f9 !important; 
    color: #1e293b !important;
    border: 1px solid #cbd5e1 !important;
    margin: 0; 
    padding: 0.75rem;  
    border-radius: 3px;
  }
  
  #searchInput::placeholder {
    color: #94a3b8;
  }

  #searchClear {
    flex: 1;
    padding: 0.75rem;
    background: #64748b;
    color: white;
    border: none;
    border-radius: 0.5rem;
    font-weight: 600;
    cursor: pointer;
    white-space: nowrap;     
  }
  
  #searchClear:hover {
    background: #475569;
  }  

  .custom-table th.searching {
    background-color: #f0fdf4 !important; 
    border-bottom: 3px solid #22c55e !important; 
    color: #1e293b !important;
     
    transition: all 0.3s ease;
  }  

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

<div class="search-wrapper">
    <input type="text" id="searchInput" class="table-search" placeholder="Enter search value">
    <button id="searchClear" class="clear-btn">Clear</button>
</div>

<table class="custom-table">
  <tr><th>First name</th><th>Last name</th><th>Last name</th><th>Last name</th><th>Last name</th></tr>
  <tr><td>John</td><td>Doe</td><td>Doe</td><td>Doe</td><td style="text-align: right;">Doe John Doe John</td></tr>
  <tr><td>Jane</td><td>Doe</td><td>Doe</td><td>Doe</td><td style="text-align: right;">Doe</td></tr>
  <tr><td>Marc</td><td>Marc</td><td>Marc</td><td>Marc</td><td>Marc</td></tr>
</table>  

<script>
    (function() {
        const input = document.getElementById('searchInput');
        const btn = document.getElementById('searchClear');
        const table = document.querySelector(".custom-table");

        // Alread initialized or missing elements -> stop
        if (!input || !table || input.dataset.initialized === "true") {
            return; 
        }

        // Mark initialized and avoid multiple initialization
        input.dataset.initialized = "true";

        const rows = Array.from(table.querySelectorAll("tr")).slice(1);
        const headers = table.querySelectorAll("th");

        const performFilter = () => {
            const filter = input.value.toLowerCase();
            const isSearching = filter.length > 0;

            headers.forEach(th => {
                isSearching ? th.classList.add('searching') : th.classList.remove('searching');
            });

            rows.forEach(row => {
                row.style.display = row.textContent.toLowerCase().includes(filter) ? "" : "none";
            });
        };

        input.addEventListener('input', performFilter);
        
        if(btn) {
            btn.addEventListener('click', () => {
                input.value = '';
                performFilter();
                input.focus();
            });
        }
        
        console.log("Search successfully bound.");
    })();
</script> 
''';

    String result = await HtmlVault.create(htmlContent: content, password: 'test123', template: template);

    await targetFile.writeAsString(result);

    print("Success ${targetFile.path}");
  } catch (e) {
    print("Conversion Error: $e");
  }
}
