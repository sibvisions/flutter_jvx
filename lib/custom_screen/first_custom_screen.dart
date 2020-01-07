import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';

class FirstCustomScreen extends StatefulWidget {
  @override
  _FirstCustomScreenState createState() => _FirstCustomScreenState();
}

class _FirstCustomScreenState extends State<FirstCustomScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('First Custom Screen')),
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 20,
                ),
                Text(
                  'Kontakt',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
            Divider(),
            Container(
                padding: EdgeInsets.all(8.0),
                alignment: Alignment.centerLeft,
                child: Text(
                  'Anrede',
                  style: TextStyle(fontSize: 16),
                )),
            _getDropdown(),
            Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.centerLeft,
              child: Text(
                'Titel',
                style: TextStyle(fontSize: 16),
              ),
            ),
            _getDropdown()
          ],
        ),
      ),
    );
  }

  Widget _getTextField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      height: 60,
      child: TextField(
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
            fillColor: Colors.transparent,
            enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: UIData.ui_kit_color_2, width: 0.0)),
            focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: UIData.ui_kit_color_2, width: 0.0)),
            disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 0.0))),
      ),
    );
  }

  Widget _getDropdown() {
    String value = 'Herr';

    return Container(
      height: 60,
      width: MediaQuery.of(context).size.width / 1.3,
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
}
