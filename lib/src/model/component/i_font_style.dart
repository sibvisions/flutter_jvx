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

class JVxFont {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The plain style constant.
  static const int TEXT_PLAIN = 0;

  /// The bold style constant.  This can be combined with the other style
  /// constants (except PLAIN) for mixed styles.
  static const int TEXT_BOLD = 1;

  /// The italicized style constant.  This can be combined with the other
  /// style constants (except PLAIN) for mixed styles.
  static const int TEXT_ITALIC = 2;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The font of the component.
  String fontName = "Default";

  /// The size of the component.
  int fontSize = 14;

  /// If the component is bold;
  bool isBold = false;

  /// If the component is italic.
  bool isItalic = false;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  JVxFont({String? fontName, int? fontSize, bool? isBold, bool? isItalic}) {
    if (fontName != null && fontName.isNotEmpty) this.fontName = fontName;
    if (fontSize != null) this.fontSize = fontSize;
    if (isBold != null) this.isBold = isBold;
    if (isItalic != null) this.isItalic = isItalic;
  }

  JVxFont.fromString(String? pFontString) {
    if (pFontString == null || pFontString.isEmpty) return;

    var fontValuesList = pFontString.split(",");
    if (fontValuesList.length == 3) {
      if (fontValuesList[0].isNotEmpty) {
        fontName = fontValuesList[0];
      }
      if (fontValuesList[2].isNotEmpty && int.tryParse(fontValuesList[2]) != null) {
        fontSize = int.parse(fontValuesList[1]);
      }
      if (fontValuesList[1].isNotEmpty && int.tryParse(fontValuesList[1]) != null) {
        isBold = int.parse(fontValuesList[1]) & TEXT_BOLD == TEXT_BOLD;
        isItalic = int.parse(fontValuesList[1]) & TEXT_ITALIC == TEXT_ITALIC;
      }
    }
  }
}
