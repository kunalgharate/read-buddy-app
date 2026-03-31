import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:read_buddy_app/features/banner/domain/usecase/delete_banner.dart';
import 'package:read_buddy_app/features/banner/domain/usecase/get_banner.dart';
import 'package:read_buddy_app/features/banner/domain/usecase/update_banner.dart';
import 'package:read_buddy_app/features/bookcrud/data/repositories/search_location_repo_impl.dart';
import 'package:read_buddy_app/features/bookcrud/domain/respository/search_location_repo.dart';
import 'package:read_buddy_app/features/bookcrud/domain/usecases/search_book.dart';
import 'package:read_buddy_app/features/bookcrud/domain/usecases/search_location.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/cubit/cubit/location_cubit.dart';

// Core
import '../network/dio_client.dart';
import '../utils/secure_storage_utils.dart';

// Auth
import '../../features/auth/data/remotesource/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/register_user_usecase.dart';
import '../../features/auth/domain/usecases/sign_in.dart';
import '../../features/auth/domain/usecases/sign_in_with_google.dart';
import '../../features/auth/domain/usecases/verify_email_usecase.dart';
import '../../features/auth/domain/usecases/send_otp_usecase.dart';
import '../../features/auth/domain/usecases/verify_reset_otp_usecase.dart';
import '../../features/auth/domain/usecases/change_password_usecase.dart';
import '../../features/auth/presentation/blocs/google_sign_in/google_sign_in_bloc.dart';
import '../../features/auth/presentation/blocs/sign_in/sign_in_bloc.dart';
import '../../features/auth/presentation/blocs/sign_up/sign_up_bloc.dart';

// Books
import '../../features/books/data/datasources/book_remote_data_source.dart';
import '../../features/books/data/repositories/book_repository_impl.dart';
import '../../features/books/domain/repositories/book_repository.dart';
import '../../features/books/domain/usecases/get_books.dart';
import '../../features/books/presentation/bloc/book_bloc.dart';

// Book CRUD
import '../../features/bookcrud/data/dataresources/bookCrud_remote_resources.dart';
import '../../features/bookcrud/data/dataresources/user_remote_resources.dart';
import 'package:read_buddy_app/features/bookcrud/data/dataresources/search_location_remote_resources.dart';
import '../../features/bookcrud/data/repositories/bookcrud_repo_impl.dart';
import '../../features/bookcrud/data/repositories/user_repo_impl.dart';
import '../../features/bookcrud/domain/respository/bookcrud_repo.dart';
import '../../features/bookcrud/domain/respository/user_repo.dart';
import '../../features/bookcrud/domain/usecases/add_book.dart';
import '../../features/bookcrud/domain/usecases/delete_book.dart';
import '../../features/bookcrud/domain/usecases/get_books.dart';
import '../../features/bookcrud/domain/usecases/get_books_by_id.dart';
import '../../features/bookcrud/domain/usecases/update_book.dart';
import '../../features/bookcrud/domain/usecases/user_listcase.dart';
import '../../features/bookcrud/presentation/bloc/bloc/book_crud_bloc.dart';
import '../../features/bookcrud/presentation/cubit/cubit/user_cubit.dart';

// Category CRUD
import '../../features/category_crud/data/datasources/category_remote_dataresources.dart';
import '../../features/category_crud/data/repositories/category_repo_impl.dart';
import '../../features/category_crud/domain/repository/category_repository.dart';
import '../../features/category_crud/domain/usecases/add_categories.dart';
import '../../features/category_crud/domain/usecases/dele_category.dart';
import '../../features/category_crud/domain/usecases/get_caategories.dart';
import '../../features/category_crud/domain/usecases/update_category.dart';
import '../../features/category_crud/presentation/bloc/bloc/category_bloc.dart';

// Banner
import '../../features/banner/datasources/data/createbanner_remote_datasource.dart';
import '../../features/banner/datasources/repositories/banner_repo_impl.dart';
import '../../features/banner/domain/repository/banner_repository.dart';
import '../../features/banner/domain/usecase/create_banner.dart';
import '../../features/banner/presentation/bloc/banner_bloc.dart';

// Questionaries
import '../../features/questionaries/data/datasources/onboarding_remote_datasource.dart';
import '../../features/questionaries/data/repositories/question_repository_impl.dart';
import '../../features/questionaries/domain/repositories/onboarding_repository.dart';
import '../../features/questionaries/domain/usecases/get_questions.dart';
import '../../features/questionaries/domain/usecases/set_preferences.dart';
import '../../features/questionaries/domain/usecases/update_user_preferences.dart';
import '../../features/questionaries/domain/usecases/delete_user_preferences.dart';
import '../../features/questionaries/domain/usecases/set_onboarding_status.dart';
import '../../features/questionaries/presentations/bloc/on_boarding_bloc.dart';

// Question CRUD (Admin)
import '../../features/question_crud/data/datasources/question_remote_datasource.dart'
    as QuestionCrudDataSource;
import '../../features/question_crud/data/repositories/question_repository_impl.dart'
    as QuestionCrudRepo;
import '../../features/question_crud/domain/repositories/question_repository.dart'
    as QuestionCrudDomain;
import '../../features/question_crud/domain/usecases/get_questions.dart'
    as QuestionCrudUseCases;
import '../../features/question_crud/domain/usecases/add_question.dart'
    as QuestionCrudUseCases;
import '../../features/question_crud/domain/usecases/update_question.dart'
    as QuestionCrudUseCases;
import '../../features/question_crud/domain/usecases/delete_question.dart'
    as QuestionCrudUseCases;

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
void configureDependencies() {
  _registerUtils();
  _registerDataSources();
  _registerRepositories();
  _registerUseCases();
  _registerBlocs();
  _registerCubits();
}

// ========================================
// UTILS & CORE
// ========================================
void _registerUtils() {
  getIt.registerLazySingleton<SecureStorageUtil>(() => SecureStorageUtil());
  getIt.registerLazySingleton<Dio>(() => DioClient.createDio());
}

// ========================================
// DATA SOURCES
// ========================================
void _registerDataSources() {
  // Auth
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  // Books
  getIt.registerLazySingleton<BookRemoteDataSource>(
    () => BookRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  // Book CRUD
  getIt.registerLazySingleton<BookCrudRemoteDataSource>(
    () => BookCrudRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  // User
  getIt.registerLazySingleton<UserRemoteResources>(
    () => UserRemoteResourcesImpl(dio: getIt<Dio>()),
  );

  // Search Location
  getIt.registerLazySingleton<SearchLocationRemoteResources>(
    () => SearchLocationRemoteResourcesImpl(dio: getIt<Dio>()),
  );

  // Category CRUD
  getIt.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  // Banner
  getIt.registerLazySingleton<BannerRemoteDataSource>(
    () => BannerRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  // Questionaries
  getIt.registerLazySingleton<OnboardingRemoteDataSource>(
    () => OnboardingRemoteDataSourceImpl(
      dio: getIt<Dio>(),
      secureStorage: getIt<SecureStorageUtil>(),
    ),
  );

  // Question CRUD (Admin)
  getIt.registerLazySingleton<QuestionCrudDataSource.QuestionRemoteDataSource>(
    () => QuestionCrudDataSource.QuestionRemoteDataSource(
      getIt<Dio>(),
      getIt<SecureStorageUtil>(),
    ),
  );
}

// ========================================
// REPOSITORIES
// ========================================
void _registerRepositories() {
  // Auth
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
  );

  // Books
  getIt.registerLazySingleton<BookRepository>(
    () => BookRepositoryImpl(getIt<BookRemoteDataSource>()),
  );

  // Book CRUD
  getIt.registerLazySingleton<BookCrudRepository>(
    () => BookCrudRepositoryImpl(getIt<BookCrudRemoteDataSource>()),
  );

  // User
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(getIt<UserRemoteResources>()),
  );

  // Search Location
  getIt.registerLazySingleton<SearchLocationRepository>(
    () => SearchLocationRepoImpl(getIt<SearchLocationRemoteResources>()),
  );

  // Category CRUD
  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(getIt<CategoryRemoteDataSource>()),
  );

  // Banner
  getIt.registerLazySingleton<BannerRepository>(
    () => BannerRepoImpl(remoteDataSource: getIt<BannerRemoteDataSource>()),
  );

  // Questionaries
  getIt.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(getIt<OnboardingRemoteDataSource>()),
  );

  // Question CRUD (Admin)
  getIt.registerLazySingleton<QuestionCrudDomain.QuestionRepository>(
    () => QuestionCrudRepo.QuestionRepositoryImpl(
      getIt<QuestionCrudDataSource.QuestionRemoteDataSource>(),
    ),
  );
}

// ========================================
// USE CASES
// ========================================
void _registerUseCases() {
  // Auth
  getIt.registerLazySingleton(() => SignIn(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => SignInWithGoogle(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => RegisterUserUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => VerifyEmailUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => SendOtpUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => VerifyResetOtpUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => ChangePasswordUseCase(getIt<AuthRepository>()));

  // Books
  getIt.registerLazySingleton(() => GetBooks(getIt<BookRepository>()));

  // Book CRUD
  getIt.registerLazySingleton(() => SearchBookUsecase(getIt<BookCrudRepository>()));
  getIt.registerLazySingleton(() => AddBookUsecase(getIt<BookCrudRepository>()));
  getIt.registerLazySingleton(() => GetBooksUsecase(getIt<BookCrudRepository>()));
  getIt.registerLazySingleton(() => GetBookByIdUsecase(getIt<BookCrudRepository>()));
  getIt.registerLazySingleton(() => UpdateBookUsecase(getIt<BookCrudRepository>()));
  getIt.registerLazySingleton(() => DeleteBookusecase(getIt<BookCrudRepository>()));

  // User
  getIt.registerLazySingleton(() => GetUserListUseCase(getIt<UserRepository>()));

  // Search Location
  getIt.registerLazySingleton(
    () => SearchLocationUsecase(getIt<SearchLocationRepository>()),
  );

  // Category CRUD
  getIt.registerLazySingleton(() => AddCategoryUsecase(getIt<CategoryRepository>()));
  getIt.registerLazySingleton(() => DeleteCategoryUsecase(getIt<CategoryRepository>()));
  getIt.registerLazySingleton(() => GetCategoriesUsecase(getIt<CategoryRepository>()));
  getIt.registerLazySingleton(() => UpdateCategoryUsecase(getIt<CategoryRepository>()));

  // Banner
  getIt.registerLazySingleton(() => GetBannerUsecase(getIt<BannerRepository>()));
  getIt.registerLazySingleton(() => CreateBannerUsecase(getIt<BannerRepository>()));
  getIt.registerLazySingleton(() => UpdateBannerUsecase(getIt<BannerRepository>()));
  getIt.registerLazySingleton(() => DeleteBannerUsecase(getIt<BannerRepository>()));

  // Questionaries
  getIt.registerLazySingleton(() => GetQuestionsUseCase(getIt<OnboardingRepository>()));
  getIt.registerLazySingleton(() => SetPreferencesUseCase(getIt<OnboardingRepository>()));
  getIt.registerLazySingleton(() => UpdatePreferencesUseCase(getIt<OnboardingRepository>()));
  getIt.registerLazySingleton(() => DeletePreferencesUseCase(getIt<OnboardingRepository>()));
  getIt.registerLazySingleton(() => SetOnboardingStatusUseCase(getIt<OnboardingRepository>()));

  // Question CRUD (Admin)
  getIt.registerLazySingleton(() => QuestionCrudUseCases.GetQuestions(
      getIt<QuestionCrudDomain.QuestionRepository>()));
  getIt.registerLazySingleton(() => QuestionCrudUseCases.AddQuestion(
      getIt<QuestionCrudDomain.QuestionRepository>()));
  getIt.registerLazySingleton(() => QuestionCrudUseCases.UpdateQuestion(
      getIt<QuestionCrudDomain.QuestionRepository>()));
  getIt.registerLazySingleton(() => QuestionCrudUseCases.DeleteQuestion(
      getIt<QuestionCrudDomain.QuestionRepository>()));
}

// ========================================
// BLOCS
// ========================================
void _registerBlocs() {
  // Auth
  getIt.registerLazySingleton(() => SignInBloc(
        getIt<SignIn>(),
        getIt<SendOtpUseCase>(),
        getIt<VerifyResetOtpUseCase>(),
        getIt<ChangePasswordUseCase>(),
      ));
  getIt.registerLazySingleton(() => GoogleSignInBloc(getIt<SignInWithGoogle>()));
  getIt.registerLazySingleton(() => SignUpBloc(
        getIt<RegisterUserUseCase>(),
        getIt<VerifyEmailUseCase>(),
      ));

  // Books
  getIt.registerLazySingleton(() => BookBloc(getIt<GetBooks>()));

  // Book CRUD
  getIt.registerLazySingleton(() => BookCrudBloc(
        searchBooks: getIt<SearchBookUsecase>(),
        addBookCrud: getIt<AddBookUsecase>(),
        getBooksCrud: getIt<GetBooksUsecase>(),
        getBookByIdCrud: getIt<GetBookByIdUsecase>(),
        updateBookCrud: getIt<UpdateBookUsecase>(),
        deleteBookCrud: getIt<DeleteBookusecase>(),
      ));

  // Category CRUD
  getIt.registerLazySingleton(() => CategoryBloc(
        getCategories: getIt<GetCategoriesUsecase>(),
        addCategory: getIt<AddCategoryUsecase>(),
        updateCategory: getIt<UpdateCategoryUsecase>(),
        deleteCategory: getIt<DeleteCategoryUsecase>(),
      ));

  // Banner
  getIt.registerLazySingleton(() => BannerBloc(
        getBannerUsecase: getIt<GetBannerUsecase>(),
        createBannerUsecase: getIt<CreateBannerUsecase>(),
        updateBannerUsecase: getIt<UpdateBannerUsecase>(),
        deleteBannerUsecase: getIt<DeleteBannerUsecase>(),
      ));

  // Questionaries
  getIt.registerFactory(() => OnboardingBloc(
        getQuestionsUseCase: getIt<GetQuestionsUseCase>(),
        setPreferencesUseCase: getIt<SetPreferencesUseCase>(),
        updatePreferencesUseCase: getIt<UpdatePreferencesUseCase>(),
        deletePreferencesUseCase: getIt<DeletePreferencesUseCase>(),
        setOnboardingStatusUseCase: getIt<SetOnboardingStatusUseCase>(),
      ));
}

// ========================================
// CUBITS
// ========================================
void _registerCubits() {
  getIt.registerLazySingleton(() => UserCubit(getIt<GetUserListUseCase>()));
  getIt.registerLazySingleton(() => LocationCubit(getIt<SearchLocationUsecase>()));
}
