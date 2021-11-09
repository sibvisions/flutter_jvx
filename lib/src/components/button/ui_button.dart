import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_jvx/src/util/mixin/service/render_service_mixin.dart';

class UiButton extends StatefulWidget {
  const UiButton({Key? key}) : super(key: key);

  @override
  _UiButtonState createState() => _UiButtonState();
}

class _UiButtonState extends State<UiButton> with RenderServiceMixin {



  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      minWidth: 10,
      child: SizedBox(
        height: 50,
        child: ElevatedButton(
          onPressed: () => {log("I have been pressed :O")},
          child: const Text("Press Me!"),
        ),
      ),
    );
  }
}
