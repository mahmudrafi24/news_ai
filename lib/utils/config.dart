// ignore_for_file: constant_identifier_names

class AppConfig {
  // Set to false to use real API
  static const bool IS_MOCK_MODE = true;

  // Update with your API base URL
  static const String BASE_URL = 'https://your-api.com';

  // API Endpoints
  static const String LOGIN_ENDPOINT = '/auth/login';
  static const String SIGNUP_ENDPOINT = '/auth/signup';
  static const String FORGOT_PASSWORD_ENDPOINT = '/auth/forgot-password';
  static const String VERIFY_EMAIL_ENDPOINT = '/auth/verify-email';
  static const String CHAT_ENDPOINT = '/chat';
  static const String PROFILE_ENDPOINT = '/profile';

  // Add your API keys
  static const String NEWS_API_KEY = 'your_newsapi_key';
  static const String OPENAI_API_KEY = 'your_openai_key';

  // Mock data for testing
  static const String MOCK_EMAIL = 'test@example.com';
  static const String MOCK_PASSWORD = 'password123';
  static const String MOCK_OTP = '123456';
  static const int MOCK_DELAY = 1500;

  static const int SHORT_ANIMATION = 200; // milliseconds
  static const int MEDIUM_ANIMATION = 300;
  static const int LONG_ANIMATION = 400;
}

class ThemeColors {
  // Light theme colors
  static const int primaryLight = 0xFF2196F3;
  static const int backgroundLight = 0xFFFAFAFA;
  static const int surfaceLight = 0xFFFFFFFF;

  // Dark theme colors
  static const int primaryDark = 0xFF1976D2;
  static const int backgroundDark = 0xFF121212;
  static const int surfaceDark = 0xFF1E1E1E;
}
