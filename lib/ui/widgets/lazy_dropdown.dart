import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../model/api/response/data/jvx_data.dart';
import '../../model/properties/properties.dart';
import '../../ui/screen/component_data.dart';
import '../../utils/translations.dart';
import '../../utils/uidata.dart';

class LazyDropdown extends StatefulWidget {
  final allowNull;
  final ValueChanged<dynamic> onSave;
  final VoidCallback onCancel;
  final VoidCallback onScrollToEnd;
  final ValueChanged<String> onFilter;
  final BuildContext context;
  final double fetchMoreYOffset;
  final ComponentData data;
  final List<String> displayColumnNames;

  LazyDropdown(
      {
      @required this.allowNull,
      @required this.context,
      @required this.data,
      this.displayColumnNames,
      this.onSave,
      this.onCancel,
      this.onScrollToEnd,
      this.onFilter,
      this.fetchMoreYOffset = 0}) :
        assert(allowNull != null),
        assert(context != null),
        assert(data != null);

  @override
  _LazyDropdownState createState() => _LazyDropdownState();
}

class _LazyDropdownState extends State<LazyDropdown> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _controller = TextEditingController();
  final FocusNode node = FocusNode();
  Timer filterTimer; // 200-300 Milliseconds
  dynamic lastChangedFilter;

  @override
  void initState() {
    super.initState();
    widget.data.registerDataChanged(updateData);
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    widget.data.unregisterDataChanged(updateData);
    super.dispose();
  }

  void updateData() {
    this.setState(() {});
  }

  void startTimerValueChanged(dynamic value) {
    lastChangedFilter = value;
    if (filterTimer != null && filterTimer.isActive) filterTimer.cancel();

    filterTimer =
        new Timer(Duration(milliseconds: 300), onTextFieldValueChanged);
  }

  void onTextFieldValueChanged() {
    if (this.widget.onFilter != null) this.widget.onFilter(lastChangedFilter);
  }

  void _onCancel() {
    Navigator.of(this.widget.context).pop();
    if (this.widget.onCancel != null) this.widget.onCancel();
  }

  void _onDelete() {
    Navigator.of(this.widget.context).pop();
    if (this.widget.onSave != null) this.widget.onSave(null);
  }

  void _onRowTapped(int index) {
    Navigator.of(this.widget.context).pop();
    if (this.widget.onSave != null) {
      dynamic value = widget.data.data.getRow(index);
      this.widget.onSave(value);
      this.updateData();
    }
  }

  Widget itemBuilder(BuildContext ctxt, int index) {
    List<Widget> children = new List<Widget>();
    List<dynamic> row = widget.data.data.getRow(index, widget.displayColumnNames);

    if (row!=null) {
      row.forEach((c) {
        children.add(getTableColumn(
              c != null ? c.toString() : "", index));
      });

      return getTableRow(children, index, false);
    }

    return Container();
  }

  Container getTableRow(List<Widget> children, int index, bool isHeader) {
    if (isHeader) {
      return Container(
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.grey[400], spreadRadius: 1)],
            color: UIData.ui_kit_color_2[200],
          ),
          child: ListTile(title: Row(children: children)));
    } else {
      return Container(
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.grey[400], spreadRadius: 1)],
            color: Colors.white,
          ),
          child: ListTile(
            title: Row(children: children),
            onTap: () => _onRowTapped(index),
          ));
    }
  }

  Widget getTableColumn(String text, int rowIndex) {
    int flex = 1;

    return Expanded(
        flex: flex,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
              child: Text(text),
              padding: EdgeInsets.all(5)),
        ));
  }

  _scrollListener() {
    if (_scrollController.offset + this.widget.fetchMoreYOffset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if (this.widget.onScrollToEnd != null) this.widget.onScrollToEnd();
    }
  }

  @override
  Widget build(BuildContext context) {
    int itemCount = 0;
    JVxData data = widget.data.data;
    if (data != null && data.records != null) itemCount = data.records.length;

    return Dialog(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: Container(
          child: Container(
            decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
            child: Column(
              children: <Widget>[
                Container(
                  color: UIData.ui_kit_color_2,
                    child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                  child: TextField(
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      hintText: Translations.of(context).text2("Search"),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: UIData.ui_kit_color_2, width: 1.0)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: UIData.ui_kit_color_2, width: 0.0)),
                    ),
                    key: widget.key,
                    controller: _controller,
                    maxLines: 1,
                    keyboardType: TextInputType.text,
                    onChanged: startTimerValueChanged,
                    focusNode: node,
                  ),
                )),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: itemCount,
                      itemBuilder: itemBuilder,
                    ),
                  ),
                ),

                ButtonBar(
                    alignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new RaisedButton(
                        child: Text(Translations.of(context).text2("Clear")),
                        onPressed: _onDelete,
                        color: UIData.ui_kit_color_2[200],
                      ),
                      new RaisedButton(
                        child: Text(
                          Translations.of(context).text2("Cancel"),
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: _onCancel,
                        color: UIData.ui_kit_color_2,
                      ),
                    ]),
              ],
            ),
          ),
        ));
  }
}
