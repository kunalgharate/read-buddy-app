// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/auth/data/remotesource/auth_remote_data_source.dart'
    as _i170;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/change_password_usecase.dart'
    as _i788;
import '../../features/auth/domain/usecases/register_user_usecase.dart'
    as _i241;
import '../../features/auth/domain/usecases/send_otp_usecase.dart' as _i663;
import '../../features/auth/domain/usecases/sign_in.dart' as _i920;
import '../../features/auth/domain/usecases/sign_in_with_google.dart' as _i692;
import '../../features/auth/domain/usecases/verify_email_usecase.dart' as _i30;
import '../../features/auth/domain/usecases/verify_reset_otp_usecase.dart'
    as _i752;
import '../../features/auth/presentation/blocs/google_sign_in/google_sign_in_bloc.dart'
    as _i170;
import '../../features/auth/presentation/blocs/sign_in/sign_in_bloc.dart'
    as _i78;
import '../../features/auth/presentation/blocs/sign_up/sign_up_bloc.dart'
    as _i725;
import '../../features/bookcrud/data/dataresources/bookCrud_remote_resources.dart'
    as _i673;
import '../../features/bookcrud/data/repositories/bookcrud_repo_impl.dart'
    as _i473;
import '../../features/bookcrud/domain/respository/bookcrud_repo.dart' as _i344;
import '../../features/bookcrud/domain/usecases/add_book.dart' as _i900;
import '../../features/bookcrud/domain/usecases/delete_book.dart' as _i836;
import '../../features/bookcrud/domain/usecases/get_books.dart' as _i701;
import '../../features/bookcrud/domain/usecases/get_books_by_id.dart' as _i328;
import '../../features/bookcrud/domain/usecases/search_book.dart' as _i194;
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
import '../../features/donated_books/data/datasources/donation_remote_data_source.dart'
    as _i66;
import '../../features/donated_books/data/repositories/donated_books_repository_impl.dart'
    as _i141;
import '../../features/donated_books/domain/repositories/donated_books_repository.dart'
    as _i225;
import '../../features/donated_books/domain/usecases/get_donated_books.dart'
    as _i505;
import '../../features/donated_books/presentation/bloc/donated_books_bloc.dart'
    as _i253;
import '../../features/profile/data/datasource/profile_remote_data_source.dart'
    as _i192;
import '../../features/profile/data/repositories/profile_repository_impl.dart'
    as _i334;
import '../../features/profile/domain/repositories/profile_repository.dart'
    as _i894;
import '../../features/profile/domain/usecases/update_profile_usecase.dart'
    as _i478;
import '../../features/profile/domain/usecases/get_profile.dart' as _i901;
import '../../features/profile/domain/usecases/update_user_avatar.dart'
    as _i902;
import '../../features/profile/presentation/blocs/profile_bloc.dart' as _i133;
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
    gh.lazySingleton<_i206.SecureStorageUtil>(() => _i206.SecureStorageUtil());
    gh.factory<_i673.BookCrudRemoteDataSource>(
        () => _i673.BookCrudRemoteDataSourceImpl(dio: gh<_i361.Dio>()));
    gh.factory<_i170.AuthRemoteDataSource>(
        () => _i170.AuthRemoteDataSourceImpl(dio: gh<_i361.Dio>()));
    gh.factory<_i66.DonatedBooksRemoteDataSource>(
        () => _i66.DonatedBooksRemoteDataSourceImpl(dio: gh<_i361.Dio>()));
    gh.factory<_i344.BookCrudRepository>(() =>
        _i473.BookCrudRepositoryImpl(gh<_i673.BookCrudRemoteDataSource>()));
    gh.factory<_i212.CategoryRemoteDataSource>(
        () => _i212.CategoryRemoteDataSourceImpl(dio: gh<_i361.Dio>()));
    gh.factory<_i906.BookRemoteDataSource>(
        () => _i906.BookRemoteDataSourceImpl(dio: gh<_i361.Dio>()));
    gh.factory<_i674.BookRepository>(
        () => _i661.BookRepositoryImpl(gh<_i906.BookRemoteDataSource>()));
    gh.lazySingleton<_i192.ProfileRemoteDataSource>(
        () => _i192.ProfileRemoteDataSourceImpl(
              dio: gh<_i361.Dio>(),
              secureStorage: gh<_i206.SecureStorageUtil>(),
            ));
    gh.factory<_i225.DonatedBooksRepository>(() =>
        _i141.DonatedBooksRepositoryImpl(
            gh<_i66.DonatedBooksRemoteDataSource>()));
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
    gh.factory<_i194.SearchBookUsecase>(
        () => _i194.SearchBookUsecase(gh<_i344.BookCrudRepository>()));
    gh.factory<_i161.UpdateBookUsecase>(
        () => _i161.UpdateBookUsecase(gh<_i344.BookCrudRepository>()));
    gh.factory<_i505.GetDonatedBooks>(
        () => _i505.GetDonatedBooks(gh<_i225.DonatedBooksRepository>()));
    gh.factory<_i581.GetBooks>(
        () => _i581.GetBooks(gh<_i674.BookRepository>()));
    gh.factory<_i903.BookBloc>(() => _i903.BookBloc(gh<_i581.GetBooks>()));
    gh.factory<_i665.DeleteCategoryUsecase>(
        () => _i665.DeleteCategoryUsecase(gh<_i187.CategoryRepository>()));
    gh.factory<_i359.GetCategoriesUsecase>(
        () => _i359.GetCategoriesUsecase(gh<_i187.CategoryRepository>()));
    gh.factory<_i527.UpdateCategoryUsecase>(
        () => _i527.UpdateCategoryUsecase(gh<_i187.CategoryRepository>()));
    gh.factory<_i241.RegisterUserUseCase>(
        () => _i241.RegisterUserUseCase(gh<_i787.AuthRepository>()));
    gh.factory<_i920.SignIn>(() => _i920.SignIn(gh<_i787.AuthRepository>()));
    gh.factory<_i692.SignInWithGoogle>(
        () => _i692.SignInWithGoogle(gh<_i787.AuthRepository>()));
    gh.factory<_i30.VerifyEmailUseCase>(
        () => _i30.VerifyEmailUseCase(gh<_i787.AuthRepository>()));
    gh.factory<_i78.SignInBloc>(() => _i78.SignInBloc(
          gh<_i920.SignIn>(),
          gh<_i663.SendOtpUseCase>(),
          gh<_i752.VerifyResetOtpUseCase>(),
          gh<_i788.ChangePasswordUseCase>(),
        ));
    gh.lazySingleton<_i894.ProfileRepository>(
        () => _i334.ProfileRepositoryImpl(gh<_i192.ProfileRemoteDataSource>()));
    gh.factory<_i170.GoogleSignInBloc>(
        () => _i170.GoogleSignInBloc(gh<_i692.SignInWithGoogle>()));
    gh.factory<_i747.BookCrudBloc>(() => _i747.BookCrudBloc(
          searchBooks: gh<_i194.SearchBookUsecase>(),
          getBooksCrud: gh<_i701.GetBooksUsecase>(),
          getBookByIdCrud: gh<_i328.GetBookByIdUsecase>(),
          addBookCrud: gh<_i900.AddBookUsecase>(),
          updateBookCrud: gh<_i161.UpdateBookUsecase>(),
          deleteBookCrud: gh<_i836.DeleteBookusecase>(),
        ));
    gh.factory<_i478.UpdateProfileUseCase>(
        () => _i478.UpdateProfileUseCase(gh<_i894.ProfileRepository>()));
    gh.factory<_i133.ProfileBloc>(() => _i133.ProfileBloc(
          gh<_i206.SecureStorageUtil>(),
          gh<_i901.GetProfileUseCase>(),
          gh<_i902.UpdateAvatarUseCase>(),
          gh<_i478.UpdateProfileUseCase>(),
        ));
    gh.factory<_i788.ChangePasswordUseCase>(
        () => _i788.ChangePasswordUseCase(gh<_i787.AuthRepository>()));
    gh.factory<_i663.SendOtpUseCase>(
        () => _i663.SendOtpUseCase(gh<_i787.AuthRepository>()));
    gh.factory<_i752.VerifyResetOtpUseCase>(
        () => _i752.VerifyResetOtpUseCase(gh<_i787.AuthRepository>()));
    gh.factory<_i725.SignUpBloc>(() => _i725.SignUpBloc(
          gh<_i241.RegisterUserUseCase>(),
          gh<_i30.VerifyEmailUseCase>(),
        ));
    gh.factory<_i78.SignInBloc>(() => _i78.SignInBloc(
          gh<_i920.SignIn>(),
          gh<_i663.SendOtpUseCase>(),
          gh<_i752.VerifyResetOtpUseCase>(),
          gh<_i788.ChangePasswordUseCase>(),
        ));
    return this;
  }
}
