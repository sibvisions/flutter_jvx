import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/api/response/data/jvx_data.dart';
import 'package:jvx_mobile_v3/model/properties/properties.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';

class LazyLinkedCellEditor extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _controller = TextEditingController();
  final List<int> visibleColumnIndex;
  final FocusNode node = FocusNode();
  final JVxData data;
  final allowNull;
  final ValueChanged<dynamic> onSave;
  final VoidCallback onCancel;
  final VoidCallback onScrollToEnd;
  final ValueChanged<String> onFilter;
  final BuildContext context;
  final double fetchMoreYOffset;

  LazyLinkedCellEditor(
      {@required this.data,
      @required this.allowNull,
      @required this.context,
      this.visibleColumnIndex,
      this.onSave,
      this.onCancel,
      this.onScrollToEnd,
      this.onFilter,
      this.fetchMoreYOffset = 0}) {
        _scrollController.addListener(_scrollListener);
      }

  void onTextFieldValueChanged(dynamic newValue) {
    if (this.onFilter != null) this.onFilter(newValue);
  }

  void _onSave() {
    Navigator.of(this.context).pop();
    if (this.onSave != null) this.onSave("Test");
  }

  void _onCancel() {
    Navigator.of(this.context).pop();
    if (this.onCancel != null) this.onCancel();
  }

  void _onDelete() {
    Navigator.of(this.context).pop();
    if (this.onSave != null) this.onSave(null);
  }

  void _onRowTapped(int index) {

  }

  Widget itemBuilder(BuildContext ctxt, int index) {
    //return Text("Na oida");
    return getDataRow(data, index);
  }

  Widget getDataRow(JVxData data, int index) {
    List<Widget> children = new List<Widget>();

    if (data != null && data.records != null && index < data.records.length) {
      List<dynamic> columns = data.records[index];

      this.visibleColumnIndex.asMap().forEach((i, j) {
        if (j < columns.length)
          children.add(getTableColumn(
              columns[j] != null ? columns[j].toString() : "", index, i));
        else
          children.add(getTableColumn("", index, j));
      });

      return getTableRow(children, false);
    }

    return Container();
  }

  Container getTableRow(List<Widget> children, bool isHeader) {
    if (isHeader) {
      return Container(
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.grey[400], spreadRadius: 1)],
            color: UIData.ui_kit_color_2[200],
          ),
          child: Row(children: children));
    } else {
      return Container(
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.grey[400], spreadRadius: 1)],
            color: Colors.white,
          ),
          child: Row(children: children));
    }
  }

  Widget getTableColumn(String text, int rowIndex, int columnIndex) {
    int flex = 1;

    return Expanded(
        flex: flex,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            child: Container(
                child: Text(Properties.utf8convert(text)),
                padding: EdgeInsets.all(5)),
            onTap: () => _onRowTapped(rowIndex),
          ),
        ));
  }

  _scrollListener() {
    if (_scrollController.offset + this.fetchMoreYOffset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
        if (this.onScrollToEnd!=null) this.onScrollToEnd();
    }
  }

  @override
  Widget build(BuildContext context) {
    int itemCount = 0;
    if (data != null && data.records != null) itemCount = data.records.length;

    return Padding(
      padding: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Dialog(
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
                new IconButton(
                  icon: Icon(Icons.save),
                  onPressed: _onSave,
                ),
                new IconButton(icon: Icon(Icons.delete), onPressed: _onDelete),
                new IconButton(icon: Icon(Icons.cancel), onPressed: _onCancel),
              ]),
              Container(
                  child: TextField(
                decoration: InputDecoration(
                  hintText: "Filter",
                  enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: UIData.ui_kit_color_2, width: 0.0)),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: UIData.ui_kit_color_2, width: 0.0)),
                ),
                key: this.key,
                controller: _controller,
                maxLines: 1,
                keyboardType: TextInputType.text,
                onChanged: onTextFieldValueChanged,
                focusNode: node,
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
        )
      )
    );
  }
}
