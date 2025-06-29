import 'package:flutter/material.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_text_styles.dart';

class TPThemeData {
  static ThemeData get raw {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: TPColors.grayscale50,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        showUnselectedLabels: true,
        showSelectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: TPColors.white,
        selectedItemColor: TPColors.primary500,
        unselectedItemColor: TPColors.grayscale950,
        selectedLabelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: TPColors.primary500,
        labelStyle: TPTextStyles.h3SemiBold,
        labelPadding: EdgeInsets.symmetric(vertical: 12),
        unselectedLabelColor: TPColors.grayscale700,
        unselectedLabelStyle: TPTextStyles.h3Regular,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: UnderlineTabIndicator(
          borderRadius: BorderRadius.all(Radius.circular(2)),
          borderSide: BorderSide(color: TPColors.primary500, width: 4),
          insets: EdgeInsets.symmetric(horizontal: 16),
        ),
        indicatorAnimation: TabIndicatorAnimation.elastic,
        dividerHeight: 0,
      ),
      colorScheme: ColorScheme.fromSeed(seedColor: TPColors.primary500),
      appBarTheme: const AppBarTheme(
        backgroundColor: TPColors.white,
        foregroundColor: TPColors.grayscale700,
        centerTitle: true,
        elevation: 0.0,
        iconTheme: IconThemeData(size: 56),
        actionsIconTheme: IconThemeData(size: 56),
      ),
      actionIconTheme: ActionIconThemeData(
        backButtonIconBuilder: (_) => Semantics(
          excludeSemantics: true,
          child: Assets.svg.iconLeftArrow.svg(width: 24, height: 24),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: TPColors.red50,
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
