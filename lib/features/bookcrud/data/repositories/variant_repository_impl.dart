import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/parent_book_entity.dart';
import '../../domain/entities/book_variant_entity.dart';
import '../../domain/respository/variant_repository.dart';
import '../model/parent_book_model.dart';
import '../model/book_variant_model.dart';

@LazySingleton(as: VariantRepository)
class VariantRepositoryImpl implements VariantRepository {
  static const String _parentBooksKey = 'parent_books_v1';
  static const String _variantsKey = 'book_variants_v1';

  VariantRepositoryImpl();

  @override
  Future<List<ParentBookEntity>> getParentBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_parentBooksKey) ?? [];
    return data.map((jsonStr) {
      final jsonMap = json.decode(jsonStr) as Map<String, dynamic>;
      return ParentBookModel.fromJson(jsonMap);
    }).toList();
  }

  @override
  Future<void> saveParentBook(ParentBookEntity book) async {
    final prefs = await SharedPreferences.getInstance();
    final currentList = await getParentBooks();
    
    final model = ParentBookModel.fromEntity(book);
    final index = currentList.indexWhere((item) => item.id == book.id);
    
    final updatedList = List<ParentBookEntity>.from(currentList);
    if (index != -1) {
      updatedList[index] = model;
    } else {
      updatedList.add(model);
    }

    final jsonList = updatedList.map((item) {
      return json.encode(ParentBookModel.fromEntity(item).toJson());
    }).toList();
    await prefs.setStringList(_parentBooksKey, jsonList);
  }

  @override
  Future<List<BookVariantEntity>> getVariantsForBook(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_variantsKey) ?? [];
    final allVariants = data.map((jsonStr) {
      final jsonMap = json.decode(jsonStr) as Map<String, dynamic>;
      return BookVariantModel.fromJson(jsonMap);
    }).toList();

    return allVariants.where((variant) => variant.bookId == bookId).toList();
  }

  @override
  Future<void> saveVariant(BookVariantEntity variant) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_variantsKey) ?? [];
    
    final allVariants = data.map((jsonStr) {
      final jsonMap = json.decode(jsonStr) as Map<String, dynamic>;
      return BookVariantModel.fromJson(jsonMap);
    }).toList();

    final model = BookVariantModel.fromEntity(variant);
    final index = allVariants.indexWhere((item) => item.id == variant.id);

    if (index != -1) {
      allVariants[index] = model;
    } else {
      final exists = allVariants.any((item) =>
          item.bookId == variant.bookId &&
          item.language.toLowerCase() == variant.language.toLowerCase());
      if (exists) {
        throw Exception('Variant for ${variant.language} already exists.');
      }
      allVariants.add(model);
    }

    final jsonList = allVariants.map((item) {
      return json.encode(BookVariantModel.fromEntity(item).toJson());
    }).toList();
    await prefs.setStringList(_variantsKey, jsonList);
  }

  @override
  Future<void> deleteVariant(String variantId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_variantsKey) ?? [];
    
    final allVariants = data.map((jsonStr) {
      final jsonMap = json.decode(jsonStr) as Map<String, dynamic>;
      return BookVariantModel.fromJson(jsonMap);
    }).toList();

    allVariants.removeWhere((item) => item.id == variantId);

    final jsonList = allVariants.map((item) {
      return json.encode(BookVariantModel.fromEntity(item).toJson());
    }).toList();
    await prefs.setStringList(_variantsKey, jsonList);
  }
}
