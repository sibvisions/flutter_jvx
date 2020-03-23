import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_flutterclient/utils/text_utils.dart';
import '../../../model/cell_editor.dart';
import '../../../model/api/response/data/jvx_data.dart';
import '../../../ui/editor/celleditor/jvx_referenced_cell_editor.dart';
import '../../../ui/widgets/custom_dropdown_button.dart' as custom;
import '../../../ui/widgets/lazy_dropdown.dart';
import '../../../utils/uidata.dart';

class JVxLinkedCellEditor extends JVxReferencedCellEditor {
  List<DropdownMenuItem> _items = <DropdownMenuItem>[];
  String initialData;
  int pageIndex = 0;
  int pageSize = 100;

  @override
  get preferredSize {
    double width = TextUtils.getTextWidth(TextUtils.averageCharactersTextField, Theme.of(context).textTheme.button).toDouble();
    return Size(width,50);
  }

  @override
  get minimumSize {
    return Size(50,50);
  }

  JVxLinkedCellEditor(CellEditor changedCellEditor, BuildContext context)
      : super(changedCellEditor, context);

  void valueChanged(dynamic value) {
    this.value = value;
    this.onValueChanged(value);
  }

  void onLazyDropDownValueChanged(dynamic pValue) {
    JVxData data = this.data.getData(context, 0);
    if (pValue!=null)
      this.value = pValue[this.getVisibleColumnIndex(data)[0]];
    else 
      this.value = pValue;
    if (this.linkReference!=null && this.linkReference.columnNames.length==1)
      this.onValueChanged(this.value);
    else
      this.onValueChanged(pValue);
  }

  List<int> getVisibleColumnIndex(JVxData data) {
    List<int> visibleColumnsIndex = <int>[];
    if (data != null && data.records.isNotEmpty) {
      data.columnNames.asMap().forEach((i, v) {
        if (this.columnView != null && this.columnView.columnNames != null) {
          if (this.columnView.columnNames.contains(v)) {
            visibleColumnsIndex.add(i);
          }
        } else if (this.linkReference != null &&
            this.linkReference.referencedColumnNames != null &&
            this.linkReference.referencedColumnNames.contains(v)) {
          visibleColumnsIndex.add(i);
        }
      });
    }

    return visibleColumnsIndex;
  }

  List<DropdownMenuItem> getItems(JVxData data) {
    List<DropdownMenuItem> items = <DropdownMenuItem>[];
    List<int> visibleColumnsIndex = this.getVisibleColumnIndex(data);

    if (data != null && data.records.isNotEmpty) {
      data.records.asMap().forEach((j, record) {
        if (j >= pageIndex * pageSize && j < (pageIndex + 1) * pageSize) {
          record.asMap().forEach((i, c) {
            if (visibleColumnsIndex.contains(i)) {
              items.add(getItem(c.toString(), c.toString()));
            }
          });
        }
      });
    }

    if (items.length == 0) items.add(getItem('loading', 'Loading...'));

    return items;
  }

  DropdownMenuItem getItem(dynamic value, String text) {
    return DropdownMenuItem(
        value: value,
        child: Padding(
          padding: EdgeInsets.only(left: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(text, overflow: TextOverflow.fade),
            ],
          ),
        ));
  }

  @override
  void onServerDataChanged() {}

  void onScrollToEnd() {
    print("Scrolled to end");
    JVxData _data = data.getData(context, pageSize);
    if (_data != null && _data.records != null)
      data.getData(context, this.pageSize + _data.records.length);
  }

  void onFilterDropDown(dynamic value) {
    this.onFilter(value);
  }

  @override
  Widget getWidget(
      {bool editable,
      Color background,
      Color foreground,
      String placeholder,
      String font,
      int horizontalAlignment}) {
    setEditorProperties(
        editable: editable,
        background: background,
        foreground: foreground,
        placeholder: placeholder,
        font: font,
        horizontalAlignment: horizontalAlignment);
    String h = this.value==null?null:this.value.toString();
    String v = this.value==null?null:this.value.toString();
    JVxData data;

    if (false) {
      //(data != null && data.records.length < 20) {
      data = this.data.getData(
          this.context, (this.pageIndex + 1) * this.pageSize);
      this._items = getItems(data);
      if (!this._items.contains((i) => (i as DropdownMenuItem).value == v))
        v = null;

      return Container(
        decoration: BoxDecoration(
            color: background != null ? background : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
            border: this.editable != null && this.editable ? (borderVisible
                ? Border.all(color: UIData.ui_kit_color_2)
                : null) : Border.all(color: Colors.grey)),
        child: DropdownButtonHideUnderline(
            child: custom.CustomDropdownButton(
          hint: Text(h == null ? "" : h),
          value: v,
          items: this._items,
          onChanged: valueChanged,
          editable: this.editable != null ? this.editable : null,
        )),
      );
    } else {
      this._items = List<DropdownMenuItem<dynamic>>();
      if (v == null)
        this._items.add(this.getItem("", ""));
      else
        this._items.add(this.getItem(v, v));

      List<String> dropDownColumnNames;

      if (this.columnView!=null)
        dropDownColumnNames = this.columnView.columnNames;
      else if (this.data.metaData!=null)
        dropDownColumnNames = this.data.metaData.tableColumnView;

      return Container(
        height: 50,
        decoration: BoxDecoration(
            color: background != null ? background : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
            border: this.editable != null && this.editable ? (borderVisible
                ? Border.all(color: UIData.ui_kit_color_2)
                : null) : Border.all(color: Colors.grey)),
        child: DropdownButtonHideUnderline(
            child: custom.CustomDropdownButton(
          hint: Text(h == null ? "" : h),
          value: v,
          items: this._items,
          onChanged: valueChanged,
          editable: this.editable != null ? this.editable : true,
          onOpen: () {
            this.onFilter(null);
            FocusScopeNode currentFocus = FocusScope.of(context);

            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
            showDialog(
                context: context,
                builder: (context) => LazyDropdown(
                    data: this.data,
                    context: context,
                    displayColumnNames: dropDownColumnNames,
                    fetchMoreYOffset: MediaQuery.of(context).size.height * 4,
                    onSave: (value) {
                      this.value = value;
                      onLazyDropDownValueChanged(value);
                    },
                    onFilter: onFilterDropDown,
                    allowNull: true,
                    onScrollToEnd: onScrollToEnd));
          },
        )),
      );
    }
  }
}
