import 'package:flutter/material.dart';

import '../../src/model/custom/custom_header.dart';

class CustomHeaderTest extends CustomHeader {
  const CustomHeaderTest({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(120);
}
