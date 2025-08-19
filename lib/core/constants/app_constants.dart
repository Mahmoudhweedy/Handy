class AppConstants {
  // App Information
  static const String appName = 'Handy';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String themeKey = 'app_theme';
  static const String localeKey = 'app_locale';
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String fcmTokenKey = 'fcm_token';
  static const String cartKey = 'cart_items';
  static const String wishlistKey = 'wishlist_items';
  static const String recentSearchesKey = 'recent_searches';
  
  // Hive Box Names
  static const String settingsBox = 'settings';
  static const String userBox = 'user';
  static const String productsBox = 'products';
  static const String cartBox = 'cart';
  static const String ordersBox = 'orders';
  static const String bookingsBox = 'bookings';
  static const String cacheBox = 'cache';
  
  // API Endpoints
  static const String baseApiUrl = 'https://api.handy.com';
  static const String productsEndpoint = '/products';
  static const String categoriesEndpoint = '/categories';
  static const String ordersEndpoint = '/orders';
  static const String bookingsEndpoint = '/bookings';
  static const String authEndpoint = '/auth';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Cache Duration
  static const Duration cacheExpiry = Duration(hours: 24);
  static const Duration shortCacheExpiry = Duration(minutes: 15);
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const String emailPattern = r'^[\w\.-]+@[\w\.-]+\.\w+$';
  static const String phonePattern = r'^\+?[\d\s\-\(\)]+$';
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 8.0;
  static const double cardElevation = 2.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Error Messages
  static const String networkError = 'Network connection error';
  static const String serverError = 'Server error occurred';
  static const String unknownError = 'An unknown error occurred';
  static const String validationError = 'Please check your input';
  static const String authError = 'Authentication failed';
  static const String permissionError = 'Permission denied';
  
  // Success Messages
  static const String loginSuccess = 'Login successful';
  static const String registrationSuccess = 'Registration successful';
  static const String orderPlacedSuccess = 'Order placed successfully';
  static const String bookingConfirmedSuccess = 'Booking confirmed successfully';
  static const String profileUpdatedSuccess = 'Profile updated successfully';
  
  // Feature Flags
  static const bool enableGoogleSignIn = true;
  static const bool enableNotifications = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  
  // Image Constraints
  static const int maxImageSizeMB = 5;
  static const double imageQuality = 0.8;
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1080;
  
  // Product Categories
  static const List<String> productCategories = [
    'Tools',
    'Materials',
    'Hardware',
    'Electrical',
    'Plumbing',
    'Paint',
    'Garden',
    'Safety',
  ];
  
  // Order Status
  static const String orderPending = 'pending';
  static const String orderConfirmed = 'confirmed';
  static const String orderShipped = 'shipped';
  static const String orderDelivered = 'delivered';
  static const String orderCanceled = 'canceled';
  
  // Booking Status
  static const String bookingStatusPending = 'pending';
  static const String bookingStatusConfirmed = 'confirmed';
  static const String bookingStatusInProgress = 'in_progress';
  static const String bookingStatusCompleted = 'completed';
  static const String bookingStatusCanceled = 'canceled';
  
  // Legacy constants for backward compatibility
  static const String bookingPending = 'pending';
  static const String bookingConfirmed = 'confirmed';
  static const String bookingInProgress = 'in_progress';
  static const String bookingCompleted = 'completed';
  static const String bookingCanceled = 'canceled';
  
  // Supported Locales
  static const List<String> supportedLocales = ['en', 'ar'];
  
  // Default Values
  static const String defaultLocale = 'en';
  static const String defaultTheme = 'light';
  static const String defaultCurrency = 'USD';
  static const String defaultCountry = 'US';
}
