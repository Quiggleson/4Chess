import 'package:flutter/material.dart';
import 'package:fourchess/theme/fc_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class FCButton extends FilledButton {
  FCButton(
      {Key? key,
      required VoidCallback? onPressed,
      VoidCallback? onLongPress,
      ValueChanged<bool>? onHover,
      ValueChanged<bool>? onFocusChange,
      ButtonStyle? style,
      FocusNode? focusNode,
      bool autofocus = false,
      Clip clipBehavior = Clip.none,
      MaterialStatesController? statesController,
      required Widget? child})
      : super(
          key: key,
          onPressed: onPressed,
          onLongPress: onLongPress,
          onHover: onHover,
          onFocusChange: onFocusChange,
          style: _buildButtonStyle(style), //Method used only for cleanliness
          focusNode: focusNode,
          autofocus: autofocus,
          clipBehavior: clipBehavior,
          statesController: statesController,
          child: child,
        );

  static ButtonStyle _buildButtonStyle(ButtonStyle? style) {
    return ButtonStyle(
        textStyle: style?.textStyle ??
            MaterialStatePropertyAll(GoogleFonts.abel(fontSize: 56)),
        backgroundColor: style?.backgroundColor ??
            MaterialStateProperty.resolveWith((Set<MaterialState> states) {
              if (states.contains(MaterialState.disabled)) {
                return FCColors.primaryBlueDisabled;
              }

              return FCColors.primaryBlue;
            }),
        foregroundColor: style?.foregroundColor ??
            MaterialStateProperty.resolveWith((Set<MaterialState> states) {
              if (states.contains(MaterialState.disabled)) {
                return const Color.fromRGBO(0, 0, 0, .5);
              }

              return Colors.black;
            }),
        overlayColor: style?.overlayColor,
        shadowColor: style?.shadowColor,
        surfaceTintColor: style?.surfaceTintColor,
        elevation: style?.elevation,
        padding: style?.padding,
        minimumSize: style?.minimumSize ??
            const MaterialStatePropertyAll(Size.fromHeight(90)),
        fixedSize: style?.fixedSize,
        maximumSize: style?.maximumSize,
        iconColor: style?.iconColor,
        iconSize: style?.iconSize,
        side: style?.side,
        shape: style?.shape ??
            MaterialStatePropertyAll(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15))),
        mouseCursor: style?.mouseCursor,
        visualDensity: style?.visualDensity,
        tapTargetSize: style?.tapTargetSize,
        animationDuration: style?.animationDuration,
        enableFeedback: style?.enableFeedback,
        alignment: style?.alignment,
        splashFactory: style?.splashFactory);
  }

  static ButtonStyle styleFrom({
    Color? foregroundColor,
    Color? backgroundColor,
    Color? disabledForegroundColor,
    Color? disabledBackgroundColor,
    Color? shadowColor,
    Color? surfaceTintColor,
    double? elevation,
    TextStyle? textStyle,
    EdgeInsetsGeometry? padding,
    Size? minimumSize,
    Size? fixedSize,
    Size? maximumSize,
    BorderSide? side,
    OutlinedBorder? shape,
    MouseCursor? enabledMouseCursor,
    MouseCursor? disabledMouseCursor,
    VisualDensity? visualDensity,
    MaterialTapTargetSize? tapTargetSize,
    Duration? animationDuration,
    bool? enableFeedback,
    AlignmentGeometry? alignment,
    InteractiveInkFeatureFactory? splashFactory,
  }) {
    return FilledButton.styleFrom(
        foregroundColor: foregroundColor ?? Colors.black,
        backgroundColor: backgroundColor ?? FCColors.primaryBlue,
        disabledForegroundColor:
            disabledForegroundColor ?? const Color.fromRGBO(0, 0, 0, .5),
        disabledBackgroundColor:
            disabledBackgroundColor ?? FCColors.primaryBlueDisabled,
        shadowColor: shadowColor,
        surfaceTintColor: surfaceTintColor,
        elevation: elevation,
        textStyle: GoogleFonts.abel(fontSize: 56).merge(textStyle),
        padding: padding,
        minimumSize: minimumSize ?? const Size.fromHeight(90),
        fixedSize: fixedSize,
        maximumSize: maximumSize,
        side: side,
        shape: shape ??
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        enabledMouseCursor: enabledMouseCursor,
        disabledMouseCursor: disabledMouseCursor,
        visualDensity: visualDensity,
        tapTargetSize: tapTargetSize,
        animationDuration: animationDuration,
        enableFeedback: enableFeedback,
        alignment: alignment,
        splashFactory: splashFactory);
  }
}
