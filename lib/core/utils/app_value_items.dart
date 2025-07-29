import 'package:read_buddy_app/features/bookcrud/domain/entities/item_entity.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/search_location_entity.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/user_entity.dart';

class BookValueItems {
  static List<Item> bookCategories = [];

  List<String> bookGenres = [
    'Fiction',
    'Non-Fiction',
    'Fantasy',
    'Science Fiction',
    'Mystery',
    'Thriller',
    'Romance',
    'Horror',
    'Historical Fiction',
    'Adventure',
    'Dystopian',
    'Drama',
    'Crime',
    'Short Stories',
    'Biography',
    'Autobiography',
    'Memoir',
    'Self-Help',
    'Health & Wellness',
    'Philosophy',
    'Psychology',
    'Science',
    'History',
    'True Crime',
    'Poetry',
    'Classics',
    'Humor',
    'Spirituality',
  ];

  List<String> bookFormats = [
    'paperback',
    'hardcover',
    'eBook',
    'audioBook',
  ];

  static List<UserEntity> usersList = [];

  static List<SearchLocationEntity> locationsuggestions = [];
}

class CategoryItems {
  static List<Item> parentCategoryItems = [];
}
