import 'dart:ui' as ui show BoxHeightStyle, BoxWidthStyle;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/fc_colors.dart';

class FCTextField extends TextField {
  FCTextField(
      {Key? key,
      String? hintText,
      TextEditingController? controller,
      FocusNode? focusNode,
      UndoHistoryController? undoController,
      InputDecoration? decoration,
      TextInputType? keyboardType,
      TextInputAction? textInputAction,
      TextCapitalization textCapitalization = TextCapitalization.characters,
      TextStyle? style,
      StrutStyle? strutStyle,
      TextAlign? textAlign,
      TextAlignVertical? textAlignVertical,
      TextDirection? textDirection,
      bool readOnly = false,
      bool? showCursor,
      bool autofocus = false,
      String obscuringCharacter = '•',
      bool obscureText = false,
      bool? autocorrect,
      SmartDashesType? smartDashesType,
      SmartQuotesType? smartQuotesType,
      bool enableSuggestions = true,
      int? maxLines = 1,
      int? minLines,
      bool expands = false,
      int? maxLength,
      MaxLengthEnforcement? maxLengthEnforcement,
      ValueChanged<String>? onChanged,
      VoidCallback? onEditingComplete,
      ValueChanged<String>? onSubmitted,
      AppPrivateCommandCallback? onAppPrivateCommand,
      List<TextInputFormatter>? inputFormatters,
      bool? enabled,
      double cursorWidth = 2.0,
      double? cursorHeight,
      Radius? cursorRadius,
      bool? cursorOpacityAnimates,
      Color? cursorColor,
      ui.BoxHeightStyle selectionHeightStyle = ui.BoxHeightStyle.tight,
      ui.BoxWidthStyle selectionWidthStyle = ui.BoxWidthStyle.tight,
      Brightness? keyboardAppearance,
      EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
      DragStartBehavior dragStartBehavior = DragStartBehavior.start,
      bool? enableInteractiveSelection,
      TextSelectionControls? selectionControls,
      GestureTapCallback? onTap,
      TapRegionCallback? onTapOutside,
      MouseCursor? mouseCursor,
      InputCounterWidgetBuilder? buildCounter,
      ScrollController? scrollController,
      ScrollPhysics? scrollPhysics,
      Iterable<String>? autofillHints = const <String>[],
      ContentInsertionConfiguration? contentInsertionConfiguration,
      Clip clipBehavior = Clip.hardEdge,
      String? restorationId,
      bool scribbleEnabled = true,
      bool enableIMEPersonalizedLearning = true,
      EditableTextContextMenuBuilder contextMenuBuilder =
          _defaultContextMenuBuilder,
      bool canRequestFocus = true,
      SpellCheckConfiguration? spellCheckConfiguration,
      TextMagnifierConfiguration? magnifierConfiguration})
      : super(
            key: key,
            controller: controller,
            focusNode: focusNode,
            undoController: undoController,
            decoration: decoration ??
                InputDecoration(
                  hintText: hintText,
                  counterStyle: const TextStyle(fontSize: 24),
                  filled: true,
                  fillColor: FCColors.primaryBlue,
                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: FCColors.thinBorder, width: 3),
                      borderRadius: BorderRadius.circular(15)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: FCColors.thinBorder, width: 3),
                      borderRadius: BorderRadius.circular(15)),
                ),
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            textCapitalization: textCapitalization,
            style: style ??
                GoogleFonts.aBeeZee(fontSize: 48, fontStyle: FontStyle.italic),
            strutStyle: strutStyle,
            textAlign: textAlign ?? TextAlign.center,
            textAlignVertical: textAlignVertical,
            textDirection: textDirection,
            readOnly: readOnly,
            showCursor: showCursor,
            autofocus: autofocus,
            obscuringCharacter: obscuringCharacter,
            obscureText: obscureText,
            autocorrect: autocorrect ?? false,
            smartDashesType: smartDashesType,
            smartQuotesType: smartQuotesType,
            enableSuggestions: enableSuggestions,
            maxLines: maxLines,
            minLines: minLines,
            expands: expands,
            maxLength: maxLength,
            maxLengthEnforcement: maxLengthEnforcement,
            onChanged: onChanged,
            onEditingComplete: onEditingComplete,
            onSubmitted: onSubmitted,
            onAppPrivateCommand: onAppPrivateCommand,
            inputFormatters: inputFormatters ?? [UpperCaseTextFormatter()],
            enabled: enabled,
            cursorWidth: cursorWidth,
            cursorHeight: cursorHeight,
            cursorRadius: cursorRadius,
            cursorOpacityAnimates: cursorOpacityAnimates,
            cursorColor: cursorColor,
            selectionHeightStyle: selectionHeightStyle,
            selectionWidthStyle: selectionWidthStyle,
            keyboardAppearance: keyboardAppearance,
            scrollPadding: scrollPadding,
            dragStartBehavior: dragStartBehavior,
            enableInteractiveSelection: enableInteractiveSelection,
            selectionControls: selectionControls,
            onTap: onTap,
            onTapOutside: onTapOutside,
            mouseCursor: mouseCursor,
            buildCounter: buildCounter,
            scrollController: scrollController,
            scrollPhysics: scrollPhysics,
            autofillHints: autofillHints,
            contentInsertionConfiguration: contentInsertionConfiguration,
            clipBehavior: clipBehavior,
            restorationId: restorationId,
            enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
            contextMenuBuilder: contextMenuBuilder,
            canRequestFocus: canRequestFocus,
            spellCheckConfiguration: spellCheckConfiguration,
            magnifierConfiguration: magnifierConfiguration);

  static Widget _defaultContextMenuBuilder(
      BuildContext context, EditableTextState editableTextState) {
    return AdaptiveTextSelectionToolbar.editableText(
      editableTextState: editableTextState,
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
