import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  //  CORE BRAND COLORS

  // Primary Colors
  static const Color primaryPurple = Color(0xFF963CF1);
  static const Color primaryDarkBlue = Color(0xFF14213D);
  static const Color primaryLightPurple = Color(0xFFE0D7FF);

  // Secondary Colors
  static const Color secondaryBackground = Color(0xFFF2F4FC);
  static const Color secondaryLightPurple = Color(0xFFDADDF2);
  static const Color secondaryLighterPurple = Color(0xFFC1C8F5);

  //  NEUTRAL COLORS
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color darkGrey = Color(0xFF14213D);
  static const Color mediumGrey = Color(0xFF666666);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color veryLightGrey = Color(0xFFF5F5F5);

  // FUNCTIONAL COLORS
  static const Color error = Color(0xFFF44336);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // COMPONENT-SPECIFIC COLORS

  // Side Menu
  static const Color sideMenuBackground = Color(0xFFDADDF2);
  static const Color sideMenuHeader = Color(0xFFC1C8F5);
  static const Color sideMenuItemText = Color(0xFF14213D);
  static const Color sideMenuIcon = Color(0xFF963CF1);
  static const Color sideMenuDivider = Color(0xFFB1B9EB);

  // MyProjects
  static const Color projectCardShadow = Color(0x14000000);
  static const Color projectFolderBackground = Color(0xFFE0D7FF);
  static const Color projectFolderIcon = Color(0xFF963CF1);
  static const Color projectTextPrimary = Color(0xFF14213D);
  static const Color projectTextSecondary = Color(0xFF666666);
  static const Color projectCreatorDot = Color(0xFF963CF1);

  // MyLikes
  static const Color likesTabSelected = Color(0xFFCACEED);
  static const Color likesTabUnselected = Color(0xFFC1C8F5);
  static const Color likesTabBorder = Color(0xFFC1C8F5);
  static const Color likesEmptyStateHeart = Color(0xFFDADDF2);
  static const Color likesHeart = Color(0xFFDADDF2);

  // HelpPage
  static const Color helpSearchBackground = Color(0xFFDADDF2);
  static const Color helpSearchIcon = Color(0xFF9E9E9E);
  static const Color helpCardShadow = Color(0x14000000);
  static const Color helpArrowIcon = Color(0xFF9E9E9E);

  // UI Elements
  static const Color textFieldBackground = Color(0xFFDADDF2);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color buttonPrimary = Color(0xFF99A0D1);
  static const Color folderPurple = Color(0xFF963CF1);
  static const Color shadowColor = Color(0x1A000000);
  static const Color bottomNavSelected = Color(0xFFDADDF2);
  static const Color bottomNavUnselected = Color(0xFF000000);
  static const Color categoryTabSelected = Color(0xFFCACEED);
  static const Color categoryTabUnselected = Color(0xFFC1C8F5);

  // GRADIENTS
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF963CF1), Color(0xFF6B46C1)],
  );

  static const Gradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE0D7FF), Color(0xFFDADDF2)],
  );

  static const Gradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFb1b9e8), Color(0xFFf4f4ff)],
  );

  // BACKEND TEAM COLORS
  static const Color splashScreenBackground = Color(0xFFB1B9E8);
  static const Color splashScreenText = Color(0xFFe3e4f6);
  static const Color lightBlueOpaque = Color(0x4DB1B9E8);
  static const Color lightBlue = Color(0xFFf4f4ff);
  static const Color greyBlue = Color(0xFF464a80);
  static const Color blackOpaque = Color(0x7D111111);
  static const Color greyLavender = Color(0xFFc29ec8);
  static const Color greyLavenderOpaque = Color(0x7dc29ec8);
  static const Color pastelGreyBlue = Color(0xFF99a0d1);
  static const Color pastelGreyBlueOpaque = Color(0x9699a0d1);
  static const Color purplePink = Color(0xFFcb6ce6);

  //CONSISTENCY
  static const Color background = Color(0xFFF2F4FC);
  static const Color textDark = Color(0xFF14213D);
  static const Color textLight = Color(0xFF666666);
  static const Color divider = Color(0xFFDADDF2);
  static const Color veryLightPurple = Color(0xFFE8E0FF);
}