import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutterclient/src/util/translation/app_localizations.dart';

showPictureSizePicker(BuildContext context, GlobalKey<ScaffoldState> key,
    Function(int?) onSizeChosen) {
  Picker picker = Picker(
      confirmText: AppLocalizations.of(context)!.text('Confirm'),
      confirmTextStyle: TextStyle(fontSize: 14),
      cancel: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextButton(
          child: Text(AppLocalizations.of(context)!.text('Cancel'),
              style: TextStyle(fontSize: 14)),
          onPressed: () {
            onSizeChosen(null);
            Navigator.of(context).pop();
          },
        ),
      ),
      adapter: PickerDataAdapter<int>(data: [
        PickerItem(text: Text('320 px'), value: 320),
        PickerItem(text: Text('640 px'), value: 640),
        PickerItem(text: Text('1024 px'), value: 1024)
      ]),
      changeToFirst: false,
      textAlign: TextAlign.left,
      columnPadding: const EdgeInsets.all(8.0),
      onConfirm: (Picker picker, List value) {
        int? size;

        if (value.isNotEmpty) {
          size = picker.getSelectedValues()[0];
        }

        onSizeChosen(size);
      });
  picker.show(key.currentState!);
}
