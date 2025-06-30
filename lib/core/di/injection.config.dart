// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/auth/data/remotesource/auth_remote_data_source.dart'
    as _i170;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/sign_in.dart' as _i920;
import '../../features/auth/presentation/blocs/sign_in/sign_in_bloc.dart'
    as _i78;
import '../../features/bookcrud/data/dataresources/bookcrud_remote_resources.dart'
    as _i199;
import '../../features/bookcrud/data/repositories/bookcrud_repo_impl.dart'
    as _i473;
import '../../features/bookcrud/domain/respository/bookcrud_repo.dart' as _i344;
import '../../features/bookcrud/domain/usecases/add_book.dart' as _i900;
import '../../features/bookcrud/domain/usecases/delete_book.dart' as _i836;
import '../../features/bookcrud/domain/usecases/get_books.dart' as _i701;
import '../../features/bookcrud/domain/usecases/get_books_by_id.dart' as _i328;
import '../../features/bookcrud/domain/usecases/update_book.dart' as _i161;
import '../../features/bookcrud/presentation/bloc/bloc/book_crud_bloc.dart'
    as _i747;
import '../../features/books/data/datasources/book_remote_data_source.dart'
    as _i906;
import '../../features/books/data/repositories/book_repository_impl.dart'
    as _i661;
import '../../features/books/domain/repositories/book_repository.dart' as _i674;
import '../../features/books/domain/usecases/get_books.dart' as _i581;
import '../../features/books/presentation/bloc/book_bloc.dart' as _i903;
import '../../features/category_crud/data/datasources/category_remote_dataresources.dart'
    as _i212;
import '../../features/category_crud/data/repositories/category_repo_impl.dart'
    as _i574;
import '../../features/category_crud/domain/repository/category_repository.dart'
    as _i187;
import '../../features/category_crud/domain/usecases/dele_category.dart'
    as _i665;
import '../../features/category_crud/domain/usecases/get_caategories.dart'
    as _i359;
import '../../features/category_crud/domain/usecases/update_category.dart'
    as _i527;
import '../network/dio_client.dart' as _i667;
import '../utils/app_interceptor.dart' as _i795;
import '../utils/secure_storage_utils.dart' as _i206;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final dioModule = _$DioModule();
    gh.lazySingleton<_i558.FlutterSecureStorage>(() => dioModule.storage);
    gh.lazySingleton<_i206.SecureStorageUtil>(() => _i206.SecureStorageUtil());
    gh.lazySingleton<_i361.Dio>(
      () => dioModule.provideAuthDio(),
      instanceName: 'auth',
    );
    gh.lazySingleton<_i795.AppInterceptor>(() => dioModule.appInterceptor(
          gh<_i558.FlutterSecureStorage>(),
          gh<_i361.Dio>(instanceName: 'auth'),
        ));
    gh.lazySingleton<_i361.Dio>(
        () => dioModule.dio(gh<_i795.AppInterceptor>()));
    gh.factory<_i199.BookCrudRemoteDataSource>(
        () => _i199.BookCrudRemoteDataSourceImpl(dio: gh<_i361.Dio>()));
    gh.factory<_i344.BookCrudRepository>(() =>
        _i473.BookCrudRepositoryImpl(gh<_i199.BookCrudRemoteDataSource>()));
    gh.factory<_i170.AuthRemoteDataSource>(
        () => _i170.AuthRemoteDataSourceImpl(dio: gh<_i361.Dio>()));
    gh.factory<_i212.CategoryRemoteDataSource>(
        () => _i212.CategoryRemoteDataSourceImpl(dio: gh<_i361.Dio>()));
    gh.factory<_i906.BookRemoteDataSource>(
        () => _i906.BookRemoteDataSourceImpl(dio: gh<_i361.Dio>()));
    gh.factory<_i674.BookRepository>(
        () => _i661.BookRepositoryImpl(gh<_i906.BookRemoteDataSource>()));
    gh.factory<_i187.CategoryRepository>(() =>
        _i574.CategoryRepositoryImpl(gh<_i212.CategoryRemoteDataSource>()));
    gh.factory<_i787.AuthRepository>(
        () => _i153.AuthRepositoryImpl(gh<_i170.AuthRemoteDataSource>()));
    gh.factory<_i900.AddBookUsecase>(
        () => _i900.AddBookUsecase(gh<_i344.BookCrudRepository>()));
    gh.factory<_i836.DeleteBookusecase>(
        () => _i836.DeleteBookusecase(gh<_i344.BookCrudRepository>()));
    gh.factory<_i701.GetBooksUsecase>(
        () => _i701.GetBooksUsecase(gh<_i344.BookCrudRepository>()));
    gh.factory<_i328.GetBookByIdUsecase>(
        () => _i328.GetBookByIdUsecase(gh<_i344.BookCrudRepository>()));
    gh.factory<_i161.UpdateBookUsecase>(
        () => _i161.UpdateBookUsecase(gh<_i344.BookCrudRepository>()));
    gh.factory<_i581.GetBooks>(
        () => _i581.GetBooks(gh<_i674.BookRepository>()));
    gh.factory<_i903.BookBloc>(() => _i903.BookBloc(gh<_i581.GetBooks>()));
    gh.factory<_i665.DeleteCategoryUsecase>(
        () => _i665.DeleteCategoryUsecase(gh<_i187.CategoryRepository>()));
    gh.factory<_i359.GetCategoriesUsecase>(
        () => _i359.GetCategoriesUsecase(gh<_i187.CategoryRepository>()));
    gh.factory<_i527.UpdateCategoryUsecase>(
        () => _i527.UpdateCategoryUsecase(gh<_i187.CategoryRepository>()));
    gh.factory<_i920.SignIn>(() => _i920.SignIn(gh<_i787.AuthRepository>()));
    gh.factory<_i78.SignInBloc>(() => _i78.SignInBloc(gh<_i920.SignIn>()));
    gh.factory<_i747.BookCrudBloc>(() => _i747.BookCrudBloc(
          getBooksCrud: gh<_i701.GetBooksUsecase>(),
          getBookByIdCrud: gh<_i328.GetBookByIdUsecase>(),
          addBookCrud: gh<_i900.AddBookUsecase>(),
          updateBookCrud: gh<_i161.UpdateBookUsecase>(),
          deleteBookCrud: gh<_i836.DeleteBookusecase>(),
        ));
    return this;
  }
}

class _$DioModule extends _i667.DioModule {}
