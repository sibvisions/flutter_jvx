import 'package:flutter/material.dart';

import '../custom/custom_header.dart';

class CustomHeaderExample extends CustomHeader {
  const CustomHeaderExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(120);
}
