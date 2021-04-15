import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../util/translation/app_localizations.dart';

class BaseUrlDialog extends StatelessWidget {
  final String baseUrl;

  const BaseUrlDialog({Key? key, this.baseUrl = ''}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String toSave = '';

    return Dialog(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Stack(
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: 400),
            padding:
                EdgeInsets.only(left: 20, top: 25 + 20, right: 20, bottom: 20),
            margin: EdgeInsets.only(top: 25),
            decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black,
                      offset: Offset(0, 10),
                      blurRadius: 10),
                ]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                AutoSizeText(
                  AppLocalizations.of(context)!.text('Enter new Base Url'),
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height: 15,
                ),
                TextField(
                  controller: TextEditingController(text: baseUrl),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.text('Base Url'),
                    hintText: 'http://new.baseUrl/services/mobile',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  onChanged: (change) => toSave = change,
                ),
                SizedBox(
                  height: 22,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          AppLocalizations.of(context)!
                              .text('Close')
                              .toUpperCase(),
                          style: TextStyle(fontSize: 18),
                        )),
                    SizedBox(
                      width: 10,
                    ),
                    TextButton(
                        onPressed: () {
                          if (!toSave.endsWith('/services/mobile')) {
                            if (toSave.endsWith('/')) {
                              toSave = toSave.replaceRange(
                                  toSave.length - 1, toSave.length, '');
                            }

                            toSave += '/services/mobile';
                          }

                          Navigator.of(context).pop(toSave);
                        },
                        child: Text(
                          AppLocalizations.of(context)!
                              .text('Save')
                              .toUpperCase(),
                          style: TextStyle(fontSize: 18),
                        )),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
              left: 20,
              right: 20,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 35,
                child: FaIcon(
                  FontAwesomeIcons.keyboard,
                  color: Theme.of(context).primaryColor,
                ),
              )),
        ],
      ),
    );
  }
}

class AppNameDialog extends StatelessWidget {
  final String appName;

  const AppNameDialog({Key? key, this.appName = ''}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String toSave = '';

    return Dialog(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Stack(
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: 400),
            padding:
                EdgeInsets.only(left: 20, top: 25 + 20, right: 20, bottom: 20),
            margin: EdgeInsets.only(top: 25),
            decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black,
                      offset: Offset(0, 10),
                      blurRadius: 10),
                ]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                AutoSizeText(
                  AppLocalizations.of(context)!.text('Enter new App Name'),
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height: 15,
                ),
                TextField(
                  controller: TextEditingController(text: appName),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.text('App name'),
                    hintText: AppLocalizations.of(context)!
                        .text('Enter new App Name'),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  onChanged: (change) => toSave = change,
                ),
                SizedBox(
                  height: 22,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          AppLocalizations.of(context)!
                              .text('Close')
                              .toUpperCase(),
                          style: TextStyle(fontSize: 18),
                        )),
                    SizedBox(
                      width: 10,
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(toSave);
                        },
                        child: Text(
                          AppLocalizations.of(context)!
                              .text('Save')
                              .toUpperCase(),
                          style: TextStyle(fontSize: 18),
                        )),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
              left: 20,
              right: 20,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 35,
                child: FaIcon(
                  FontAwesomeIcons.server,
                  color: Theme.of(context).primaryColor,
                ),
              )),
        ],
      ),
    );
  }
}
