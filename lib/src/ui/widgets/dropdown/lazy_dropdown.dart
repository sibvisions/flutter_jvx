import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterclient/src/ui/component/model/table_component_model.dart';
import 'package:flutterclient/src/ui/screen/core/so_component_data.dart';
import 'package:flutterclient/src/util/translation/app_localizations.dart';
import '../../component/co_table_widget.dart';

class LazyDropdown extends StatefulWidget {
  final allowNull;
  final ValueChanged<MapEntry<int, dynamic>>? onSave;
  final VoidCallback? onCancel;
  final VoidCallback? onScrollToEnd;
  final ValueChanged<String>? onFilter;
  final BuildContext context;
  final double fetchMoreYOffset;
  final SoComponentData data;
  final List<String>? displayColumnNames;
  final bool? editable;

  LazyDropdown(
      {required this.allowNull,
      required this.context,
      required this.data,
      this.editable,
      this.displayColumnNames,
      this.onSave,
      this.onCancel,
      this.onScrollToEnd,
      this.onFilter,
      this.fetchMoreYOffset = 0});

  @override
  _LazyDropdownState createState() => _LazyDropdownState();
}

class _LazyDropdownState extends State<LazyDropdown> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _controller = TextEditingController();
  final FocusNode node = FocusNode();
  Timer? filterTimer; // 200-300 Milliseconds
  dynamic lastChangedFilter;
  CoTableWidget? table;
  Size maxSize = Size(600, 800);

  void updateData(BuildContext context) {
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      if (mounted) this.setState(() {});
    });
  }

  void startTimerValueChanged(dynamic value) {
    lastChangedFilter = value;
    if (filterTimer != null && filterTimer!.isActive) filterTimer!.cancel();

    filterTimer =
        new Timer(Duration(milliseconds: 300), onTextFieldValueChanged);
  }

  void onTextFieldValueChanged() {
    if (this.widget.onFilter != null) this.widget.onFilter!(lastChangedFilter);
  }

  void _onCancel() {
    Navigator.of(this.widget.context).pop(true);
    if (this.widget.onCancel != null) this.widget.onCancel!();
  }

  void _onDelete() {
    Navigator.of(this.widget.context).pop(true);
    if (this.widget.onSave != null)
      this.widget.onSave!(new MapEntry<int, dynamic>(-1, null));
  }

  void _onRowTapped(int index) {
    Navigator.of(this.widget.context).pop(true);
    if (this.widget.onSave != null) {
      dynamic value = widget.data.data!.getRow(index, null);
      this.widget.onSave!(new MapEntry<int, dynamic>(index, value));
      this.updateData(context);
    }
  }

  Widget itemBuilder(BuildContext ctxt, int index) {
    List<Widget> children = <Widget>[];
    List<dynamic>? row =
        widget.data.data?.getRow(index, widget.displayColumnNames);

    if (row != null) {
      row.forEach((c) {
        children.add(getTableColumn(c != null ? c.toString() : "", index));
      });

      return getTableRow(children, index, false);
    }

    return Container();
  }

  Container getTableRow(List<Widget> children, int index, bool isHeader) {
    if (isHeader) {
      return Container(
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.grey[400]!, spreadRadius: 1)],
            color: Theme.of(context).primaryColor,
          ),
          child: ListTile(title: Row(children: children)));
    } else {
      return Container(
          child: Column(
        children: [
          GestureDetector(
            onTap: () => _onRowTapped(index),
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Row(children: children),
            ),
          ),
          Divider(
            color: Colors.grey,
            indent: 10,
            endIndent: 10,
            thickness: 0.5,
          )
        ],
      ));
    }
  }

  Widget getTableColumn(String text, int rowIndex) {
    int flex = 1;

    return Expanded(
        flex: flex,
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16),
          child: Container(child: Text(text), padding: EdgeInsets.all(0)),
        ));
  }

  _scrollListener() {
    if (_scrollController.offset + this.widget.fetchMoreYOffset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if (this.widget.onScrollToEnd != null) this.widget.onScrollToEnd!();
    }
  }

  @override
  void initState() {
    super.initState();
    widget.data.registerDataChanged(updateData);
    _scrollController.addListener(_scrollListener);

    TableComponentModel tableComponentModel =
        TableComponentModel.withoutChangedComponent(null, null, _onRowTapped,
            false, false, true, widget.displayColumnNames!, null);

    tableComponentModel.data = widget.data;

    table = CoTableWidget(
      componentModel: tableComponentModel,
    );
  }

  @override
  void dispose() {
    widget.data.unregisterDataChanged(updateData);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;
    double? containerWidth;
    double? containerHeight;
    Size displaySize = MediaQuery.of(context).size;

    if (displaySize.width - 50 > maxSize.width) containerWidth = maxSize.width;
    if (displaySize.height - 50 > maxSize.height)
      containerHeight = maxSize.height;

    return Dialog(
        insetPadding: EdgeInsets.fromLTRB(25, 25, 25, 25),
        elevation: 0.0,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        child: Container(
          width: containerWidth,
          height: containerHeight,
          child: Container(
            decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
            child: Column(
              children: <Widget>[
                Container(
                    decoration: new BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5.0),
                            topRight: Radius.circular(5.0))),
                    child: Row(
                      children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                            child: Text(
                              AppLocalizations.of(context)!
                                  .text("Select item")
                                  .toUpperCase(),
                              style: TextStyle(
                                  color:
                                      colorScheme.brightness == Brightness.light
                                          ? colorScheme.onPrimary
                                          : colorScheme.onSurface),
                            )),
                      ],
                    )),
                Container(
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: TextFormField(
                          key: widget.key,
                          controller: _controller,
                          maxLines: 1,
                          keyboardType: TextInputType.text,
                          onChanged: startTimerValueChanged,
                          style: new TextStyle(
                              fontSize: 14.0, color: Colors.black),
                          decoration: new InputDecoration(
                              hintStyle: TextStyle(color: Colors.green),
                              labelText:
                                  AppLocalizations.of(context)!.text("Search"),
                              labelStyle: TextStyle(
                                  fontSize: 14.0, fontWeight: FontWeight.w600)),
                        ))),
                Expanded(
                  child: Padding(
                      padding:
                          const EdgeInsets.only(left: 16, right: 16, top: 10),
                      child: table),
                ),
                ButtonBar(
                    alignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ElevatedButton(
                        child: Text(
                          AppLocalizations.of(context)!
                              .text("Cancel")
                              .toUpperCase(),
                        ),
                        onPressed: _onCancel,
                      ),
                    ]),
              ],
            ),
          ),
        ));
  }
}
