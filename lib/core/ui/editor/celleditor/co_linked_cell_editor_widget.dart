import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jvx_flutterclient/core/ui/screen/component_screen_widget.dart';
import '../../../../injection_container.dart';
import '../../../models/api/editor/cell_editor.dart';
import '../../../models/api/response/data/data_book.dart';
import '../../../services/remote/bloc/api_bloc.dart';
import '../../../utils/app/text_utils.dart';
import '../../widgets/custom/custom_dropdown_button.dart' as custom;
import '../../widgets/dropdown/lazy_dropdown.dart';
import 'co_referenced_cell_editor_widget.dart';
import 'models/linked_cell_editor_model.dart';

class CoLinkedCellEditorWidget extends CoReferencedCellEditorWidget {
  final LinkedCellEditorModel cellEditorModel;
  CoLinkedCellEditorWidget({
    this.cellEditorModel,
  }) : super(cellEditorModel: cellEditorModel);

  @override
  State<StatefulWidget> createState() => CoLinkedCellEditorWidgetState();
}

class CoLinkedCellEditorWidgetState
    extends CoReferencedCellEditorWidgetState<CoLinkedCellEditorWidget> {
  void valueChanged(dynamic value) {
    widget.cellEditorModel.cellEditorValue = value;
    this.onValueChanged(value);
  }

  void onLazyDropDownValueChanged(MapEntry<int, dynamic> pValue) {
    if (pValue.key >= 0) {
      ComponentScreenWidget.of(context)
          .getComponentData(widget.cellEditorModel.linkReference.dataProvider)
          .selectRecord(context, pValue.key);
    }

    DataBook data = widget.cellEditorModel.referencedData.getData(context, 0);
    if (pValue.value != null)
      widget.cellEditorModel.cellEditorValue =
          pValue.value[widget.cellEditorModel.getVisibleColumnIndex(data)[0]];
    else
      widget.cellEditorModel.cellEditorValue = pValue.value;
    if (widget.cellEditorModel.linkReference != null &&
        widget.cellEditorModel.linkReference.columnNames.length == 1)
      this.onValueChanged(widget.cellEditorModel.cellEditorValue, pValue.value[0]);
    else
      this.onValueChanged(pValue.value);
  }

  List<DropdownMenuItem> getItems(DataBook data) {
    List<DropdownMenuItem> items = <DropdownMenuItem>[];
    List<int> visibleColumnsIndex =
        widget.cellEditorModel.getVisibleColumnIndex(data);

    if (data != null && data.records.isNotEmpty) {
      data.records.asMap().forEach((j, record) {
        if (j >=
                widget.cellEditorModel.pageIndex *
                    widget.cellEditorModel.pageSize &&
            j <
                (widget.cellEditorModel.pageIndex + 1) *
                    widget.cellEditorModel.pageSize) {
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
  void onServerDataChanged(BuildContext context) {
    this.setState(() {});
  }

  void onScrollToEnd() {
    print("Scrolled to end");
    DataBook _data = widget.cellEditorModel.referencedData
        .getData(context, widget.cellEditorModel.pageSize);
    if (_data != null && _data.records != null)
      widget.cellEditorModel.referencedData.getData(
          context, widget.cellEditorModel.pageSize + _data.records.length);
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
    if (widget.cellEditorModel.referencedData.data == null) {
      widget.cellEditorModel.referencedData.getData(context, -1);
    }

    String h = widget.cellEditorModel.cellEditorValue == null
        ? null
        : widget.cellEditorModel.cellEditorValue.toString();
    String v = widget.cellEditorModel.cellEditorValue == null
        ? null
        : widget.cellEditorModel.cellEditorValue.toString();

    List<DropdownMenuItem> items = List<DropdownMenuItem<dynamic>>();
    if (v == null)
      items.add(this.getItem("", ""));
    else
      items.add(this.getItem(v, v));

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
          color: widget.cellEditorModel.background != null
              ? widget.cellEditorModel.background
              : Colors.white.withOpacity(widget.cellEditorModel.appState
                      .applicationStyle?.controlsOpacity ??
                  1.0),
          borderRadius: BorderRadius.circular(widget.cellEditorModel.appState
                  .applicationStyle?.cornerRadiusEditors ??
              10),
          border: widget.cellEditorModel.editable != null &&
                  widget.cellEditorModel.editable
              ? (widget.cellEditorModel.borderVisible
                  ? Border.all(color: Theme.of(context).primaryColor)
                  : null)
              : Border.all(color: Colors.grey)),
      child: Container(
        child: DropdownButtonHideUnderline(
            child: custom.CustomDropdownButton(
          hint: Text(h == null
              ? (widget.cellEditorModel.placeholderVisible &&
                      widget.cellEditorModel.placeholder != null
                  ? widget.cellEditorModel.placeholder
                  : "")
              : h),
          value: v,
          items: items,
          onChanged: valueChanged,
          editable: widget.cellEditorModel.editable != null
              ? widget.cellEditorModel.editable
              : true,
          onDelete: () {
            widget.cellEditorModel.cellEditorValue = null;
            onLazyDropDownValueChanged(MapEntry<int, dynamic>(-1, null));
          },
          onOpen: () {
            this.onFilter(null);
            TextUtils.unfocusCurrentTextfield(context);
            showDialog(
                context: context,
                builder: (context) => BlocProvider<ApiBloc>(
                      create: (_) => sl<ApiBloc>(),
                      child: LazyDropdown(
                          editable: widget.cellEditorModel.editable,
                          data: widget.cellEditorModel.referencedData,
                          context: context,
                          displayColumnNames: dropDownColumnNames,
                          fetchMoreYOffset:
                              MediaQuery.of(context).size.height * 4,
                          onSave: (value) {
                            widget.cellEditorModel.cellEditorValue = value.value;
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
