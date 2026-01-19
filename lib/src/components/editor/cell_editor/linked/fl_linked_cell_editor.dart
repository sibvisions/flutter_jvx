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
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../../../components.dart';
import '../../../../flutter_ui.dart';
import '../../../../model/command/api/filter_command.dart';
import '../../../../model/command/api/select_record_command.dart';
import '../../../../model/component/editor/cell_editor/cell_editor_model.dart';
import '../../../../model/component/editor/cell_editor/linked/fl_linked_cell_editor_model.dart';
import '../../../../model/component/editor/cell_editor/linked/reference_definition.dart';
import '../../../../model/component/fl_component_model.dart';
import '../../../../model/data/column_definition.dart';
import '../../../../model/data/subscriptions/data_subscription.dart';
import '../../../../service/command/i_command_service.dart';
import '../../../../service/data/i_data_service.dart';
import '../../../../service/ui/i_ui_service.dart';
import '../../../../util/jvx_colors.dart';
import '../../../../util/parse_util.dart';
import '../../../base_wrapper/base_comp_wrapper_widget.dart';
import '../i_cell_editor.dart';

class FlLinkedCellEditor extends IFocusableCellEditor<FlLinkedEditorModel, FlLinkedCellEditorModel, dynamic>
                         with WidgetsBindingObserver
{
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  (dynamic, List<dynamic>?)? _record;

  final LayerLink _layerLink = LayerLink();

  TextEditingController textController = TextEditingController();

  FlLinkedEditorModel? lastWidgetModel;

  ReferencedCellEditor? referencedCellEditor;

  bool isOpen = false;

  dynamic get _value => _record?.$1;

  @override
  bool get allowedTableEdit => model.preferredEditorMode == ICellEditorModel.SINGLE_CLICK;

  @override
  bool get tableDeleteIcon => !model.hideClearIcon && super.tableDeleteIcon;

  @override
  IconData? get tableEditIcon => FontAwesomeIcons.caretDown;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlLinkedCellEditor({
    required super.cellEditorJson,
    required super.name,
    required super.dataProvider,
    required super.columnName,
    required super.columnDefinition,
    super.isInTable,
    super.focusChecker,
    required super.onValueChange,
    required super.onEndEditing,
    super.onFocusChanged,
  }) : super(
          model: FlLinkedCellEditorModel(),
        ) {
    focusNode.skipTraversal = true;

    _subscribe();

    WidgetsBinding.instance.addObserver(this);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void setValue(dynamic pValue) {
    _record = pValue;

    _updateControllerValue();
  }

  @override
  FlLinkedEditorWidget createWidget(Map<String, dynamic>? pJson, [WidgetWrapper? pWrapper]) {
    FlLinkedEditorModel widgetModel = createWidgetModel();

    applyEditorJson(widgetModel, pJson);

    lastWidgetModel = widgetModel;

    return FlLinkedEditorWidget(
      link: _layerLink,
      model: widgetModel,
      endEditing: (_) => receiveNull(),
      valueChanged: onValueChange,
      textController: textController,
      focusNode: focusNode,
      hideClearIcon: model.hideClearIcon,
    );
  }

  @override
  createWidgetModel() => FlLinkedEditorModel();

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    IUiService().disposeDataSubscription(pSubscriber: this, pDataProvider: dataProvider);
    referencedCellEditor?.dispose();
    textController.dispose();
    super.dispose();
  }

  @override
  Future<dynamic> getValue() async {
    return _value;
  }

  @override
  String formatValue(Object? pValue) {
    Object? showValue = pValue;
    if (showValue == null) {
      return "";
    }

    if (model.displayConcatMask != null || model.displayReferencedColumnName != null) {
      ReferenceDefinition linkReference = effectiveLinkReference;

      int linkRefColumnIndex = linkReference.columnNames.indexOf(columnName);
      if (linkRefColumnIndex == -1) {
        // Invalid definition by the developer, Swing throws InvalidArgumentException.
        // Possible solution: just return value and ignore concatMask and others.
        linkRefColumnIndex = 0;
      }

      if (model.additionalCondition != null || model.searchColumnMapping != null) {
        var dataBook = IDataService().getDataBook(dataProvider);
        if (dataBook != null && _record?.$2 != null) {
          Map<String, dynamic> displayKeyMap = model.createDisplayMapKey(
            dataBook.metaData!.columnDefinitions,
            _record!.$2!,
            linkReference,
            columnName,
            dataProvider: dataProvider,
          );
          var displayKey = jsonEncode(displayKeyMap);

          if (linkReference.dataToDisplay.containsKey(displayKey)) {
            return linkReference.dataToDisplay[displayKey] ?? showValue.toString();
          }
        }
      }

      var fallbackDataKey = jsonEncode(
          model.createFallbackDisplayKey(linkReference.referencedColumnNames[linkRefColumnIndex], showValue));

      if (linkReference.dataToDisplay.containsKey(fallbackDataKey)) {
        return linkReference.dataToDisplay[fallbackDataKey] ?? showValue.toString();
      }
    }

    return showValue.toString();
  }

  @override
  double getContentPadding(Map<String, dynamic>? pJson) {
    return createWidget(pJson).extraWidthPaddings();
  }

  @override
  double getEditorWidth(Map<String, dynamic>? pJson) {
    FlLinkedEditorModel widgetModel = createWidgetModel();

    applyEditorJson(widgetModel, pJson);

    double colWidth = ParseUtil.getTextWidth(text: "w", style: widgetModel.createTextStyle());

    if (isInTable) {
      return colWidth * widgetModel.columns / 2;
    }
    return colWidth * widgetModel.columns;
  }

  @override
  double getEditorHeight(Map<String, dynamic>? pJson) {
    return FlTextFieldWidget.TEXT_FIELD_HEIGHT;
  }

  @override
  void handleFocusChanged(bool pHasFocus) {
    if (focusNode.hasPrimaryFocus && lastWidgetModel != null) {
      if (!lastWidgetModel!.isFocusable) {
        focusNode.unfocus();
      } else if (lastWidgetModel!.isEditable && lastWidgetModel!.isEnabled) {
        openLinkedCellPicker();

        focusNode.unfocus();
      }
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Future<void>? openLinkedCellPicker() {
    if (!isOpen) {
      if (lastWidgetModel != null && lastWidgetModel!.isFocusable) {
        onFocusChanged?.call(true);
      }
      isOpen = true;

      return ICommandService()
          .sendCommand(
        FilterCommand.byValue(
          dataProvider: model.linkReference.referencedDataBook,
          editorComponentId: (lastWidgetModel?.name.isNotEmpty ?? false) ? lastWidgetModel!.name : name,
          columnNames: [columnName],
          // Same as React
          value: "",
          reason: "Opened the linked cell picker",
        ),
      ).then((success) {
        if (!success) {
          return null;
        }

        Future<dynamic> future;

        bool bUseDefaultStyle = model.styles.contains(FlLinkedCellEditorModel.STYLE_AS_DIALOG);

        if (!bUseDefaultStyle && focusNode.context != null && model.styles.contains(FlLinkedCellEditorModel.STYLE_AS_POPUP)) {
          future = _showAsPopup();
        }
        else if (!bUseDefaultStyle && model.styles.contains(FlLinkedCellEditorModel.STYLE_AS_BOTTOMSHEET)) {
          future = _showAsBottomSheet();
        }
        else {
          future = IUiService().openDialog(
            pBuilder: (_) => FlLinkedCellPicker(
              linkedCellEditor: this,
              model: model,
              name: name!,
              editorColumnDefinition: columnDefinition,
            ),
            pIsDismissible: true,
          );
        }

        future = future.then((value) {
          if (value != null) {
            if (value == FlLinkedCellPicker.NULL_OBJECT) {
              receiveNull();
            } else {
              onEndEditing(value);
            }
          }
        });

        return future;
      }).whenComplete(() {
        isOpen = false;
        // The "onEndEditing" of the FlEditorWrapper handles the focus for the linked cell picker and date cell editor.
      });
    }

    return null;
  }

  Future<T?> _showAsPopup<T>() {
    //default popup height
    double prefPopupHeight = 400;

    //we need the databook for height calculation, only if all records are fetched
    var dataBook = IDataService().getDataBook(model.linkReference.referencedDataBook);

    if (dataBook?.isAllFetched == true) {
      int records = dataBook?.records.length ?? 0;

      if (records == 0) {
        //simulate height for 1 record if empty -> looks better
        records = 1;
      }
      //90 = padding.top + padding.bottom + 2 (table border) + gap + buttons
      if (records < FlLinkedCellPicker.MIN_ROWS_FOR_SEARCH) {
        double rowHeight = JVxColors.componentHeight() + 2;

        prefPopupHeight = 90 + (records * rowHeight) + (rowHeight / 2);
      }
    }

    bool bUseDefault = model.styles.contains(FlLinkedCellEditorModel.STYLE_POPUP_FADE_IN_BOUNCE);

    if (!bUseDefault) {
      if (model.styles.contains(FlLinkedCellEditorModel.STYLE_POPUP_FADE_IN_ROLL_DOWN)) {
        return Navigator.push(
          FlutterUI.getCurrentContext()!,
          PageRouteBuilder(
            opaque: false,
            barrierDismissible: true,
            barrierColor: Colors.black.withValues(alpha: 0.1),
            pageBuilder: (context, animation, secondaryAnimation) {
              Rect rect = getPopupRect(prefPopupHeight);

              return Stack(
                children: [
                  Positioned(
                    top: rect.top,
                    left: rect.left,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      builder: (context, value, _) {

                        return Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(8),
                          clipBehavior: Clip.antiAlias,
                          child: SizedBox(
                            width: rect.width,
                            height: rect.height * value,
                            child: Opacity(
                                opacity: value.clamp(0.0, 1.0),
                                child: OverflowBox(
                                  fit: OverflowBoxFit.max,
                                  maxHeight: max(200, rect.height * value),
                                  child:
                                  FlLinkedCellPicker(
                                    linkedCellEditor: this,
                                    scrollToSelected: value == 1,
                                    model: model,
                                    name: name!,
                                    editorColumnDefinition: columnDefinition,
                                    embeddable: true,
                                    showTitle: false,
                                  ),
                                )
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }
      else if (model.styles.contains(FlLinkedCellEditorModel.STYLE_POPUP_JUMP)) {
        return Navigator.push(
          FlutterUI.getCurrentContext()!,
          PageRouteBuilder(
            opaque: false,
            barrierDismissible: true,
            barrierColor: Colors.black.withValues(alpha: 0.1),
            pageBuilder: (context, animation, secondaryAnimation) {
              Rect rect = getPopupRect(prefPopupHeight);

              return Stack(
                children: [
                  Positioned(
                      top: rect.top,
                      left: rect.left,
                      width: rect.width,
                      height: rect.height,
                      child:
                      ScaleTransition(
                        scale: CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutBack,
                        ),
                        child: FadeTransition(
                          opacity: animation,
                          child: Material(
                              elevation: 4,
                              borderRadius: BorderRadius.circular(8),
                              child: FlLinkedCellPicker(
                                linkedCellEditor: this,
                                model: model,
                                name: name!,
                                editorColumnDefinition: columnDefinition,
                                embeddable: true,
                                showTitle: false,
                              )
                          ),
                        ),
                      )
                  )
                ],
              );
            },
          ),
        );
      }
      else if (model.styles.contains(FlLinkedCellEditorModel.STYLE_POPUP_FADE_IN_DOWN)) {
        return Navigator.push(
          FlutterUI.getCurrentContext()!,
          PageRouteBuilder(
            opaque: false,
            barrierDismissible: true,
            barrierColor: Colors.black26.withAlpha(25),
            pageBuilder: (context, animation, secondaryAnimation) {
              final slide = Tween<Offset>(
                begin: Offset(0, -0.1), // leicht von oben
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

              final fade = Tween<double>(
                begin: 0,
                end: 1,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

              final expand = Tween<double>(
                begin: 0,
                end: 1,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

              Rect rect = getPopupRect(prefPopupHeight);

              return Stack(
                children: [
                  Positioned(
                    top: rect.top,
                    left: rect.left,
                    child: SlideTransition(
                      position: slide,
                      child: FadeTransition(
                        opacity: fade,
                        child: Align(
                          alignment: Alignment.topCenter,
                          heightFactor: expand.value,
                          child: Container(
                            width: rect.width,
                            height: rect.height,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
                            ),
                            child: Material(
                              elevation: 4,
                              borderRadius: BorderRadius.circular(8),
                              child: FlLinkedCellPicker(
                                  linkedCellEditor: this,
                                  model: model,
                                  name: name!,
                                  editorColumnDefinition: columnDefinition,
                                  embeddable: true,
                                  showTitle: false
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }
    }

    //standard animation (fade_in_bounce)
    return Navigator.push(
      FlutterUI.getCurrentContext()!,
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black26.withAlpha(25),
        pageBuilder: (context, animation, secondaryAnimation) {
          final slide = Tween<Offset>(
            begin: Offset(0, -0.05),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack, //Bounce-Effect
          ));

          final fade = Tween<double>(
            begin: 0,
            end: 1,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeIn,
          ));

          final expand = Tween<double>(
            begin: 0,
            end: 1,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ));

          Rect rect = getPopupRect(prefPopupHeight);

          return Stack(
            children: [
              Positioned(
                top: rect.top,
                left: rect.left,
                child: SlideTransition(
                  position: slide,
                  child: FadeTransition(
                    opacity: fade,
                    child: Align(
                      alignment: Alignment.topCenter,
                      heightFactor: expand.value,
                      child: Container(
                        width: rect.width,
                        height: rect.height,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
                        ),
                        child: Material(
                          elevation: 4,
                          clipBehavior: Clip.antiAlias,
                          borderRadius: BorderRadius.circular(8),
                          child: FlLinkedCellPicker(
                              linkedCellEditor: this,
                              model: model,
                              name: name!,
                              editorColumnDefinition: columnDefinition,
                              embeddable: true,
                              showTitle: false
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Rect getPopupRect(double preferredPopupHeight) {
    double fieldTop;
    double fieldBottom;

    if (_layerLink.leaderSize != null) {
      fieldTop = focusNode.offset.dy - focusNode.size.height + 1;
      fieldBottom = fieldTop + _layerLink.leaderSize!.height + 1;
    }
    else {
      fieldTop = focusNode.offset.dy - focusNode.size.height + 1;
      fieldBottom = fieldTop + focusNode.size.height + 32;
    }

    MediaQueryData mqd = MediaQuery.of(FlutterUI.getCurrentContext()!);

    final safeAreaTop = mqd.padding.top;
    final safeAreaBottom = mqd.padding.bottom;
    final screenHeight = mqd.size.height;
    final keyboardHeight = mqd.viewInsets.bottom;
    final padding = 5.0;

    // space above node
    final spaceAbove = fieldTop + padding - safeAreaTop;
    // space below node
    final spaceBelow = screenHeight - safeAreaBottom - keyboardHeight - fieldBottom + padding;

    double popupHeight;
    double topPosition;

    if (spaceBelow >= preferredPopupHeight) {
      popupHeight = preferredPopupHeight;
      topPosition = fieldBottom - padding;
    }
    else if (spaceBelow >= 250) {
      //min-height: 250 of popup if shown below
      popupHeight = spaceBelow;
      topPosition = fieldBottom - padding;
    }
    else if (spaceAbove >= preferredPopupHeight) {
      popupHeight = preferredPopupHeight;
      topPosition = fieldTop - popupHeight + padding;
    }
    else if (spaceAbove >= 250) {
      //min-height: 250 of popup if shown above
      popupHeight = spaceAbove;
      topPosition = fieldTop - popupHeight + padding;
    }
    else {
      popupHeight = preferredPopupHeight;
      topPosition = fieldBottom - (popupHeight - spaceBelow);
    }

    FlutterUI.logUI.d("Space above linked cell editor = $spaceAbove");
    FlutterUI.logUI.d("Space below linked cell editor = $spaceBelow");

    if (_layerLink.leader != null) {
      return Rect.fromLTWH(
          _layerLink.leader!.offset.dx, topPosition,
          max(_layerLink.leaderSize!.width, 250), popupHeight);
    }
    else {
      double clear = textController.text.isNotEmpty ? 80 : 54;

      return Rect.fromLTWH(focusNode.offset.dx - 14, topPosition,
          max(focusNode.size.width + clear, 250), popupHeight);
    }
  }

  Future<T?> _showAsBottomSheet<T>() {
    //default popup height
    double contentHeight = 500;

    //we need the databook for height calculation, only if all records are fetched
    var dataBook = IDataService().getDataBook(model.linkReference.referencedDataBook);

    if (dataBook?.isAllFetched == true) {
      int records = dataBook?.records.length ?? 0;

      if (records == 0) {
        //simulate height for 1 record if empty -> looks better
        records = 1;
      }
      //134 = text + gap + padding.top + padding.bottom + 2 (table border) + gap + buttons
      if (records < FlLinkedCellPicker.MIN_ROWS_FOR_SEARCH) {
        double rowHeight = JVxColors.componentHeight() + 2;

        contentHeight = 134 + (records * rowHeight) + (rowHeight / 2);
      }
    }

    return showBarModalBottomSheet(
      context: FlutterUI.getCurrentContext()!,
      backgroundColor: Theme.of(FlutterUI.getCurrentContext()!).dialogTheme.backgroundColor,
      barrierColor: JVxColors.LIGHTER_BLACK.withAlpha(Color.getAlphaFromOpacity(0.75)),
      topControl: Container(
        height: 20,
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 6,
          width: 40,
          decoration: BoxDecoration(color: Colors.white.withAlpha(Color.getAlphaFromOpacity(0.5)), borderRadius: BorderRadius.circular(6)),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: const RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.only(topLeft: kDefaultBarTopRadius, topRight: kDefaultBarTopRadius),
      ),
      enableDrag: true,
      //otherwise the full height will be used - independent of the ContentBottomSheet
      expand: false,
      bounce: false,
      builder: (context) => SizedBox(
        height: contentHeight,
        child: FlLinkedCellPicker(
          linkedCellEditor: this,
          model: model,
          name: name!,
          editorColumnDefinition: columnDefinition,
          embeddable: true,
        )
      ),
    ).then((value) {
      if (value != null) {
        if (value == FlLinkedCellPicker.NULL_OBJECT) {
          receiveNull();
        } else {
          onEndEditing(value);
        }
      }

      return value;
    });
  }

  void _subscribe() {
    if ((model.displayReferencedColumnName != null || model.displayConcatMask != null) && dataProvider.isNotEmpty) {
      IUiService().registerDataSubscription(
        pDataSubscription: DataSubscription(
          subbedObj: this,
          dataProvider: dataProvider,
          from: 0,
          to: -1,
          onDataToDisplayMapChanged: _updateControllerValue,
        ),
      );

      // Checks if the column of the metadata has a link reference
      // If not, then we have to create the referenced cell editor ourselves
      if (model.linkReference == effectiveLinkReference) {
        referencedCellEditor = IDataService().createReferencedCellEditors(model, dataProvider, columnName);
      }
    }
  }

  void _updateControllerValue() {
    if (_value == null) {
      textController.clear();
    } else {
      dynamic showValue = formatValue(_value!);

      if (showValue == null) {
        textController.clear();
      } else {
        if (showValue is! String) {
          showValue = showValue.toString();
        }

        textController.value = textController.value.copyWith(
          text: showValue,
          selection: TextSelection.collapsed(offset: showValue.characters.length),
          composing: null,
        );
      }
    }
  }

  void receiveNull() {
    List<String> columnsToSend = [columnName];
    if (model.linkReference.columnNames.isNotEmpty) {
      columnsToSend = List.from(model.linkReference.columnNames);
    }

    if (model.additionalClearColumnNames?.isNotEmpty == true) {
      //no matter if element is already in list
      columnsToSend.addAll(model.additionalClearColumnNames!);
    }

    if (model.clearColumnNames?.isNotEmpty == true) {
      //no matter if element is already in list
      columnsToSend.addAll(model.clearColumnNames!);
    }

    Map<String, dynamic> dataMap = HashMap<String, dynamic>();

    for (String columnName in columnsToSend) {
      dataMap[columnName] = null;
    }

    ICommandService().sendCommand(SelectRecordCommand.deselect(
      dataProvider: model.linkReference.referencedDataBook,
      reason: "Tapped",
    )).then((success) {
        if (success) {
          onEndEditing(dataMap);
        }
      },
    );
  }

  ReferenceDefinition get effectiveLinkReference {
    ColumnDefinition? colDef = IDataService().getMetaData(dataProvider)?.columnDefinitions.byName(columnName);

    return (colDef?.cellEditorModel is FlLinkedCellEditorModel)
        ? (colDef!.cellEditorModel as FlLinkedCellEditorModel).linkReference
        : model.linkReference;
  }
}
