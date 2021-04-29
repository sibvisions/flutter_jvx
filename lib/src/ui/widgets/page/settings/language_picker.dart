import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutterclient/src/util/translation/app_localizations.dart';

showLanguagePicker(
    BuildContext context,
    GlobalKey<ScaffoldState> key,
    List<String> possibleLanguages,
    Function(String?) onLanguageChosen,
    int selected) {
  Picker picker = Picker(
      selecteds: [selected],
      confirmText: AppLocalizations.of(context)!.text('Confirm'),
      confirmTextStyle: TextStyle(fontSize: 14),
      cancel: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextButton(
          child: Text(AppLocalizations.of(context)!.text('Cancel'),
              style: TextStyle(fontSize: 14)),
          onPressed: () {
            onLanguageChosen(null);
            Navigator.of(context).pop();
          },
        ),
      ),
      adapter: PickerDataAdapter<String>(pickerdata: possibleLanguages),
      changeToFirst: false,
      textAlign: TextAlign.left,
      columnPadding: const EdgeInsets.all(8.0),
      onConfirm: (Picker picker, List value) {
        String? lang;

        if (value.isNotEmpty) {
          lang = picker.getSelectedValues()[0];
        }

        onLanguageChosen(lang);
      });
  picker.show(key.currentState!);
}
