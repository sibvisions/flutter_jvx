import 'package:flutter/material.dart';

class DownloadWrapper extends StatefulWidget {
  final Widget child;

  final Stream<bool> stream;

  DownloadWrapper({Key key, this.child, this.stream}) : super(key: key);

  @override
  _DownloadWrapperState createState() => _DownloadWrapperState();
}

class _DownloadWrapperState extends State<DownloadWrapper> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: widget.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data)
          return widget.child;
        else return Container();
      }
    );
  }
}
