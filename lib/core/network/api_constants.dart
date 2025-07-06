class ApiConstants {
  static const String baseUrl = 'https://readbuddy-server.onrender.com/api';

  // Auth endpoints
  static const String login = '$baseUrl/users/login';
  static const String register = '$baseUrl/users/register';
  static const String verifyEmail = '$baseUrl/users/verify-email';
  static const String refreshToken = '$baseUrl/auth/refresh';

  // User endpoints
  static const String users = '$baseUrl/users';

  // Book endpoints
  static const String books = '$baseUrl/books';

  // Category endpoints
  static const String categories = '$baseUrl/categories';

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
  static const createBanner = '$baseUrl/banners/';
}
