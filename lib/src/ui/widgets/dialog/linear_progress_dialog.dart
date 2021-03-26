import 'package:flutter/material.dart';
import 'package:flutterclient/injection_container.dart';
import 'package:flutterclient/src/services/local/local_database/i_offline_database_provider.dart';
import 'package:flutterclient/src/util/translation/app_localizations.dart';

void showLinearProgressDialog(BuildContext context) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
            onWillPop: () async => false,
            child: ValueListenableBuilder(
              valueListenable: sl<IOfflineDatabaseProvider>().progress,
              builder: (BuildContext context, double? value, Widget? child) {
                return Container(
                  child: Center(
                      child: Container(
                    width: 200,
                    height: 200,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(
                            AppLocalizations.of(context)!
                                    .text('Gehe offline...') +
                                ' ${((value ?? 0) * 100).round()}%',
                            style: TextStyle(fontSize: 16),
                          ),
                          LinearProgressIndicator(
                            value: value,
                          )
                        ],
                      ),
                    ),
                  )),
                );
              },
            ),
          ));
}

void hideLinearProgressDialog(BuildContext context) {
  Navigator.of(context).pop();
}
