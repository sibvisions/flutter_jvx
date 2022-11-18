import 'package:flutter/material.dart';

enum ButtonState { idle, loading, success, fail }

/// Source: https://github.com/slm/progress-state-button
class ProgressButton extends StatefulWidget {
  /// [StateButton]s for different [ButtonState]s
  final Map<ButtonState, StateButton> stateButtons;

  /// Default text style for buttons
  final TextStyle? textStyle;

  /// Current state of button
  final ButtonState state;

  /// onPressed from [MaterialButton]
  final Function()? onPressed;

  /// Will be called when animation ended
  final Function(AnimationStatus status, ButtonState state)? onAnimationEnd;

  /// Min width when used with [minWidthStates]
  final double minWidth;

  /// Max button width, will be used when [state] is not in [minWidthStates]
  final double maxWidth;

  /// Button radius
  final double radius;

  /// Button height
  final double height;

  /// Custom progress indicator
  final ProgressIndicator? progressIndicator;

  /// Size of progress indicator
  final Size progressIndicatorSize;

  /// ProgressIndicator alignment
  final MainAxisAlignment progressIndicatorAlignment;

  /// Padding of button
  final EdgeInsets padding;

  /// List of min width states, [ButtonState.loading] is the default. If you want to make small only icon states define them on this.
  final List<ButtonState> minWidthStates;

  /// Transition animation duration
  final Duration animationDuration;

  ProgressButton({
    super.key,
    required this.stateButtons,
    this.onPressed,
    this.state = ButtonState.idle,
    this.textStyle,
    this.onAnimationEnd,
    this.minWidth = 200.0,
    this.maxWidth = 400.0,
    this.radius = 16.0,
    this.height = 53.0,
    this.progressIndicatorSize = const Size.square(35.0),
    this.progressIndicator,
    this.progressIndicatorAlignment = MainAxisAlignment.center,
    this.padding = EdgeInsets.zero,
    this.minWidthStates = const [ButtonState.loading],
    this.animationDuration = const Duration(milliseconds: 250),
  }) : assert(
          stateButtons.keys.contains(ButtonState.idle),
          "Must be non-null widgets provided in map of stateWidgets. Minimum required states => ${ButtonState.idle}",
        );

  ProgressButton.icon({
    super.key,
    required this.stateButtons,
    this.onPressed,
    this.state = ButtonState.idle,
    this.textStyle,
    this.onAnimationEnd,
    this.maxWidth = 170.0,
    this.minWidth = 58.0,
    this.height = 53.0,
    this.radius = 100.0,
    this.progressIndicatorSize = const Size.square(35.0),
    this.progressIndicator,
    this.progressIndicatorAlignment = MainAxisAlignment.center,
    this.padding = EdgeInsets.zero,
    this.minWidthStates = const [ButtonState.loading],
    this.animationDuration = const Duration(milliseconds: 250),
  }) : assert(
          stateButtons.keys.contains(ButtonState.idle),
          "Must be non-null widgets provided in map of stateWidgets. Minimum required states => ${ButtonState.idle}",
        );

  @override
  State<StatefulWidget> createState() {
    return _ProgressButtonState();
  }
}

class _ProgressButtonState extends State<ProgressButton> with TickerProviderStateMixin {
  late AnimationController colorAnimationController;
  Animation<Color?>? colorAnimation;

  Color? getStateColor(BuildContext context, ButtonState buttonState) {
    return widget.stateButtons[buttonState]?.color ?? Theme.of(context).colorScheme.primary;
  }

  @override
  void initState() {
    super.initState();

    colorAnimationController = AnimationController(duration: widget.animationDuration, vsync: this);
    colorAnimationController.addStatusListener((status) {
      if (widget.onAnimationEnd != null) {
        widget.onAnimationEnd!(status, widget.state);
      }
    });
  }

  @override
  void didUpdateWidget(ProgressButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    colorAnimationController.duration = widget.animationDuration;

    if (oldWidget.state != widget.state) {
      colorAnimationController.reset();
      startAnimations(oldWidget.state, widget.state);
    }
  }

  void startAnimations(ButtonState oldState, ButtonState newState) {
    Color? begin = getStateColor(context, oldState);
    Color? end = getStateColor(context, newState);

    colorAnimation = ColorTween(begin: begin, end: end).animate(CurvedAnimation(
      parent: colorAnimationController,
      curve: const Interval(0, 1, curve: Curves.easeIn),
    ));
    colorAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: colorAnimationController,
      builder: (context, child) {
        final TextStyle mergedTextStyle = const TextStyle(fontWeight: FontWeight.w500)
            .merge(widget.textStyle)
            .merge(widget.stateButtons[widget.state]?.textStyle);
        return AnimatedContainer(
          width: (widget.minWidthStates.contains(widget.state)) ? widget.minWidth : widget.maxWidth,
          height: widget.height,
          duration: widget.animationDuration,
          child: MaterialButton(
            padding: widget.padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.radius),
              side: const BorderSide(color: Colors.transparent, width: 0),
            ),
            color: colorAnimation == null
                ? getStateColor(context, widget.state)
                : colorAnimation!.value ?? getStateColor(context, widget.state),
            textColor: mergedTextStyle.color ?? Theme.of(context).colorScheme.onPrimary,
            onPressed: widget.onPressed,
            child: DefaultTextStyle.merge(
              style: mergedTextStyle,
              child: getButtonChild(colorAnimation == null ? true : colorAnimation!.isCompleted),
            ),
          ),
        );
      },
    );
  }

  Widget getButtonChild(bool visibility) {
    StateButton? buttonChild = widget.stateButtons[widget.state];

    if (widget.state == ButtonState.loading) {
      return Row(
        mainAxisAlignment: widget.progressIndicatorAlignment,
        children: [
          SizedBox(
            width: widget.progressIndicatorSize.width,
            height: widget.progressIndicatorSize.height,
            child: widget.progressIndicator ??
                CircularProgressIndicator(
                  backgroundColor: getStateColor(context, widget.state),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
          ),
          buttonChild?.child ?? const SizedBox.shrink(),
        ],
      );
    }

    return AnimatedOpacity(
      opacity: visibility ? 1.0 : 0.0,
      duration: widget.animationDuration,
      child: buttonChild?.child ?? widget.stateButtons[ButtonState.idle]!.child!,
    );
  }

  @override
  void dispose() {
    colorAnimationController.dispose();
    super.dispose();
  }
}

class StateButton {
  /// Background color, used by the animations, defaults to [Theme.primary]
  final Color? color;

  /// Text style
  final TextStyle? textStyle;

  /// Widget that will be placed inside a MaterialButton, often used with [IconedButton]
  final Widget? child;

  const StateButton({
    this.child,
    this.color,
    this.textStyle,
  });
}

class IconedButton extends StatelessWidget {
  final String? text;
  final Widget? icon;
  final double iconPadding;

  const IconedButton({
    super.key,
    this.text,
    this.icon,
    this.iconPadding = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    children.add(icon ?? const SizedBox.shrink());
    if (text != null) {
      children.add(Padding(padding: EdgeInsets.all(iconPadding)));
      children.add(Text(text!));
    }

    return Wrap(
      direction: Axis.horizontal,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}
