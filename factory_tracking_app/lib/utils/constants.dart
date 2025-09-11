// API Configuration
class ApiConstants {
  // Base URLs
  static const String baseUrl = 'http://localhost:5000/api';
  static const String baseUrlProduction = 'https://your-production-api.com/api';
  
  // Endpoints
  static const String loginEndpoint = '/Auth/login';
  static const String registerEndpoint = '/Auth/register';
  static const String userProfileEndpoint = '/Users/profile';
  static const String checkPointsEndpoint = '/CheckPoints';
  static const String stopCardsEndpoint = '/StopCards';
  static const String imageUploadEndpoint = '/Image/upload';
  
  // Request Configuration
  static const int timeoutSeconds = 30;
  static const int maxRetries = 3;
  static const int uploadTimeoutSeconds = 60;
  
  // Storage Keys
  static const String tokenKey = 'jwt_token';
  static const String userKey = 'user_info';
  static const String lastLoginKey = 'last_login';
}

// Error Messages
class ErrorMessages {
  static const String networkError = 'No internet connection available';
  static const String timeoutError = 'Request timeout. Please try again.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unauthorizedError = 'Session expired. Please login again.';
  static const String forbiddenError = 'Access denied. Insufficient permissions.';
  static const String notFoundError = 'Resource not found.';
  static const String validationError = 'Invalid input data.';
  static const String unknownError = 'An unexpected error occurred.';
  
  // Authentication
  static const String invalidCredentials = 'Invalid email or password.';
  static const String loginRequired = 'Please login to continue.';
  
  // Image Upload
  static const String imageUploadError = 'Failed to upload image.';
  static const String imageSizeError = 'Image size too large.';
  static const String imageFormatError = 'Unsupported image format.';
  
  // QR Code
  static const String qrScanError = 'Failed to scan QR code.';
  static const String invalidQrCode = 'Invalid QR code format.';
  
  // Stop Cards
  static const String stopCardCreateError = 'Failed to create stop card.';
  static const String stopCardUpdateError = 'Failed to update stop card.';
  
  // CheckPoints
  static const String checkPointScanError = 'Failed to scan checkpoint.';
  static const String checkPointNotFound = 'Checkpoint not found.';
}

// App Constants
class AppConstants {
  static const String appName = 'Factory Tracking';
  static const String appVersion = '1.0.0';
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  static const double defaultBorderRadius = 8.0;
  static const double smallBorderRadius = 4.0;
  static const double largeBorderRadius = 16.0;
  
  // Image Constants
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];
  
  // QR Code Constants
  static const double qrScanAreaSize = 250.0;
  
  // Stop Card Constants
  static const List<String> stopCardPriorities = ['Low', 'Medium', 'High', 'Critical'];
  static const List<String> stopCardStatuses = ['Open', 'InProgress', 'Resolved', 'Closed'];
}

// Validation Constants
class ValidationConstants {
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 1000;
  static const int maxTitleLength = 100;
  
  // Email validation regex
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
}

// Theme Constants
class ThemeConstants {
  // Colors (you can customize these based on your brand)
  static const int primaryColorValue = 0xFF2196F3;
  static const int secondaryColorValue = 0xFF03DAC6;
  static const int errorColorValue = 0xFFB00020;
  static const int warningColorValue = 0xFFFF9800;
  static const int successColorValue = 0xFF4CAF50;
  
  // Text Sizes
  static const double headingTextSize = 24.0;
  static const double titleTextSize = 20.0;
  static const double bodyTextSize = 16.0;
  static const double captionTextSize = 14.0;
  static const double smallTextSize = 12.0;
}