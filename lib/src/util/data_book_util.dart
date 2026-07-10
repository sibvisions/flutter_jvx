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

import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../flutter_ui.dart';
import '../model/command/api/fetch_command.dart';
import '../model/component/editor/cell_editor/cell_editor_model.dart';
import '../model/component/editor/cell_editor/date/fl_date_cell_editor_model.dart';
import '../model/data/column_definition.dart';
import '../model/data/data_book.dart';
import '../service/api/shared/fl_component_classname.dart';
import '../service/command/i_command_service.dart';
import '../service/config/i_config_service.dart';
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
            
            .image-link {
              color: #1a73e8;
              text-decoration: none;
              font-weight: bold;
              cursor: pointer;
              display: inline-flex;
              align-items: center;
              gap: 5px;
              
              -webkit-tap-highlight-color: transparent;
            }
          
            @media (hover: hover) {
              .image-link:hover {
                  text-decoration: underline;
                  color: #1557b0;
              }
            }
            
            .image-link:active {
              text-decoration: none; 
              opacity: 0.7;
            }
          
            /* don't scroll background if modal layer is visible */
            body.modal-open {
                overflow: hidden;
                position: fixed;
                width: 100%;
            }
            
            .modal {
              display: none !important;
              position: fixed;
              z-index: 1000;
              left: 0;
              top: 0;
              width: 100%;
              height: 100%;
              background-color: rgba(0, 0, 0, 0.85);
              
              /* Support scrolling if image is too high */
              overflow-y: auto;
              -webkit-overflow-scrolling: touch;
              
              display: flex;
              justify-content: center;
              align-items: flex-start; /* no image cut */
              padding: 40px 10px; /* placeholder for x and scrolling */
              box-sizing: border-box;
            }
            
            .modal.is-active {
                display: flex !important;
            }
            
            .modal-wrapper {
              position: relative;
              max-width: 90%; 
              margin: auto 0;
            }
            
            .modal-content {
              max-width: 100%;

              height: auto;
              max-height: 85vh; 
              display: block;
              box-shadow: 0 4px 15px rgba(0,0,0,0.5);
              border: 3px solid white;
              background-color: white;
              cursor: default;
            }
            
            .close-btn {
              position: absolute;
              top: -15px;
              right: -15px;
              color: white;
              background-color: #333;
              border: 2px solid white;
              border-radius: 50%;
              width: 30px;
              height: 30px;
              font-size: 20px;
              line-height: 26px;
              text-align: center;
              font-weight: bold;
              cursor: pointer;
              z-index: 1010;
            }    
          </style>
          '''
        );

        html.write("<p class='title'>$title</p>");

        //Search

        html.write(
          '''
          <div class="search-wrapper">
            <input type="text" id="searchInput" class="table-search" placeholder="${FlutterUI.translate('Enter search value')}">
            <button id="searchClear" class="clear-btn">${FlutterUI.translate('Clear')}</button>
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

            Map<ColumnDefinition, ICellEditorModel> modelCache = HashMap<ColumnDefinition, ICellEditorModel>();

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

                html.write(_formatValue(book.metaData!.columnDefinitions[idx], modelCache, record[idx]) ?? "");
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

        //image overlay
        html.write(
          '''
          <div id="modalimage" class="modal" onclick="closeModal()">
            <div class="modal-wrapper" onclick="event.stopPropagation()">
              <span class="close-btn" onclick="closeModal()">&times;</span>
              <img class="modal-content" id="modalimage-img">
            </div>
          </div>
          '''
        );

        html.write(
          '''
          <script>
              function openModal(imageSrc) {
                  var modal = document.getElementById("modalimage");
                  var modalImg = document.getElementById("modalimage-img");
                  
                  modal.style.display = "flex";
                  modalImg.src = imageSrc;
                  
                  modal.classList.add("is-active");
                  document.body.classList.add("modal-open");
              }
          
              function closeModal() {
                  var modal = document.getElementById("modalimage");
                  
                  modal.style.display = "none";
                  
                  modal.classList.remove("is-active");
                  document.body.classList.remove("modal-open");
              }
          
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

  /// Formats a record value as string
  static dynamic _formatValue(ColumnDefinition columnDefinition, Map<ColumnDefinition, ICellEditorModel> modelCache, dynamic value) {
    if (value == null) {
      return value;
    }

    if (columnDefinition.dataTypeIdentifier == ITypes.ENCODED_BINARY ||
        columnDefinition.dataTypeIdentifier == ITypes.BINARY) {
      if (columnDefinition.cellEditorClassName == FlCellEditorClassname.TEXT_CELL_EDITOR
          || columnDefinition.cellEditorClassName == FlCellEditorClassname.LINKED_CELL_EDITOR) {
        if (value is Uint8List) {
          return utf8.decode(value);
        }
      }
      else if (columnDefinition.cellEditorClassName == FlCellEditorClassname.IMAGE_VIEWER) {
        if (value is Uint8List) {
          return
            '''
              <span class="image-link" onclick="openModal('data:image/png;base64,${base64.encode(value)}')">${FlutterUI.translate('Show image')}</span>
            ''';
        }
      }

      return FlutterUI.translate("&lt;binary&gt;");
    }
    else if (columnDefinition.dataTypeIdentifier == ITypes.TIMESTAMP) {
      FlDateCellEditorModel? model = modelCache[columnDefinition] as FlDateCellEditorModel?;

      if (model == null) {
        model = FlDateCellEditorModel()
          ..applyFromJson(columnDefinition.cellEditorJson);

        modelCache[columnDefinition] = model;
      }

      return DateFormat(model.dateFormat, model.locale ?? IConfigService().getLanguage()).format(
        tz.TZDateTime.fromMillisecondsSinceEpoch(tz.getLocation(model.timeZoneCode ?? IConfigService().getTimezone()), value)
      );
    }

    return value;
  }
}
