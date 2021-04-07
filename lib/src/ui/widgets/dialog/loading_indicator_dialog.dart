import 'package:flutter/material.dart';

showLoadingIndicator(BuildContext context) {
  showDialog(
      routeSettings: RouteSettings(name: '/loading'),
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Opacity(
            opacity: 0.7,
            child: Container(
              child: Center(
                child: Container(
                  width: 100,
                  height: 100,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [CircularProgressIndicator.adaptive()],
                  ),
                ),
              ),
            ),
          ),
        );
      });
}

hideLoading(BuildContext context) {
  Navigator.of(context).pop();
}
