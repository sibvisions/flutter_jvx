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

<p class="title">Contacts</p>

<div class="search-wrapper">
    <input type="text" id="searchInput" class="table-search" placeholder="Enter search value">
    <button id="searchClear" class="clear-btn">Clear</button>
</div>

<table class="custom-table">
  <tr><th>First name</th><th>Last name</th><th>Last name</th><th>Last name</th><th>Last name</th><th>Image</th></tr>
  <tr><td>John</td><td>Doe</td><td>Doe</td><td>Doe</td><td style="text-align: right;">Doe John Doe John</td><td></td></tr>
  <tr><td>Jane</td><td>Doe</td><td>Doe</td><td>Doe</td><td style="text-align: right;">Doe</td><td><span class="image-link" onclick="openModal('data:image/svg+xml;utf8,<svg xmlns=&quot;http://www.w3.org/2000/svg&quot; viewBox=&quot;0 0 272 92&quot; width=&quot;272&quot; height=&quot;92&quot;><path fill=&quot;%234285F4&quot; d=&quot;M58.1 46.1c0-12.9-10.3-23.3-23.2-23.3S11.7 33.2 11.7 46.1s10.3 23.3 23.2 23.3c12.9.1 23.2-10.3 23.2-23.3zm-8.3 0c0 8.6-6.1 15-14.9 15s-14.9-6.4-14.9-15 6.1-15 14.9-15 14.9 6.4 14.9 15z&quot;/><path fill=&quot;%23EA4335&quot; d=&quot;M108.3 46.1c0-12.9-10.3-23.3-23.2-23.3s-23.2 10.4-23.2 23.3 10.3 23.3 23.2 23.3c12.9.1 23.2-10.3 23.2-23.3zm-8.3 0c0 8.6-6.1 15-14.9 15s-14.9-6.4-14.9-15 6.1-15 14.9-15 14.9 6.4 14.9 15z&quot;/><path fill=&quot;%23FBBC05&quot; d=&quot;M157.5 46.5c0-12.3-9.5-23.7-22.7-23.7s-22.7 11.2-22.7 23.7 9.5 23.3 22.7 23.3c13.2 0 22.7-11 22.7-23.3zm-8.2-.4c0 7.9-5.5 15.3-14.5 15.3s-14.5-7.4-14.5-15.3 5.5-15.3 14.5-15.3 14.5 7.4 14.5 15.3z&quot;/><path fill=&quot;%234285F4&quot; d=&quot;M204.6 47.9V24.5h-8.3v3.1c-2.4-2.8-6.6-5.1-12.1-5.1-11.4 0-21.6 9.9-21.6 23.4s10.2 23.3 21.6 23.3c5.5 0 9.7-2.3 12.1-5.2v3.1c0 8.9-4.8 13.7-12.5 13.7-6.3 0-10.2-4.5-11.8-8.3l-7.2 3c2.1 5.1 7.7 11.3 19 11.3 12.1 0 22.3-7.1 22.3-24.3zm-8.1-4.1c0 7.9-5.4 13.7-13 13.7s-13-5.8-13-13.7 5.4-13.7 13-13.7 13 5.8 13 13.7z&quot;/><path fill=&quot;%2334A853&quot; d=&quot;M215.1 13.8h8.3V68h-8.3z&quot;/><path fill=&quot;%23EA4335&quot; d=&quot;M258.9 52.8l7-4.7c-2.2-3.3-7.6-9.1-16.7-9.1-10.6 0-19.1 8.3-19.1 20.3 0 12.6 8.6 20.3 18.2 20.3 7.8 0 12.3-4.8 14.6-8.3l-5.8-3.9c-1.9 2.8-4.5 5.2-8.8 5.2-5 0-8.2-2.3-9.6-5.5l25.9-10.7-1-.3zm-19.1 5.9c.9-3 3.6-5.2 6.8-5.2 2.2 0 4.2 1.1 5 2.8l-11.8 4.9v-2.5z&quot;/></svg>')">
  Show image</span></td></tr>
  <tr><td>Marc</td><td>Marc</td><td>Marc</td><td>Marc</td><td>Marc</td><td></td></tr>
</table>  

<div id="modalimage" class="modal" onclick="closeModal()">
  <div class="modal-wrapper" onclick="event.stopPropagation()">
    <span class="close-btn" onclick="closeModal()">&times;</span>
    <img class="modal-content" id="modalimage-img">
  </div>
</div>

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
