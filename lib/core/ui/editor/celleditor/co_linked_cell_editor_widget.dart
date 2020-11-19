import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../../models/api/editor/cell_editor.dart';
import '../../../models/api/response/data/data_book.dart';
import '../../../services/remote/bloc/api_bloc.dart';
import '../../../utils/app/text_utils.dart';
import '../../widgets/custom/custom_dropdown_button.dart' as custom;
import '../../widgets/dropdown/lazy_dropdown.dart';
import 'co_referenced_cell_editor_widget.dart';
import 'linked_cell_editor_model.dart';

class CoLinkedCellEditorWidget extends CoReferencedCellEditorWidget {
  final LinkedCellEditorModel cellEditorModel;
  CoLinkedCellEditorWidget({
    CellEditor changedCellEditor,
    this.cellEditorModel,
  }) : super(
            changedCellEditor: changedCellEditor,
            cellEditorModel: cellEditorModel);

  @override
  State<StatefulWidget> createState() => CoLinkedCellEditorWidgetState();
}

class CoLinkedCellEditorWidgetState
    extends CoReferencedCellEditorWidgetState<CoLinkedCellEditorWidget> {
  List<DropdownMenuItem> _items = <DropdownMenuItem>[];
  String initialData;
  int pageIndex = 0;
  int pageSize = 100;

  void valueChanged(dynamic value) {
    this.value = value;
    this.onValueChanged(value);
  }

  void onLazyDropDownValueChanged(dynamic pValue) {
    DataBook data = widget.cellEditorModel.referencedData.getData(context, 0);
    if (pValue != null)
      this.value =
          pValue[widget.cellEditorModel.getVisibleColumnIndex(data)[0]];
    else
      this.value = pValue;
    if (widget.cellEditorModel.linkReference != null &&
        widget.cellEditorModel.linkReference.columnNames.length == 1)
      this.onValueChanged(this.value, pValue[0]);
    else
      this.onValueChanged(pValue);
  }

  List<DropdownMenuItem> getItems(DataBook data) {
    List<DropdownMenuItem> items = <DropdownMenuItem>[];
    List<int> visibleColumnsIndex =
        widget.cellEditorModel.getVisibleColumnIndex(data);

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
  void onServerDataChanged() {
    this.setState(() {});
  }

  void onScrollToEnd() {
    print("Scrolled to end");
    DataBook _data =
        widget.cellEditorModel.referencedData.getData(context, pageSize);
    if (_data != null && _data.records != null)
      widget.cellEditorModel.referencedData
          .getData(context, this.pageSize + _data.records.length);
  }

  void onFilterDropDown(dynamic value) {
    this.onFilter(value);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    setEditorProperties(context);

    if (widget.cellEditorModel.referencedData.data == null) {
      widget.cellEditorModel.referencedData.getData(context, -1);
    }

    String h = this.value == null ? null : this.value.toString();
    String v = this.value == null ? null : this.value.toString();

    this._items = List<DropdownMenuItem<dynamic>>();
    if (v == null)
      this._items.add(this.getItem("", ""));
    else
      this._items.add(this.getItem(v, v));

    List<String> dropDownColumnNames;

    if (widget.cellEditorModel.columnView != null)
      dropDownColumnNames = widget.cellEditorModel.columnView.columnNames;
    else if (widget.cellEditorModel.referencedData?.metaData != null)
      dropDownColumnNames =
          widget.cellEditorModel.referencedData.metaData.tableColumnView ??
              widget.cellEditorModel.linkReference.referencedColumnNames;

    return Container(
      height: 50,
      decoration: BoxDecoration(
          color: background != null
              ? background
              : Colors.white.withOpacity(
                  this.appState.applicationStyle?.controlsOpacity ?? 1.0),
          borderRadius: BorderRadius.circular(
              this.appState.applicationStyle?.cornerRadiusEditors ?? 10),
          border: this.editable != null && this.editable
              ? (borderVisible
                  ? Border.all(color: Theme.of(context).primaryColor)
                  : null)
              : Border.all(color: Colors.grey)),
      child: Container(
        width: 100,
        child: DropdownButtonHideUnderline(
            child: custom.CustomDropdownButton(
          hint: Text(h == null
              ? (placeholderVisible && placeholder != null ? placeholder : "")
              : h),
          value: v,
          items: this._items,
          onChanged: valueChanged,
          editable: this.editable != null ? this.editable : true,
          onDelete: () {
            this.value = null;
            onLazyDropDownValueChanged(null);
          },
          onOpen: () {
            this.onFilter(null);
            TextUtils.unfocusCurrentTextfield(context);
            showDialog(
                context: context,
                builder: (context) => BlocProvider<ApiBloc>(
                      create: (_) => sl<ApiBloc>(),
                      child: LazyDropdown(
                          editable: this.editable,
                          data: widget.cellEditorModel.referencedData,
                          context: context,
                          displayColumnNames: dropDownColumnNames,
                          fetchMoreYOffset:
                              MediaQuery.of(context).size.height * 4,
                          onSave: (value) {
                            this.value = value;
                            onLazyDropDownValueChanged(value);
                          },
                          onFilter: onFilterDropDown,
                          allowNull: true,
                          onScrollToEnd: onScrollToEnd),
                    ));
          },
        )),
      ),
    );
  }
}
