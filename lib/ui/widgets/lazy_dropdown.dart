import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/api/response/data/jvx_data.dart';
import 'package:jvx_mobile_v3/model/properties/properties.dart';
import 'package:jvx_mobile_v3/ui/screen/component_data.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';

class LazyDropdown extends StatefulWidget {
  final List<int> visibleColumnIndex;
  final allowNull;
  final ValueChanged<dynamic> onSave;
  final VoidCallback onCancel;
  final VoidCallback onScrollToEnd;
  final ValueChanged<String> onFilter;
  final BuildContext context;
  final double fetchMoreYOffset;
  final ComponentData data;

  LazyDropdown(
      {//@required this.data,
      @required this.allowNull,
      @required this.context,
      this.data,
      this.visibleColumnIndex,
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

  @override
  void initState() {
    super.initState();
    widget.data.registerDataChanged(updateData);
    _scrollController.addListener(_scrollListener);
  }

  void updateData() {
    this.setState(() {});
  }

  void onTextFieldValueChanged(dynamic newValue) {
    if (this.widget.onFilter != null) this.widget.onFilter(newValue);
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
    JVxData data = widget.data.getData(context, null, 0);
    if (this.widget.onSave!=null && data.records.length>index) {
      dynamic value = data.records[index][widget.visibleColumnIndex[0]];
      this.widget.onSave(value);
      this.updateData();
    }
  }

  Widget itemBuilder(BuildContext ctxt, int index) {
    //return Text("Na oida");
    JVxData data = widget.data.getData(context, null, 0);
    return getDataRow(data, index);
  }

  Widget getDataRow(JVxData data, int index) {
    List<Widget> children = new List<Widget>();

    if (data != null && data.records != null && index < data.records.length) {
      List<dynamic> columns = data.records[index];

      this.widget.visibleColumnIndex.asMap().forEach((i, j) {
        if (j < columns.length)
          children.add(getTableColumn(
              columns[j] != null ? columns[j].toString() : "", index, i));
        else
          children.add(getTableColumn("", index, j));
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
          child: ListTile(title: Row(children: children), onTap: () => _onRowTapped(index),));
    }
  }

  Widget getTableColumn(String text, int rowIndex, int columnIndex) {
    int flex = 1;

    return Expanded(
        flex: flex,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
              child: Text(Properties.utf8convert(text)),
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
    JVxData data = widget.data.getData(context, null, 0);
    if (data != null && data.records != null) itemCount = data.records.length;

    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              ButtonBar(alignment: MainAxisAlignment.spaceEvenly, children: <
                  Widget>[
                new RaisedButton(child: Text("Delete"), onPressed: _onDelete),
                new RaisedButton(child: Text("Cancel"), onPressed: _onCancel),
              ]),
              Container(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TextField(
                decoration: InputDecoration(
                    hintText: "Filter",
                    enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: UIData.ui_kit_color_2, width: 1.0)),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: UIData.ui_kit_color_2, width: 0.0)),
                ),
                key: widget.key,
                controller: _controller,
                maxLines: 1,
                keyboardType: TextInputType.text,
                onChanged: onTextFieldValueChanged,
                focusNode: node,
              ),
                  )),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: itemCount,
                  itemBuilder: itemBuilder,
                ),
              ),
            ],
          ),
        ));
  }
}
