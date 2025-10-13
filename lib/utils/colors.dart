// AppColors - Comprehensive Color System for Roomanties
//
// PURPOSE: Centralized color management for consistent UI/UX
//
// COLOR SYSTEM:
// - Brand Colors: Primary purple (#963CF1) and dark blue (#14213D)
// - Semantic Colors: Success, Error, Warning, Info states
// - Dynamic Methods: Theme-aware color getters for dark/light mode
//
// USAGE:
// - Static colors: AppColors.primaryPurple
// - Dynamic colors: AppColors.getBackgroundColor(context)
// - Gradients: AppColors.primaryGradient
//
// DESIGN TOKENS: All colors follow design system specifications

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // Private constructor - static usage only

  // Main brand purple - used for buttons, highlights, important elements
  static const Color primaryPurple = Color(0xFF963CF1);

  // Dark navy blue - used for primary text, titles, important labels
  static const Color primaryDarkBlue = Color(0xFF14213D);

  // Light purple - used for backgrounds, secondary elements
  static const Color primaryLightPurple = Color(0xFFE0D7FF);

  // Light purple background - used for pages, cards
  static const Color secondaryBackground = Color(0xFFF2F4FC);

  // Light purple for tabs and selections
  static const Color secondaryLightPurple = Color(0xFFDADDF2);

  // Lighter purple for tabs
  static const Color secondaryLighterPurple = Color(0xFFC1C8F5);

  // Light purple for selected tabs (MyLikes)
  static const Color likesTabSelected = Color(0xFFCACEED);

  // Even lighter purple for tabs
  static const Color veryLightPurple = Color(0xFFE8E0FF);

  // Pure white for cards and backgrounds
  static const Color white = Color(0xFFFFFFFF);

  // Pure black for text and icons
  static const Color black = Color(0xFF000000);

  // Dark grey for primary text
  static const Color darkGrey = Color(0xFF14213D); // Same as primaryDarkBlue

  // Medium grey for secondary text
  static const Color mediumGrey = Color(0xFF666666);

  // Standard grey for tertiary text and borders
  static const Color grey = Color(0xFF9E9E9E);

  // Light grey for backgrounds and subtle elements
  static const Color lightGrey = Color(0xFFE0E0E0);

  // Very light grey for placeholders and disabled states
  static const Color veryLightGrey = Color(0xFFF5F5F5);

  // Text field background color
  static const Color textFieldBackground = Color(0xFFDADDF2);

  // Card background (usually white)
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Button primary color (used in save buttons)
  static const Color buttonPrimary = Color(0xFF99A0D1);

  // Purple for folder icons
  static const Color folderPurple = Color(0xFF963CF1);

  // Purple for heart icons in MyLikes
  static const Color likesHeart = Color(0xFFDADDF2);

  // Shadow color for subtle shadows
  static const Color shadowColor = Color(0x1A000000); // 10% opacity black

  // Color for selected bottom navigation items
  static const Color bottomNavSelected = Color(0xFFDADDF2);

  // Color for unselected bottom navigation items
  static const Color bottomNavUnselected = Color(0xFF000000);

  // Color for selected category tabs
  static const Color categoryTabSelected = Color(0xFFCACEED);

  // Color for unselected category tabs
  static const Color categoryTabUnselected = Color(0xFFC1C8F5);

  // Color for error states
  static const Color error = Color(0xFFF44336);

  // Color for success states
  static const Color success = Color(0xFF4CAF50);

  // Color for warning states
  static const Color warning = Color(0xFFFF9800);

  // Color for info states
  static const Color info = Color(0xFF2196F3);

  // ======================
  // 🎨 SIDE MENU COLORS
  // ======================
  static const Color sideMenuBackground = Color(0xFFF2F4FC);
  static const Color sideMenuDivider = Color(0xFFDADDF2);
  static const Color sideMenuIcon = Color(0xFF14213D);
  static const Color sideMenuItemText = Color(0xFF14213D);

  // ======================
  // 🎨 GRADIENT COLORS
  // ======================
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

  // MyProjects specific colors
  static const Color projectCardShadow = Color(0x14000000);
  static const Color projectFolderBackground = Color(0xFFE0D7FF);
  static const Color projectFolderIcon = Color(0xFF963CF1);
  static const Color projectTextPrimary = Color(0xFF14213D);
  static const Color projectTextSecondary = Color(0xFF666666);
  static const Color projectCreatorDot = Color(0xFF963CF1);

  // MyLikes specific colors
  static const Color likesEmptyStateHeart = Color(0xFFDADDF2);
  static const Color likesTabBorder = Color(0xFFC1C8F5);
  static const Color likesTabUnselected = Color(0xFFC1C8F5);

  // HelpPage specific colors
  static const Color helpSearchBackground = Color(0xFFDADDF2);
  static const Color helpSearchIcon = Color(0xFF9E9E9E);
  static const Color helpCardShadow = Color(0x14000000);
  static const Color helpArrowIcon = Color(0xFF9E9E9E);

  // ======================
  // 🎨 BACKEND TEAM COLORS (Your colors)
  // ======================
  static const Color splashScreenBackground = Color(0xFFB1B9E8);
  static const Color splashScreenText = Color(0xFFE3E4F6);
  static const Color lightBlueOpaque = Color(0x4DB1B9E8);
  static const Color lightBlue = Color(0xFFF4F4FF);
  static const Color greyBlue = Color(0xFF464A80);
  static const Color blackOpaque = Color(0x7D111111);
  static const Color greyLavender = Color(0xFFC29EC8);
  static const Color greyLavenderOpaque = Color(0x7DC29EC8);
  static const Color pastelGreyBlue = Color(0xFF99A0D1);
  static const Color pastelGreyBlueOpaque = Color(0x9699A0D1);
  static const Color purplePink = Color(0xFFCB6CE6);

  // ======================
  // 🎨 CONSISTENCY COLORS - Bulelwa's Assigned Pages Colors
  // ======================
  static const Color background = Color(0xFFF2F4FC);
  static const Color textDark = Color(0xFF14213D);
  static const Color textLight = Color(0xFF666666);
  static const Color divider = Color(0xFFDADDF2);

  // ======================
  // 🎨 DYNAMIC THEME METHODS
  // ======================

  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? primaryDarkBlue
        : secondaryBackground;
  }

  static Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? white
        : primaryDarkBlue;
  }

  static Color getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? grey
        : mediumGrey;
  }

  static Color getPrimaryColor(BuildContext context) {
    return primaryPurple;
  }

  static Color getCategoryTabSelected(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? secondaryLightPurple
        : categoryTabSelected;
  }

  static Color getCategoryTabUnselected(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? secondaryLighterPurple
        : categoryTabUnselected;
  }

  static Color getCardBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? primaryDarkBlue
        : cardBackground;
  }

  static Color getAppBarBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? primaryDarkBlue
        : secondaryBackground;
  }

  static Color getAppBarForeground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? white
        : primaryDarkBlue;
  }

  static Color getTextFieldBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? primaryLightPurple.withOpacity(0.3)
        : textFieldBackground;
  }

  static Color getIconColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? white
        : primaryDarkBlue;
  }

  static Color getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? white.withOpacity(0.2)
        : primaryPurple.withOpacity(0.2);
  }

  // ======================
  // 🎨 SIDE MENU DYNAMIC METHODS
  // ======================

  static Color getSideMenuBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? primaryDarkBlue
        : sideMenuBackground;
  }

  static Color getSideMenuDivider(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? white.withOpacity(0.2)
        : sideMenuDivider;
  }

  static Color getSideMenuIcon(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? white
        : sideMenuIcon;
  }

  static Color getSideMenuItemText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? white
        : sideMenuItemText;
  }
}