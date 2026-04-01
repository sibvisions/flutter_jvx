/*
 * Copyright 2026 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */
import 'package:flutter/material.dart';

import '../jvx_colors.dart';

/// Acts like a standard [ElevatedButton] but shows a progress indicator as long as
/// pressed is executing
class ElevatedProgressButton extends StatefulWidget {
    /// Called when the button is tapped or otherwise activated.
    ///
    /// If this callback and [onLongPress] are null, then the button will be disabled.
    ///
    /// See also:
    ///
    ///  * [enabled], which is true if the button is enabled.
    final VoidCallback? onPressed;

    /// Called when the button is long-pressed.
    ///
    /// If this callback and [onPressed] are null, then the button will be disabled.
    ///
    /// See also:
    ///
    ///  * [enabled], which is true if the button is enabled.
    final VoidCallback? onLongPress;

    /// Called when a pointer enters or exits the button response area.
    ///
    /// The value passed to the callback is true if a pointer has entered this
    /// part of the material and false if a pointer has exited this part of the
    /// material.
    final ValueChanged<bool>? onHover;

    /// Handler called when the focus changes.
    ///
    /// Called with true if this widget's node gains focus, and false if it loses
    /// focus.
    final ValueChanged<bool>? onFocusChange;

    /// Customizes this button's appearance.
    ///
    /// Non-null properties of this style override the corresponding
    /// properties in [themeStyleOf] and [defaultStyleOf]. [WidgetStateProperty]s
    /// that resolve to non-null values will similarly override the corresponding
    /// [WidgetStateProperty]s in [themeStyleOf] and [defaultStyleOf].
    ///
    /// Null by default.
    final ButtonStyle? style;

    /// {@macro flutter.material.Material.clipBehavior}
    ///
    /// Defaults to [Clip.none] unless [ButtonStyle.backgroundBuilder] or
    /// [ButtonStyle.foregroundBuilder] is specified. In those
    /// cases the default is [Clip.antiAlias].
    final Clip? clipBehavior;

    /// {@macro flutter.widgets.Focus.focusNode}
    final FocusNode? focusNode;

    /// {@macro flutter.widgets.Focus.autofocus}
    final bool autofocus;

    /// {@macro flutter.material.inkwell.statesController}
    final WidgetStatesController? statesController;

    /// Determine whether this subtree represents a button.
    ///
    /// If this is null, the screen reader will not announce "button" when this
    /// is focused. This is useful for [MenuItemButton] and [SubmenuButton] when we
    /// traverse the menu system.
    ///
    /// Defaults to true.
    final bool? isSemanticButton;

    /// Text that describes the action that will occur when the button is pressed or
    /// hovered over.
    ///
    /// This text is displayed when the user long-presses or hovers over the button
    /// in a tooltip. This string is also used for accessibility.
    ///
    /// If null, the button will not display a tooltip.
    final String? tooltip;

    /// Whether the button is in loading state
    final bool loading;

    /// Typically the button's label.
    ///
    /// {@macro flutter.widgets.ProxyWidget.child}
    final Widget? child;

    const ElevatedProgressButton({
      super.key,
      required this.onPressed,
      this.onLongPress,
      this.onHover,
      this.onFocusChange,
      this.style,
      this.focusNode,
      this.autofocus = false,
      this.clipBehavior,
      this.statesController,
      this.isSemanticButton = true,
      this.tooltip,
      this.loading = false,
      required this.child,
    });

    @override
    State<ElevatedProgressButton> createState() => _ElevatedProgressButtonState();
}

class _ElevatedProgressButtonState extends State<ElevatedProgressButton> {
    ///whether button is in loading progress
    late bool _isLoading;

    @override
    void initState() {
        super.initState();

        _isLoading = widget.loading;
    }

    @override
    Widget build(BuildContext context) {
        return ElevatedButton(
            key: widget.key,
            style: widget.style,
            focusNode: widget.focusNode,
            autofocus: widget.autofocus,
            clipBehavior: widget.clipBehavior,
            onFocusChange: widget.onFocusChange,
            onHover: widget.onHover,
            statesController: widget.statesController,
            onLongPress: widget.onLongPress,
            onPressed: widget.loading || _isLoading ? () {} : _handlePress,
            child: widget.loading || _isLoading
                ? SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: JVxColors.DARKER_WHITE,
                ),
            )
                : widget.child,
        );
    }

    Future<void> _handlePress() async {
        if (widget.loading || _isLoading) return;

        setState(() => _isLoading = true);

        try {
            widget.onPressed!();
        } finally {
            _isLoading = false;

            if (mounted) {
                setState(() {});
            }
        }
    }

}