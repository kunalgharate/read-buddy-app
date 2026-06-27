import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../bookcrud/domain/entities/book_variant_entity.dart';
import '../../../bookcrud/domain/respository/variant_repository.dart';
import '../../data/datasources/book_request_remote_datasource.dart';

// ─── State ──────────────────────────────────────────────────────────────────

class BookDetailVariantState extends Equatable {
  final List<BookVariantEntity> variants;
  final bool isLoading;
  final String? selectedLanguage;
  final bool isInWishlist;
  final bool hasActiveRequest;

  const BookDetailVariantState({
    this.variants = const [],
    this.isLoading = true,
    this.selectedLanguage,
    this.isInWishlist = false,
    this.hasActiveRequest = false,
  });

  BookDetailVariantState copyWith({
    List<BookVariantEntity>? variants,
    bool? isLoading,
    String? selectedLanguage,
    bool? isInWishlist,
    bool? hasActiveRequest,
  }) {
    return BookDetailVariantState(
      variants: variants ?? this.variants,
      isLoading: isLoading ?? this.isLoading,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      isInWishlist: isInWishlist ?? this.isInWishlist,
      hasActiveRequest: hasActiveRequest ?? this.hasActiveRequest,
    );
  }

  @override
  List<Object?> get props =>
      [variants, isLoading, selectedLanguage, isInWishlist, hasActiveRequest];
}

// ─── Cubit ──────────────────────────────────────────────────────────────────

class BookDetailVariantCubit extends Cubit<BookDetailVariantState> {
  final VariantRepository _repository;
  final BookRequestRemoteDataSource _requestDataSource;
  final Dio _dio;
  final FlutterSecureStorage _storage;

  BookDetailVariantCubit(
    this._repository,
    this._requestDataSource,
    this._dio,
    this._storage,
  ) : super(const BookDetailVariantState());

  Future<void> loadVariants({
    required String bookId,
    List<BookVariantEntity> inlineVariants = const [],
    List<dynamic> userWishlist = const [],
  }) async {
    final isInWishlist = userWishlist.contains(bookId);

    // Check if user already has an active request for this book
    bool hasActiveRequest = false;
    try {
      final requests = await _requestDataSource.getMyBookRequests();
      hasActiveRequest = requests.any((r) =>
          r.bookId == bookId &&
          (r.status == 'pending' ||
              r.status == 'approved' ||
              r.status == 'scheduled' ||
              r.status == 'in_transit'));
    } catch (_) {}

    if (inlineVariants.isNotEmpty) {
      emit(BookDetailVariantState(
        variants: inlineVariants,
        isLoading: false,
        selectedLanguage: inlineVariants.first.language,
        isInWishlist: isInWishlist,
        hasActiveRequest: hasActiveRequest,
      ));
      return;
    }

    try {
      final variants = await _repository.getVariantsForBook(bookId);
      emit(BookDetailVariantState(
        variants: variants,
        isLoading: false,
        selectedLanguage: variants.isNotEmpty ? variants.first.language : null,
        isInWishlist: isInWishlist,
        hasActiveRequest: hasActiveRequest,
      ));
    } catch (_) {
      emit(state.copyWith(
        isLoading: false,
        isInWishlist: isInWishlist,
        hasActiveRequest: hasActiveRequest,
      ));
    }
  }

  void selectLanguage(String language) {
    emit(state.copyWith(selectedLanguage: language));
  }

  Future<void> toggleWishlist(String bookId) async {
    final adding = !state.isInWishlist;
    emit(state.copyWith(isInWishlist: adding));

    try {
      final token = await _storage.read(key: 'accessToken');
      if (adding) {
        await _dio.post(
          '${ApiConstants.wishlist}/$bookId',
          options: Options(
              headers: {'Authorization': 'Bearer $token'}),
        );
      } else {
        await _dio.delete(
          '${ApiConstants.wishlist}/$bookId',
          options: Options(
              headers: {'Authorization': 'Bearer $token'}),
        );
      }
    } catch (_) {
      // Revert on failure
      emit(state.copyWith(isInWishlist: !adding));
    }
  }
}
