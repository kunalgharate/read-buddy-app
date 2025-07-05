class Api {
  static const String baseUrl = 'https://readbuddy-server.onrender.com/api';
  static const String userslist = '$baseUrl/users';
  static const String books = '$baseUrl/books';

  static const categories = '$baseUrl/categories';
  static const addCategory = '$baseUrl/categories';
  static const updateCategory = '$baseUrl/categories'; // append /:id
  static const deleteCategory = '$baseUrl/categories'; // append /:id

//Banner Apis
  static const createBanner = '$baseUrl/banners/';
}
