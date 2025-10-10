class TextComponents {
  // App Titles
  static const String appTitle = "Roomantic";

  // Catalogue Page
  static const String cataloguePageTitle = 'Catalogue';
  static const String catalogueHeaderTitle = 'Find Your Style';
  static const String catalogueHeaderSubtitle = 'Discover perfect furniture for your space';
  static const String searchHint = 'Search furniture...';
  static const String noItemsFound = 'No items found';

  // Settings Page
  static const String settingsPageTitle = 'Settings';

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
  static const String userGreeting = "Hello!";

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
  static const String forgotPasswordTitle = "Reset Password";
  static const String resetPasswordTitle = "Reset Password";
  static const String logoutTitle = "Logout";
  static const String favoritesTitle = "My Favorites";

  // Home Screen
  static const String homeGreeting = "Welcome back!";
  static const String homeWelcome = "Let's design your dream space";
  static const String searchPlaceholder = "Search furniture...";
  static const String recentlyUsedTitle = "Recently Used";
  static const String recentlyUsedSubtitle = "Your recent items";
  static const String allRoomsTitle = "All Rooms";

  // Recently Used Items
  static const String recentItemBeigeCouch = "Beige Couch";
  static const String recentItemPinkBed = "Pink Bed";
  static const String recentItemSilver = "Silver Lamp";

  // Room Categories - USED IN CATALOGUE
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
  static const String logoutConfirmationQuestion = "Are you sure you want to logout?";
  static const String logoutDescription = "You will need to log in again to access your projects and favorites.";
  static const String cancelButton = "Cancel";
  static const String logoutButton = "Logout";

  // AR View Page
  static const String arViewPlaceholder = "AR View - Place your furniture in real world";

  // Product Details
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
  static const String errorLoadingCatalogue = "Error loading catalogue";
  static const String tryAgain = "Try Again";

  // Success Messages
  static const String cacheCleared = "Cache cleared";
  static const String addedToProject = "Added to Project!";
  static const String arViewComingSoon = "AR View Coming Soon!";

  // Dynamic methods for categories
  static List<String> get roomCategories => [
    roomCategoryBedroom,
    roomCategoryLiving,
    roomCategoryKitchen,
  ];
}