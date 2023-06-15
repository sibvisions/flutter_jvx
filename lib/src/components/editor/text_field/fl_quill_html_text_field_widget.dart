// /*
//  * Copyright 2023 SIB Visions GmbH
//  *
//  * Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  * use this file except in compliance with the License. You may obtain a copy of
//  * the License at
//  *
//  * http://www.apache.org/licenses/LICENSE-2.0
//  *
//  * Unless required by applicable law or agreed to in writing, software
//  * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
//  * License for the specific language governing permissions and limitations under
//  * the License.
//  */
//
// import 'package:flutter/material.dart';
// import 'package:quill_html_editor/quill_html_editor.dart';
//
// import '../../../components.dart';
// import '../../../model/component/fl_component_model.dart';
//
// class FlQuillHtmlTextFieldWidget<T extends FlTextFieldModel> extends FlStatelessDataWidget<T, String> {
//   //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//   // Class members
//   //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
//   /// The [QuillEditorController] of the [QuillHtmlEditor] widget.
//   final QuillEditorController htmlController;
//
//   /// The [Function] that is called when the [QuillHtmlEditor] widget is initialized.
//   ///
//   /// Only after the initialization is complete can the controller be used.
//   final Function()? onInit;
//
//   /// The [FocusNode] of the [QuillHtmlEditor] widget.
//   final FocusNode focusNode;
//
//   //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//   // Initialization
//   //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
//   const FlQuillHtmlTextFieldWidget({
//     super.key,
//     required super.model,
//     required super.valueChanged,
//     required super.endEditing,
//     required this.htmlController,
//     required this.focusNode,
//     this.onInit,
//   });
//
//   //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//   // Overridden methods
//   //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
//   @override
//   Widget build(BuildContext context) {
//     return Focus(
//       skipTraversal: true,
//       autofocus: false,
//       descendantsAreFocusable: true,
//       focusNode: focusNode,
//       child: Column(
//         children: [
//           ToolBar(controller: htmlController),
//           Expanded(
//             child: QuillHtmlEditor(
//               onEditorCreated: onInit,
//               controller: htmlController,
//               minHeight: 0.0,
//               hintText: model.placeholder ?? "",
//               isEnabled: !model.isReadOnly,
//               onFocusChanged: (focus) {
//                 if (focus && !focusNode.hasFocus) {
//                   focusNode.requestFocus();
//                 } else if (!focus && focusNode.hasFocus) {
//                   focusNode.unfocus();
//                 }
//               },
//               onTextChanged: valueChanged,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
