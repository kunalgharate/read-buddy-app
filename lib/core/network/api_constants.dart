import 'package:read_buddy_app/core/config/app_config.dart';

class ApiConstants {
  static String get baseUrl => AppConfig.instance.baseUrl;

  // Auth endpoints
  static String get login => '$baseUrl/users/login';
  static String get register => '$baseUrl/users/register';
  static String get verifyEmail => '$baseUrl/users/verify-email';
  static String get refreshToken => '$baseUrl/users/refresh-token';
  static String get loginWithGoogle => '$baseUrl/users/google-auth';
  static String get resendResetOtp => '$baseUrl/users/resend-reset-otp';
  static String get changePassword => '$baseUrl/users/reset-password';
  static String get verifyOtp => '$baseUrl/users/verify-reset-otp';
  static String get logout => '$baseUrl/users/logout';
  static String get resendRegisterOtp => '$baseUrl/users/resend-register-otp';
  static String get changePasswordAuth => '$baseUrl/users/change-password';
  static String get uploadProfileImage => '$baseUrl/users/upload-profile-image';

  // User endpoints
  static String get users => '$baseUrl/users';
  static String get searchUsers => '$baseUrl/searchuser/search';

  // Profile endpoints
  static String get getProfile => '$baseUrl/users/profile';
  static String get updateAvatar => '$baseUrl/users/update-avatar';

  // Book endpoints
  static String get books => '$baseUrl/books';
  static String get searchBooks => '$baseUrl/searchbook/search';
  static String get bookVariants => '$baseUrl/book-variants';

  // Home books
  static String get trendingBooks => '$baseUrl/home/trending-books';
  static String get recommendedBooks => '$baseUrl/home/recommended-books';
  static String get latestBooks => '$baseUrl/home/latest-books';

  // Monthly data
  static String get monthlyData => '$baseUrl/home/monthly-stats';

  // Reading progress (continue reading / resume)
  static String get readingProgress => '$baseUrl/reading-progress';
  static String get recentReadingProgress => '$baseUrl/reading-progress/recent';
  static String readingProgressByBook(String bookId) =>
      '$baseUrl/reading-progress/$bookId';

  // Category endpoints
  static String get categories => '$baseUrl/categories';

  // Donation endpoints
  static String get getAllDonations => '$baseUrl/donations';
  static String get adminDonations => '$baseUrl/admin/donations';
  static String get adminDonationSummary => '$baseUrl/admin/donations/summary';
  static String get adminMoneyDonations => '$baseUrl/admin/donations/money';
  static String donationById(String id) => '$baseUrl/donations/$id';
  static String updateDonationStatus(String id) => '$baseUrl/donations/$id';
  static String updateAdminDonationStatus(String id) =>
      '$baseUrl/admin/donations/$id/status';
  static String get myImpact => '$baseUrl/v1/donations/my-impact';
  static String get createBookDonation =>
      '$baseUrl/v1/donations/createBookDonation';
  static String uploadDonationReceipt(String donationId) =>
      '$baseUrl/v1/donations/$donationId/uploadReceipt';

  // ─── Book Request endpoints ──────────────────────────────────────────────
  static String get userBookRequests => '$baseUrl/users/book-requests';
  static String get v1BookRequests => '$baseUrl/v1/book-requests';
  static String get getAllBookRequests => '$baseUrl/bookrequests';
  static String get bookRequests => '$baseUrl/bookrequests';

  // Library endpoints
  static String get libraryDetails => '$baseUrl/v1/libraries/details';

  static String get olaMap => '$baseUrl/ola/address?input';

  // Reviews
  static String get reviews => '$baseUrl/review';
  static String reviewById(String id) => '$baseUrl/review/$id';
  static String reviewsByBook(String bookId) => '$baseUrl/review/book/$bookId';

  // HTTP Status Codes
  static const int success = 200;
  static const int created = 201;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int conflict = 409;
  static const int internalServerError = 500;

  static String get addCategory => '$baseUrl/categories';
  static String get updateCategory => '$baseUrl/categories';
  static String get deleteCategory => '$baseUrl/categories';

  // Banner APIs
  static String get banner => '$baseUrl/banners';

  static String get updateUserInfo => '$baseUrl/users/update-user-info';

  // Onboarding
  static String get onboarding => '$baseUrl/onboarding';
  static String get getAllQuestions => '$baseUrl/onboarding/questions';
  static String get getQuestion => '$baseUrl/onboarding/question';
  static String get setUserPreferences => '$baseUrl/onboarding/preference';
  static String get updateUserPreference => '$baseUrl/onboarding/preference';
  static String get resetUserPreference => '$baseUrl/onboarding/preference';
  static String get setOnboardingStatus => '$baseUrl/users/onboarding-status';

  // TTS (Text-to-Speech) endpoints
  static String get ttsSynthesize => '$baseUrl/tts/synthesize';
  static String get ttsVoices => '$baseUrl/tts/voices';

  // Money Donation (Razorpay)
  static String get donateMoneyInitiate => '$baseUrl/donations/money/initiate';
  static String get donateMoneyVerify => '$baseUrl/donations/money/verify';
  static String get myMoneyDonations => '$baseUrl/donations/money/my';

  // Address CRUD
  static String get addresses => '$baseUrl/addresses';

  // Wishlist
  static String get wishlist => '$baseUrl/wishlist';

  // FCM Token
  static String get fcmToken => '$baseUrl/users/fcm-token';

  // Libraries (multi-library)
  static String get libraries => '$baseUrl/v1/libraries';
  static String get superLibraries => '$baseUrl/v1/libraries/super';

  // Library Inventory
  static String get libraryInventory => '$baseUrl/v1/library-inventory';
  static String get libraryInventoryBrowse => '$baseUrl/v1/library-inventory/browse';
  static String libraryInventoryById(String id) => '$baseUrl/v1/library-inventory/$id';

  // Admin User Management
  static String get adminUsers => '$baseUrl/admin/users';
  static String get adminLibrarians => '$baseUrl/admin/librarians';
  static String get adminLibrariesPath => '$baseUrl/admin/libraries';

  // Librarian endpoints
  static String get librarianBase => '$baseUrl/librarian';
  static String get librarianMyLibrary => '$librarianBase/my-library';
  static String get librarianDashboard => '$librarianBase/dashboard';
  static String get librarianBookRequests => '$librarianBase/book-requests';
  static String get librarianDonations => '$librarianBase/donations';
  static String librarianRequestAccept(String id) =>
      '$librarianBookRequests/$id/accept';
  static String librarianRequestReject(String id) =>
      '$librarianBookRequests/$id/reject';
  static String librarianRequestStatus(String id) =>
      '$librarianBookRequests/$id/status';
  static String librarianDonationStatus(String id) =>
      '$librarianDonations/$id/status';
  static String librarianDonationSchedulePickup(String id) =>
      '$librarianDonations/$id/schedule-pickup';

  // Admin Dashboard
  static String get adminDashboard => '$baseUrl/admindashboard/dashboard';
  static String get dashboardCounts => '$baseUrl/dashboard/dashboard-counts';

  // Return Requests
  static String get returnRequests => '$baseUrl/users/return-requests';
  static String returnRequestById(String id) =>
      '$baseUrl/users/return-requests/$id';
  static String returnRequestMethod(String id) =>
      '$baseUrl/users/return-requests/$id/method';
  static String returnRequestPayment(String id) =>
      '$baseUrl/users/return-requests/$id/payment';
  static String returnRequestDropConfirm(String id) =>
      '$baseUrl/users/return-requests/$id/drop-confirm';
  static String returnRequestReceive(String id) =>
      '$baseUrl/users/return-requests/$id/receive';
  static String returnRequestInspect(String id) =>
      '$baseUrl/users/return-requests/$id/inspect';

  // Shipments
  static String get shipments => '$baseUrl/shipments';
  static String shipmentById(String id) => '$baseUrl/shipments/$id';
  static String shipmentByRequest(String requestId) =>
      '$baseUrl/shipments/request/$requestId';
}
