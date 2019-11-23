

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/api/response/data/jvx_data.dart';

class LazyLinkedCellEditor extends StatelessWidget {
  final JVxData data;
  final allowNull;
  final ValueChanged<dynamic> onSave;
  final VoidCallback onCancel;
  final VoidCallback onScrollToEnd;
  final ValueChanged<String> onFilter;

  LazyLinkedCellEditor({
    @required this.data,
    @required this.allowNull,
    this.onSave,
    this.onCancel,
    this.onScrollToEnd,
    this.onFilter
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
      ),      
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Column(children: <Widget>[
          Container(child: 
            Text("Filter")
          ),
          Container(child: 
            Text("ListView")),
          Container(child: 
            Text("Buttons"),)
      ],),
    );
  }
}