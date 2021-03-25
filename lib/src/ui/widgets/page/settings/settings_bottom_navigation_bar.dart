import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../util/color/color_extension.dart';
import '../../../../util/translation/app_localizations.dart';

class SettingsBottomAppBar extends StatefulWidget {
  final bool canPop;
  final Function onSave;

  const SettingsBottomAppBar(
      {Key? key, required this.canPop, required this.onSave})
      : super(key: key);

  @override
  _SettingsBottomAppBarState createState() => _SettingsBottomAppBarState();
}

class _SettingsBottomAppBarState extends State<SettingsBottomAppBar> {
  int selectedItem = 0;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      clipBehavior: !kIsWeb ? Clip.antiAlias : Clip.none,
      shape: !kIsWeb ? CircularNotchedRectangle() : null,
      child: Container(
        height: 50.0,
        decoration: BoxDecoration(color: Theme.of(context).primaryColor),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (widget.canPop)
              Expanded(
                child: InkWell(
                  radius: 50,
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                        AppLocalizations.of(context)!
                            .text('Close')
                            .toUpperCase(),
                        style: TextStyle(
                            color: Theme.of(context).primaryColor.textColor(),
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              )
            else
              Expanded(child: Container()),
            Expanded(
              child: InkWell(
                radius: 50,
                splashColor: Theme.of(context).primaryColor.withOpacity(0.9),
                onTap: () => widget.onSave(),
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    AppLocalizations.of(context)!
                        .text(widget.canPop ? 'Save' : 'Open')
                        .toUpperCase(),
                    style: TextStyle(
                        color: Theme.of(context).primaryColor.textColor(),
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
