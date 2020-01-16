import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';

class FirstCustomScreenWidget extends StatefulWidget {
  @override
  _FirstCustomScreenState createState() => _FirstCustomScreenState();
}

class _FirstCustomScreenState extends State<FirstCustomScreenWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            SizedBox(
              width: 20,
            ),
            Text(
              'Kontakt',
              style: TextStyle(fontSize: 20),
            ),
            Divider(),
            Container(
                padding: EdgeInsets.fromLTRB(30, 8, 8, 8),
                alignment: Alignment.centerLeft,
                child: Text(
                  'Anrede',
                  style: TextStyle(fontSize: 16),
                )),
            _getAnredeDropdown(),
            Container(
              padding: EdgeInsets.fromLTRB(30, 8, 8, 8),
              alignment: Alignment.centerLeft,
              child: Text(
                'Titel',
                style: TextStyle(fontSize: 16),
              ),
            ),
            _getTitelDropdown(),
            Container(
              padding: EdgeInsets.fromLTRB(30, 8, 8, 8),
              alignment: Alignment.centerLeft,
              child: Text(
                'Vorname',
                style: TextStyle(fontSize: 16),
              ),
            ),
            _getTextField(),
            Container(
              padding: EdgeInsets.fromLTRB(30, 8, 8, 8),
              alignment: Alignment.centerLeft,
              child: Text(
                'Nachname',
                style: TextStyle(fontSize: 16),
              ),
            ),
            _getTextField()
          ],
        ),
      );
  }

  Widget _getTextField() {
    return Container(
      height: 60,
      width: MediaQuery.of(context).size.width / 1.2,
      child: TextField(
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
            fillColor: Colors.transparent,
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: BorderSide(color: UIData.ui_kit_color_2, width: 1)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: BorderSide(color: UIData.ui_kit_color_2, width: 1)),
            disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: BorderSide(color: Colors.grey, width: 1))),
      ),
    );
  }

  Widget _getAnredeDropdown() {
    String value = 'Herr';

    return Container(
      height: 60,
      width: MediaQuery.of(context).size.width / 1.2,
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          border: Border(
              top: BorderSide(
                width: 1,
                color: UIData.ui_kit_color_2,
              ),
              bottom: BorderSide(width: 1, color: UIData.ui_kit_color_2),
              left: BorderSide(width: 1, color: UIData.ui_kit_color_2),
              right: BorderSide(width: 1, color: UIData.ui_kit_color_2))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          value: value,
          onChanged: (String changed) {
            setState(() {
              value = changed;
            });
          },
          items: <DropdownMenuItem<String>>[
            DropdownMenuItem(
              value: 'Herr',
              child: Text('Herr'),
            ),
            DropdownMenuItem(
              value: 'Frau',
              child: Text('Frau'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getTitelDropdown() {
    String value = 'Keinen';

    return Container(
      height: 60,
      width: MediaQuery.of(context).size.width / 1.2,
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          border: Border(
              top: BorderSide(
                width: 1,
                color: UIData.ui_kit_color_2,
              ),
              bottom: BorderSide(width: 1, color: UIData.ui_kit_color_2),
              left: BorderSide(width: 1, color: UIData.ui_kit_color_2),
              right: BorderSide(width: 1, color: UIData.ui_kit_color_2))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          value: value,
          onChanged: (String changed) {
            setState(() {
              value = changed;
            });
          },
          items: <DropdownMenuItem<String>>[
            DropdownMenuItem(
              value: 'Keinen',
              child: Text('Keinen'),
            ),
            DropdownMenuItem(
              value: 'Mag',
              child: Text('Mag'),
            ),
            DropdownMenuItem(
              value: 'Dr',
              child: Text('Dr'),
            ),
            DropdownMenuItem(
              value: 'Dipl',
              child: Text('Dipl'),
            ),
          ],
        ),
      ),
    );
  }
}
