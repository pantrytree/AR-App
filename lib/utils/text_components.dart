class TextComponents {
  // App Titles
  static const String appTitle = "Roomantic";

  // Dynamic text methods
  static String userGreeting(String? displayName) {
    return displayName != null ? "Hi, $displayName" : "Hello!";
  }

  static String homeGreeting(String? displayName) {
    return displayName != null ? "Welcome back, $displayName!" : "Welcome back!";
  }

  // Side Menu Labels
  static const String menuHome = "Home";
  static const String menuCatalogue = "Catalogue";
  static const String menuLikes = "My Likes";
  static const String menuProjects = "My Projects";
  static const String menuSettings = "Settings";
  static const String menuHelp = "Help & Support";
  static const String menuForgotPassword = "Forgot Password";
  static const String menuEditProfile = "Edit Profile";
  static const String menuLogout = "Logout";

  // User related
  static const String userGreetingFallback = "Hello!";
  static const String userGreetingFormat = "Hi, %s";

  // Bottom Nav Labels
  static const String navHome = "Home";
  static const String navArView = "AR View";
  static const String navCart = "Cart";
  static const String navFavorites = "Favorites";
  static const String navProfile = "Profile";

  // Page Headings
  static const String homePageTitle = "Home";
  static const String arViewTitle = "AR View";
  static const String cartPageTitle = "Shopping Cart";
  static const String profilePageTitle = "My Profile";
  static const String cataloguePageTitle = "Product Details";
  static const String forgotPasswordTitle = "Reset Password";
  static const String resetPasswordTitle = "Reset Password";
  static const String logoutTitle = "Logout";
  static const String favoritesTitle = "My Favorites";

  // Home Screen
  static const String homeWelcome = "Let's design your dream space";
  static const String searchPlaceholder = "Search furniture...";
  static const String recentlyUsedTitle = "Recently Used";
  static const String recentlyUsedSubtitle = "Your recent items";
  static const String allRoomsTitle = "All Rooms";

  // Recently Used Items - These will now come from FurnitureItem data
  static const String recentItemBeigeCouch = "Beige Couch";
  static const String recentItemPinkBed = "Pink Bed";
  static const String recentItemSilver = "Silver Lamp";

  // Room Categories - These will now come from UserRoom data
  static const String roomCategoryLiving = "Living Room";
  static const String roomCategoryBedroom = "Bedroom";
  static const String roomCategoryKitchen = "Kitchen";
  static const String roomCategoryOffice = "Office";

  // Forgot Password Page
  static const String forgotPasswordDescription = "Enter your email address and we'll send you a link to reset your password.";
  static const String emailFieldLabel = "Email Address";
  static const String emailFieldHint = "your@email.com";
  static const String sendResetLinkButton = "Send Reset Link";
  static const String noAccountText = "Don't have an account?";
  static const String signUpButton = "Sign Up";

  // Logout Page
  static const String logoutConfirmationQuestion = "Are you logging out?";
  static const String logoutDetailedDescription =
      "You can always log back in\nat any time, if you just want\nto switch accounts, you can";
  static const String addAnotherAccount = "add another account";
  static const String cancelButton = "Cancel";
  static const String logoutButton = "Logout";

  // AR View Page
  static const String arViewPlaceholder = "AR View - Place your furniture in real world";

  // Product Details - These will now come from FurnitureItem data
  static const String productQueenBedTitle = "Queen Bed";
  static const String productQueenBedDimensions = "80×80 cm";
  static const String productQueenBedDescription = "Custom-made, handcrafted furniture designed to fit your unique style and space.";

  static const String productBedsideTableTitle = "Bedside Table";
  static const String productBedsideTableDimensions = "30×60 cm";

  static const String productWardrobeTitle = "Wardrobe";
  static const String productWardrobeDimensions = "120×200 cm";

  static const String productDresserTitle = "Dresser";
  static const String productDresserDimensions = "40×80 cm";

  static const String moreToExploreTitle = "More to explore";

  // Error Messages
  static const String networkError = "Network error occurred";
  static const String serverError = "Server error occurred";
  static const String unknownError = "An unknown error occurred";
  static const String loadingError = "Failed to load data";
  static const String retryButton = "Retry";

  // Success Messages
  static const String profileUpdated = "Profile updated successfully";
  static const String passwordResetSent = "Password reset link sent to your email";
  static const String logoutSuccess = "Logged out successfully";

  // Form Validation
  static const String emailRequired = "Email is required";
  static const String invalidEmail = "Please enter a valid email";
  static const String passwordRequired = "Password is required";
  static const String passwordTooShort = "Password must be at least 6 characters";
  static const String nameRequired = "Name is required";
  static const String confirmPasswordRequired = "Please confirm your password";
  static const String passwordsDontMatch = "Passwords do not match";

  // Empty States
  static const String noFavorites = "You haven't liked any items yet";
  static const String noProjects = "You haven't created any projects yet";
  static const String noRecentlyUsed = "No recently used items";
  static const String noRooms = "No rooms created yet";

  // Action Buttons
  static const String saveButton = "Save";
  static const String updateButton = "Update";
  static const String deleteButton = "Delete";
  static const String editButton = "Edit";
  static const String createButton = "Create";
  static const String addButton = "Add";
  static const String removeButton = "Remove";
  static const String continueButton = "Continue";
  static const String backButton = "Back";
  static const String nextButton = "Next";
  static const String doneButton = "Done";

  // Search and Filter
  static const String searchResults = "Search Results";
  static const String noSearchResults = "No items found";
  static const String filterButton = "Filter";
  static const String sortButton = "Sort";
  static const String clearFilters = "Clear Filters";

  // Categories
  static const String categoryAll = "All";
  static const String categoryLivingRoom = "Living Room";
  static const String categoryBedroom = "Bedroom";
  static const String categoryKitchen = "Kitchen";
  static const String categoryBathroom = "Bathroom";
  static const String categoryOffice = "Office";
  static const String categoryOutdoor = "Outdoor";

  // Furniture Properties
  static const String dimensionsLabel = "Dimensions";
  static const String materialsLabel = "Materials";
  static const String colorsLabel = "Colors";
  static const String styleLabel = "Style";
  static const String priceLabel = "Price";
  static const String ratingLabel = "Rating";
  static const String reviewsLabel = "Reviews";

  // AR Features
  static const String arPlaceObject = "Place in Room";
  static const String arMoveObject = "Move";
  static const String arRotateObject = "Rotate";
  static const String arScaleObject = "Scale";
  static const String arSaveDesign = "Save Design";
  static const String arReset = "Reset";
  static const String arInstructions = "Point your camera at a flat surface to place furniture";

  // Collaboration
  static const String inviteCollaborator = "Invite Collaborator";
  static const String collaborators = "Collaborators";
  static const String shareProject = "Share Project";
  static const String leaveProject = "Leave Project";

  // Settings
  static const String notifications = "Notifications";
  static const String privacy = "Privacy";
  static const String helpSupport = "Help & Support";
  static const String about = "About";
  static const String termsOfService = "Terms of Service";
  static const String privacyPolicy = "Privacy Policy";

  // Helper methods for dynamic content
  static String itemCount(int count) {
    return count == 1 ? '1 item' : '$count items';
  }

  static String roomCount(int count) {
    return count == 1 ? '1 room' : '$count rooms';
  }

  static String projectCount(int count) {
    return count == 1 ? '1 project' : '$count projects';
  }

  static String formatDimensions(Map<String, dynamic> dimensions) {
    final width = dimensions['width']?.toString() ?? '0';
    final height = dimensions['height']?.toString() ?? '0';
    final depth = dimensions['depth']?.toString() ?? '0';
    final unit = dimensions['unit']?.toString() ?? 'cm';
    return '${width}×${depth}×${height} $unit';
  }

  static String formatPrice(double price) {
    return '\$${price.toStringAsFixed(2)}';
  }

  static String formatRating(double rating) {
    return rating.toStringAsFixed(1);
  }
}