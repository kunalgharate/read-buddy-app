class ApiConstants {
  static const String baseUrl = 'https://readbuddy-server.onrender.com/api';

  // Auth endpoints
  static const String login = '$baseUrl/users/login';
  static const String register = '$baseUrl/users/register';
  static const String verifyEmail = '$baseUrl/users/verify-email';
  static const String refreshToken = '$baseUrl/auth/refresh';
  static const String loginWithGoogle = '$baseUrl/googleauth/google-auth';
  static const String resendResetOtp = '$baseUrl/users/resend-reset-otp';
  static const String changePassword = '$baseUrl/users/reset-password';
  static const String verifyOtp = '$baseUrl/users/verify-reset-otp';
  // User endpoints
  static const String users = '$baseUrl/users';

// Profile endpoints
  static const String getProfile = '$baseUrl/users/profile';
  static const String updateAvatar = '$baseUrl/users/update-avatar';
  // Book endpoints
  static const String books = '$baseUrl/books';
  static const String searchBooks = '$baseUrl/searchbook/search';
  //homebooks
  static const String trendingBooks = '$baseUrl/home/trending-books';
  static const String recommendedBooks = '$baseUrl/home/recommended-books';
  static const String latestBooks = '$baseUrl/home/latest-books';
  //monthly data
  static const String monthlyData = '$baseUrl/home/monthly-stats';
  // Category endpoints
  static const String categories = '$baseUrl/categories';

  // Donation endpoints
  static const String getAllDonations = '$baseUrl/donations';

  // Donation endpoints

  static const String olaMap = '$baseUrl/ola/address?input';

  // HTTP Status Codes
  static const int success = 200;
  static const int created = 201;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int conflict = 409;
  static const int internalServerError = 500;

  static const addCategory = '$baseUrl/categories';
  static const updateCategory = '$baseUrl/categories'; // append /:id
  static const deleteCategory = '$baseUrl/categories'; // append /:id

//Banner Apis
  static const Banner = '$baseUrl/banners';

  static const String updateUserInfo = '$baseUrl/users/update-user-info';
  // Onboarding base
  static const String onboarding = '$baseUrl/onboarding';

  // Onboarding Endpoints
  static const String getAllQuestions = '$baseUrl/onboarding/questions';
  static const String getQuestion =
      '$baseUrl/onboarding/question'; // append /:id

  static const String setUserPreferences = '$baseUrl/onboarding/preference';

  static const String updateUserPreference = '$baseUrl/onboarding/preference';

  static const String resetUserPreference = '$baseUrl/onboarding/preference';

  static const String setOnboardingStatus = '$baseUrl/users/onboarding-status';
}
