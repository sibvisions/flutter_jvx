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

import 'package:flutter/material.dart';

import '../model/command/api/fetch_command.dart';
import '../model/data/column_definition.dart';
import '../model/data/data_book.dart';
import '../service/command/i_command_service.dart';
import '../service/data/i_data_service.dart';
import '../service/ui/i_ui_service.dart';
import 'html_vault.dart';
import 'i_types.dart';

abstract class DataBookUtil {

  /// Creates a html vault for records
  static Future<String?> exportAsHtmlVault(String title, String dataProvider, List<String>? columnNames, String? password) async {
    DataBook? book = IDataService().getDataBook(dataProvider);

    if (book != null) {
      String? contentPassword = password ?? await IUiService().getInput("File password", "Password", true, icon: Icons.save_outlined);

      if (contentPassword == null || contentPassword.isEmpty) {
        return null;
      }

      List<String>? columnNamesForTable = columnNames ?? book.metaData?.columnDefinitions.listNames;

      if (columnNamesForTable != null) {
        if (!book.isAllFetched) {
          await ICommandService().sendCommand(
              FetchCommand(
                  reason: "Fetching data for export on device",
                  dataProvider: book.dataProvider,
                  fromRow: book.records.length,
                  rowCount: -1
              )
          );
        }

        //copy asap
        Map<int, List<dynamic>> recordCopy = Map.of(book.records);

        StringBuffer html = StringBuffer();

        html.write(
            '''
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
          '''
        );

        html.write("<p class='title'>$title</p>");

        //Search

        html.write(
            '''
          <div class="search-wrapper">
          <input type="text" id="searchInput" class="table-search" placeholder="Enter search value">
          <button id="searchClear" class="clear-btn">Clear</button>
          </div>
          '''
        );

        // Header

        List<String> columnNamesCopy = List.of(columnNamesForTable);

        List<String> headers = [];
        Map<String, String> alignments = {};

        html.write("<table class='custom-table'><tr>");

        for (String name in columnNamesCopy) {
          if (book.metaData != null) {
            ColumnDefinition? colDef = book.metaData!.columnDefinitions.byName(name);

            if (colDef != null) {
              html.write("<th>${colDef.label}</th>");

              if (colDef.dataTypeIdentifier == ITypes.DECIMAL
                  || colDef.dataTypeIdentifier == ITypes.BIGINT) {
                alignments[name] = "right";
              }
              else {
                alignments[name] = "left";
              }
            }
            else {
              //no column definition -> don't export
              columnNamesForTable.remove(name);
            }
          }
          else {
            alignments[name] = "left";

            //no metadata -> try to export
            headers.add(name);
          }
        }

        html.write("</tr>");

        // Records
        List<dynamic>? record;

        bool replaceOriginalValue = true;

        for (int i = 0; i < recordCopy.length; i++) {
          record = recordCopy[i];

          if (record != null) {
            int? idx;

            html.write("<tr>");

            for (String name in columnNamesForTable) {
              html.write("<td style='text-align: ${alignments[name]};'>");

              idx = book.metaData?.columnDefinitions.indexByName(name);

              if (idx != null && idx >= 0) {
                dynamic oldValue = record[idx];

                if (oldValue != null) {

                  record[idx] = await book.checkAndDecryptValue(oldValue);

                  //replace with encrypted value as long as original object instance exists

                  if (replaceOriginalValue) {
                    //as long as the original value is the same object instance -> update
                    if (identical(book.records[i]?[idx], oldValue)) {
                      book.records[i]![idx] = record[idx];
                    }
                    else {
                      //stop with replacing after first problem
                      // (maybe a new record was inserted)
                      replaceOriginalValue = false;
                    }
                  }
                }

                html.write(record[idx] ?? "");
              }
              else {
                html.write("");
              }

              html.write("</td>");
            }

            html.write("</tr>");
          }
        }

        html.write("</table>");

        html.write(
            '''
          <script>
              (function() {
                  const input = document.getElementById('searchInput');
                  const btn = document.getElementById('searchClear');
                  const table = document.querySelector(".custom-table");
          
                  // Already initialized or missing elements -> stop
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
          '''
        );

        return HtmlVault.create(htmlContent: html.toString(), password: contentPassword);
      }
    }

    return null;
  }
}
