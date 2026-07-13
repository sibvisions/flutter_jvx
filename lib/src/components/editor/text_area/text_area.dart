import 'package:flutter/material.dart';

import '../text_field/fl_text_field_widget.dart';

class TextArea extends StatefulWidget {

  final FocusNode focusNode;

  final Widget child;

  final ({InputDecoration decoration, Widget? suffixIcon, int prefixCount, int suffixCount}) inputDecoration;

  final EdgeInsets contentPadding;

  const TextArea({
    super.key,
    required this.focusNode,
    required this.inputDecoration,
    required this.contentPadding,
    required this.child,
  });

  @override
  State<TextArea> createState() => _TextAreaState();
}

class _TextAreaState extends State<TextArea> {
  late final FocusNode focusNode;

  @override
  void initState() {
    super.initState();

    focusNode = widget.focusNode;
    focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    focusNode.removeListener(_onFocusChange);

    //!!! We won't dispose focusNode here, because it's done outside
    //focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double leftGap = widget.inputDecoration.prefixCount * FlTextFieldWidget.iconAreaSize + widget.contentPadding.left + FlTextFieldWidget.iconsPaddingHorizontal - 2;
    double rightGap = (widget.inputDecoration.suffixCount * FlTextFieldWidget.iconAreaSize) + (FlTextFieldWidget.iconsPaddingHorizontal * 2);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: 0,
          bottom: 0,
          left: leftGap,
          right: rightGap,
          child: LayoutBuilder(
              builder: (context, constraints) {
                  return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                          constraints: BoxConstraints(
                              minWidth: constraints.maxWidth,
                          ),
                          child: IntrinsicWidth(
                              child: widget.child,
                          ),
                      )
                  );
              },
          )
        ),
        if (leftGap > 0)
          Positioned(
            left: 0,
            width: leftGap,
            top: 0,
            bottom: 0,
            child: SizedBox.shrink()
          ),
        if (rightGap > 0)
          Positioned(
            right: 0,
            width: rightGap,
            top: 0,
            bottom: 0,
            child: widget.inputDecoration.suffixCount > 0 && widget.inputDecoration.suffixIcon != null ?
              Column(children: [widget.inputDecoration.suffixIcon!])
              :
              SizedBox.shrink()
          ),
        IgnorePointer(
          ignoring: true,
          child: InputDecorator(
            isFocused: focusNode.hasFocus,
            decoration: widget.inputDecoration.decoration,
          )
        )
      ],
    );
  }
}