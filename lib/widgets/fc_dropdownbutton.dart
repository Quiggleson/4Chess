import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/fc_colors.dart';

//TODO: ADD STYLE DEFAULTSCUSTOMIZE FEATURES + CHANGE SELECTED COLOR
class FCDropDownButton<T> extends StatefulWidget {
  const FCDropDownButton(
      {Key? key,
      required this.items,
      this.selectedItemBuilder,
      this.value,
      this.hint,
      this.disabledHint,
      this.onChanged,
      this.onTap,
      this.elevation = 8,
      this.style,
      this.icon,
      this.iconDisabledColor,
      this.iconEnabledColor,
      this.iconSize = 48,
      this.isDense = false,
      this.isExpanded = true,
      this.itemHeight = 90,
      this.color = FCColors.accentBlue,
      this.focusNode,
      this.autofocus = false,
      this.dropdownColor = FCColors.primaryBlue,
      this.menuMaxHeight,
      this.enableFeedback,
      this.alignment = AlignmentDirectional.centerStart,
      this.border,
      this.borderRadius,
      this.padding})
      : super(key: key);

  final List<DropdownMenuItem<T>>? items;
  final DropdownButtonBuilder? selectedItemBuilder;
  final T? value;
  final Widget? hint;
  final Widget? disabledHint;
  final ValueChanged<T?>? onChanged;
  final VoidCallback? onTap;
  final int elevation;
  final TextStyle? style;
  final Widget? icon;
  final Color? iconDisabledColor;
  final Color? iconEnabledColor;
  final double iconSize;
  final bool isDense;
  final bool isExpanded;
  final double? itemHeight;
  final Color color;
  final FocusNode? focusNode;
  final bool autofocus;
  final Color? dropdownColor;
  final double? menuMaxHeight;
  final bool? enableFeedback;
  final AlignmentGeometry alignment;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Border? border;

  @override
  FCDropdownButtonState<T> createState() => FCDropdownButtonState<T>();
}

class FCDropdownButtonState<T> extends State<FCDropDownButton<T>> {
  @override
  Widget build(BuildContext context) {
    return Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          border: widget.border ??
              Border.all(
                  width: 3,
                  color: widget.color,
                  strokeAlign: BorderSide.strokeAlignInside),
          color: widget.dropdownColor,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(15),
        ),
        child: DropdownButtonHideUnderline(
            child: DropdownButton(
          icon: widget.icon ??
              Container(
                  constraints: BoxConstraints(
                      minHeight: widget.itemHeight ?? 90, minWidth: 72),
                  color: widget.color,
                  child:
                      const Icon(Icons.arrow_drop_down, color: Colors.black)),
          iconSize: widget.iconSize,
          isExpanded: widget.isExpanded,
          itemHeight: widget.itemHeight,
          style: widget.style ??
              GoogleFonts.abel(
                color: Colors.black,
                fontSize: 56,
              ),
          borderRadius: widget.borderRadius,
          dropdownColor: widget.dropdownColor,
          value: widget.value,
          items: widget.items,
          onChanged: widget.onChanged,
        )));
  }
}
