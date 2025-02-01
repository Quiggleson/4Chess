import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/fc_colors.dart';

class FCAppBar extends AppBar {
  FCAppBar(
      {Key? key,
      Widget? leading,
      bool automaticallyImplyLeading = true,
      Widget? title,
      List<Widget>? actions,
      Widget? flexibleSpace,
      PreferredSizeWidget? bottom,
      double? elevation,
      double? scrolledUnderElevation,
      ScrollNotificationPredicate notificationPredicate =
          defaultScrollNotificationPredicate,
      Color? shadowColor,
      Color? surfaceTintColor,
      ShapeBorder? shape,
      Color? backgroundColor,
      Color? foregroundColor,
      IconThemeData? iconTheme,
      IconThemeData? actionsIconTheme,
      bool primary = true,
      bool? centerTitle,
      bool excludeHeaderSemantics = false,
      double? titleSpacing,
      double toolbarOpacity = 1.0,
      double bottomOpacity = 1.0,
      double? toolbarHeight,
      double? leadingWidth,
      TextStyle? toolbarTextStyle,
      TextStyle? titleTextStyle,
      SystemUiOverlayStyle? systemOverlayStyle,
      bool forceMaterialTransparency = false,
      Clip? clipBehavior})
      : super(
            key: key,
            leading: leading ??
                BackButton(style: IconButton.styleFrom(enableFeedback: false)),
            automaticallyImplyLeading: automaticallyImplyLeading,
            title: title,
            actions: actions,
            flexibleSpace: flexibleSpace,
            bottom: bottom,
            elevation: elevation ?? 0,
            scrolledUnderElevation: scrolledUnderElevation,
            notificationPredicate: notificationPredicate,
            shadowColor: shadowColor,
            surfaceTintColor: surfaceTintColor,
            shape: shape ??
                const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                )),
            backgroundColor: backgroundColor ?? FCColors.primaryBlue,
            foregroundColor: foregroundColor ?? Colors.black,
            iconTheme: iconTheme,
            actionsIconTheme: actionsIconTheme,
            primary: primary,
            centerTitle: centerTitle ?? true,
            excludeHeaderSemantics: excludeHeaderSemantics,
            titleSpacing: titleSpacing,
            toolbarOpacity: toolbarOpacity,
            bottomOpacity: bottomOpacity,
            toolbarHeight: toolbarHeight ?? 70,
            leadingWidth: leadingWidth,
            toolbarTextStyle: toolbarTextStyle,
            titleTextStyle: titleTextStyle ??
                GoogleFonts.abel(fontSize: 48, color: Colors.black),
            systemOverlayStyle: systemOverlayStyle,
            forceMaterialTransparency: forceMaterialTransparency,
            clipBehavior: clipBehavior);
}
