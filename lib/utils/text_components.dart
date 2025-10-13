import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class TextComponents {

  // DYNAMIC USER DATA (MUTABLE PROPERTIES)

  static String userName = "Guest"; // Mutable property for dynamic user name
  static String userEmail = "guest@example.com"; // Mutable property for dynamic email


  // MY PROJECTS PAGE STRINGS

  static String myProjectsTitle() => "My Projects";
  static String loadingProjects() => "Loading projects...";
  static String projectsLoadError() => "Couldn't load projects.";
  static String noProjectsYet() => "No projects yet";
  static String createFirstProject() =>
      "Start by creating your first project to save and organize your designs!";
  static String createProject() => "Create Project";
  static String createNewProject() => "Create New Project";
  static String cancel() => "Cancel";
  static String create() => "Create";
  static String editProject() => "Edit Project";
  static String save() => "Save";
  static String enterProjectName() => "Enter project name";
  static String enterNewName() => "Enter new project name";

  static String deleteProject() => "Delete Project";
  static String deleteConfirmation(String projectTitle) {
    return "Are you sure you want to delete \"$projectTitle\"?";
  }

  static String retry() {
    return "Retry";
  }

  static String projectsCount(int count) =>
      "$count Project${count != 1 ? 's' : ''}";

  static String createdBy(String creator) => "Created by $creator";
  static String lastUpdate(String date) => "Last update $date";




// MY LIKES PAGE STRINGS

  static String myLikesTitle() => "My Likes";
  static String noLikedItemsYet() => "No liked items yet";
  static String likedItemsDescription() => "Items you like will appear here";
  static String exploreProducts() => "Explore Products";
  static String exploreMoreProducts() => "Explore More Products";
  static String errorLoadingLikes(String errorMessage) =>
      "Failed to load liked items. Error: $errorMessage";




  //  FALLBACK MESSAGES & PLACEHOLDERS

  static String get dataLoadFallback => "Couldn't load data, showing saved info instead.";
  static String get welcomeGuest => "Welcome, Guest!";
  static String get fallbackUserName => "Guest User";
  static String get fallbackProjectCreator => "Unknown User";


  // HELP PAGE STRINGS

  static String helpPageTitle() => "How can we help you?";
  static String searchPlaceholder() => "Search for help topics...";
  static String gettingStarted() => "Getting Started";
  static String generalDescription() => "General description";
  static String importGuides() => "Import guides";
  static String additionalServices() => "Additional services";
  static String guides() => "Guides";
  static String faq() => "FAQ";
  static String errorLoadingHelp() =>
      "Failed to load help content. Please try again.";
  static String contactSupport() => "Contact Support";


  // SHARED TEXT STYLES

  static TextStyle header18 = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryDarkBlue,
  );

  static TextStyle header16 = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryDarkBlue,
  );

  static TextStyle header14Bold = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryDarkBlue,
  );

  static TextStyle body14 = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryDarkBlue,
  );

  static TextStyle body13Grey = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.grey,
    height: 1.4,
  );

  static TextStyle hintStyle = GoogleFonts.inter(
    fontSize: 14,
    color: AppColors.grey.withOpacity(0.8),
  );


  // METHODS TO UPDATE DYNAMIC CONTENT


  /// Updates the user name dynamically (to be called after login/user data fetch)
  static void updateUserName(String newName) {
    userName = newName;
  }

  /// Updates the user email dynamically
  static void updateUserEmail(String newEmail) {
    userEmail = newEmail;
  }

  /// Resets user data to guest/default values
  static void resetToGuest() {
    userName = "Guest";
    userEmail = "guest@example.com";
  }
}