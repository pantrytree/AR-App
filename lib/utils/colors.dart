import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ======================
  // 🎨 CORE BRAND COLORS
  // ======================

  // Primary Colors
  static const Color primaryPurple = Color(0xFF963CF1);
  static const Color primaryDarkBlue = Color(0xFF14213D);
  static const Color primaryLightPurple = Color(0xFFE0D7FF);

  // Secondary Colors
  static const Color secondaryBackground = Color(0xFFF2F4FC);
  static const Color secondaryLightPurple = Color(0xFFDADDF2);
  static const Color secondaryLighterPurple = Color(0xFFC1C8F5);

  // ======================
  // 🎨 NEUTRAL COLORS
  // ======================
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color darkGrey = Color(0xFF14213D);
  static const Color mediumGrey = Color(0xFF666666);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color veryLightGrey = Color(0xFFF5F5F5);

  // ======================
  // 🎨 FUNCTIONAL COLORS
  // ======================
  static const Color error = Color(0xFFF44336);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // ======================
  // 🎨 COMPONENT-SPECIFIC COLORS
  // ======================

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

  // ======================
  // 🎨 GRADIENTS
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

  static const Gradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFb1b9e8), Color(0xFFf4f4ff)],
  );

  // ======================
  // 🎨 BACKEND TEAM COLORS
  // ======================
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

  // ======================
  // 🎨 CONSISTENCY COLORS
  // ======================
  static const Color background = Color(0xFFF2F4FC);
  static const Color textDark = Color(0xFF14213D);
  static const Color textLight = Color(0xFF666666);
  static const Color divider = Color(0xFFDADDF2);
  static const Color veryLightPurple = Color(0xFFE8E0FF);

  // ======================
  // 🎨 ADDITIONAL COLORS FROM TEAMMATE'S FILE
  // ======================

  // Light purple for selected tabs (MyLikes) - already exists as likesTabSelected
  // Even lighter purple for tabs - already exists as veryLightPurple

  // Pure white for cards and backgrounds - already exists as white
  // Pure black for text and icons - already exists as black

  // Dark grey for primary text - already exists as darkGrey
  // Medium grey for secondary text - already exists as mediumGrey
  // Standard grey for tertiary text and borders - already exists as grey
  // Light grey for backgrounds and subtle elements - already exists as lightGrey
  // Very light grey for placeholders and disabled states - already exists as veryLightGrey

  // Text field background color - already exists as textFieldBackground
  // Card background (usually white) - already exists as cardBackground
  // Button primary color (used in save buttons) - already exists as buttonPrimary
  // Purple for folder icons - already exists as folderPurple
  // Purple for heart icons in MyLikes - already exists as likesHeart
  // Shadow color for subtle shadows - already exists as shadowColor

  // Color for selected bottom navigation items - already exists as bottomNavSelected
  // Color for unselected bottom navigation items - already exists as bottomNavUnselected
  // Color for selected category tabs - already exists as categoryTabSelected
  // Color for unselected category tabs - already exists as categoryTabUnselected

  // Color for error states - already exists as error
  // Color for success states - already exists as success
  // Color for warning states - already exists as warning
  // Color for info states - already exists as info

  // Splash screens/Login/Signup specific colors
  static const Color splashBrackground = Color(0xFFb1b9e9);
  static const Color appNamecolor = Color(0xFFe2e4f7);
  static const Color signupButtonBackground = Color(0xFFf5f4ff);
  static const Color loginButtonBackground = Color(0xFF14213d);
  static const Color signupButtonText = Color(0xFF474a81);
  static const Color loginButtonText = Color(0xFFf0f1fa);

  // ======================
  // 🎨 DYNAMIC THEME METHODS (From Teammate's File)
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