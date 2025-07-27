// lib/core/di/injection.dart

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:read_buddy_app/features/home/domain/repositories/main_repository.dart';
import 'package:read_buddy_app/features/home/domain/usecase/usecases.dart';
import 'package:read_buddy_app/features/home/presentation/bloc/home_main_bloc.dart';

// Core
import '../../features/home/data/datasources/home_remote_data_source.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../network/dio_client.dart';
import '../utils/secure_storage_utils.dart';
import '../services/image_picker_service.dart';
import '../services/image_upload_service.dart';
import '../services/permission_service.dart';


// Auth
import '../../features/auth/data/remotesource/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/register_user_usecase.dart';
import '../../features/auth/domain/usecases/sign_in.dart';
import '../../features/auth/domain/usecases/sign_in_with_google.dart';
import '../../features/auth/domain/usecases/verify_email_usecase.dart';
import '../../features/auth/presentation/blocs/google_sign_in/google_sign_in_bloc.dart';
import '../../features/auth/presentation/blocs/sign_in/sign_in_bloc.dart';
import '../../features/auth/presentation/blocs/sign_up/sign_up_bloc.dart';

// Profile
import '../../features/profile/data/remotesource/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/update_profile_usecase.dart';
import '../../features/profile/presentation/blocs/profile_bloc.dart';

// Books
import '../../features/books/data/datasources/book_remote_data_source.dart';
import '../../features/books/data/repositories/book_repository_impl.dart';
import '../../features/books/domain/repositories/book_repository.dart';
import '../../features/books/domain/usecases/get_books.dart';
import '../../features/books/presentation/bloc/book_bloc.dart';

// Book CRUD
import '../../features/bookcrud/data/dataresources/bookCrud_remote_resources.dart';
import '../../features/bookcrud/data/dataresources/user_remote_resources.dart';
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

// Permissions
import '../../features/permissions/presentation/bloc/permission_bloc.dart';

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
// UTILS & CORE DEPENDENCIES
// ========================================
void _registerUtils() {
  getIt.registerLazySingleton<SecureStorageUtil>(() => SecureStorageUtil());
  getIt.registerLazySingleton<Dio>(() => DioClient.createDio());
}

// ========================================
// DATA SOURCES
// ========================================
void _registerDataSources() {
  // Auth Data Sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  // Profile Data Sources
  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  // Books Data Sources
  getIt.registerLazySingleton<BookRemoteDataSource>(
    () => BookRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  // Book CRUD Data Sources
  getIt.registerLazySingleton<BookCrudRemoteDataSource>(
    () => BookCrudRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  // User Data Sources
  getIt.registerLazySingleton<UserRemoteResources>(
    () => UserRemoteResourcesImpl(dio: getIt<Dio>()),
  );

  // Category CRUD Data Sources
  getIt.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  // Banner Data Sources
  getIt.registerLazySingleton<BannerRemoteDataSource>(
    () => BannerRemoteDataSourceImpl(dio: getIt<Dio>()),
  );
  getIt.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(getIt<Dio>(), getIt<SecureStorageUtil>()),
  );

  // Image Services
  getIt.registerLazySingleton<ImagePickerService>(() => ImagePickerService());
  getIt.registerLazySingleton<ImageUploadService>(
    () => ImageUploadService(dio: getIt<Dio>()),
  );



  // Permission Service
  getIt.registerLazySingleton<PermissionService>(() => PermissionService());
}

// ========================================
// REPOSITORIES
// ========================================
void _registerRepositories() {
  // Auth Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
  );

  // Profile Repositories
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(getIt<ProfileRemoteDataSource>()),
  );

  // Books Repositories
  getIt.registerLazySingleton<BookRepository>(
    () => BookRepositoryImpl(getIt<BookRemoteDataSource>()),
  );

  // Book CRUD Repositories
  getIt.registerLazySingleton<BookCrudRepository>(
    () => BookCrudRepositoryImpl(getIt<BookCrudRemoteDataSource>()),
  );

  // User Repositories
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(getIt<UserRemoteResources>()),
  );

  // Category CRUD Repositories
  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(getIt<CategoryRemoteDataSource>()),
  );

  // Banner Repositories
  getIt.registerLazySingleton<BannerRepository>(
    () => BannerRepoImpl(remoteDataSource: getIt<BannerRemoteDataSource>()),
  );
  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(getIt<HomeRemoteDataSource>()),
  );
}

// ========================================
// USE CASES
// ========================================
void _registerUseCases() {
  // Auth Use Cases
  getIt.registerLazySingleton(() => SignIn(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => SignInWithGoogle(getIt<AuthRepository>()));
  getIt.registerLazySingleton(
      () => RegisterUserUseCase(getIt<AuthRepository>()));
  getIt
      .registerLazySingleton(() => VerifyEmailUseCase(getIt<AuthRepository>()));

  // Profile Use Cases
  getIt.registerLazySingleton(
      () => UpdateProfileUseCase(getIt<ProfileRepository>()));

  // Books Use Cases
  getIt.registerLazySingleton(() => GetBooks(getIt<BookRepository>()));

  // Book CRUD Use Cases
  getIt
      .registerLazySingleton(() => AddBookUsecase(getIt<BookCrudRepository>()));
  getIt.registerLazySingleton(
      () => GetBooksUsecase(getIt<BookCrudRepository>()));
  getIt.registerLazySingleton(
      () => GetBookByIdUsecase(getIt<BookCrudRepository>()));
  getIt.registerLazySingleton(
      () => UpdateBookUsecase(getIt<BookCrudRepository>()));
  getIt.registerLazySingleton(
      () => DeleteBookusecase(getIt<BookCrudRepository>()));

  // User Use Cases
  getIt
      .registerLazySingleton(() => GetUserListUseCase(getIt<UserRepository>()));

  // Category CRUD Use Cases
  getIt.registerLazySingleton(
      () => AddCategoryUsecase(getIt<CategoryRepository>()));
  getIt.registerLazySingleton(
      () => DeleteCategoryUsecase(getIt<CategoryRepository>()));
  getIt.registerLazySingleton(
      () => GetCategoriesUsecase(getIt<CategoryRepository>()));
  getIt.registerLazySingleton(
      () => UpdateCategoryUsecase(getIt<CategoryRepository>()));

  // Banner Use Cases
  getIt.registerLazySingleton(
      () => CreateBannerUsecase(getIt<BannerRepository>()));
  getIt.registerLazySingleton(
      () => GetLatestBooksUseCase(getIt<HomeRepository>()));
  getIt.registerLazySingleton(
      () => GetRecommendedBooksUseCase(getIt<HomeRepository>()));
  getIt.registerLazySingleton(() => GetStatsUseCase(getIt<HomeRepository>()));
  getIt.registerLazySingleton(() => GetBannersUseCase(getIt<HomeRepository>()));
}

// ========================================
// BLOCS
// ========================================
void _registerBlocs() {
  // Auth Blocs
  getIt.registerLazySingleton(() => SignInBloc(getIt<SignIn>()));
  getIt
      .registerLazySingleton(() => GoogleSignInBloc(getIt<SignInWithGoogle>()));
  getIt.registerLazySingleton(() => SignUpBloc(
        getIt<RegisterUserUseCase>(),
        getIt<VerifyEmailUseCase>(),
      ));

  // Profile Blocs
  getIt.registerLazySingleton(() => ProfileBloc(
        getIt<SecureStorageUtil>(),
        getIt<UpdateProfileUseCase>(),
        getIt<ImagePickerService>(),
        getIt<ImageUploadService>(),
      ));

  // Books Blocs
  getIt.registerLazySingleton(() => BookBloc(getIt<GetBooks>()));

  // Book CRUD Blocs
  getIt.registerLazySingleton(() => BookCrudBloc(
        addBookCrud: getIt<AddBookUsecase>(),
        getBooksCrud: getIt<GetBooksUsecase>(),
        getBookByIdCrud: getIt<GetBookByIdUsecase>(),
        updateBookCrud: getIt<UpdateBookUsecase>(),
        deleteBookCrud: getIt<DeleteBookusecase>(),
      ));

  // Category CRUD Blocs
  getIt.registerLazySingleton(() => CategoryBloc(
        getCategories: getIt<GetCategoriesUsecase>(),
        addCategory: getIt<AddCategoryUsecase>(),
        updateCategory: getIt<UpdateCategoryUsecase>(),
        deleteCategory: getIt<DeleteCategoryUsecase>(),
      ));

  // Banner Blocs
  getIt.registerLazySingleton(() => BannerBloc(
        createBannerUsecase: getIt<CreateBannerUsecase>(),
      ));

  // Permission Blocs
  getIt.registerLazySingleton(() => PermissionBloc(
        getIt<PermissionService>(),
      ));
  getIt.registerLazySingleton(() => HomeMainBloc(
        getLatestBooksUseCase: getIt<GetLatestBooksUseCase>(),
        getRecommendedBooksUsecase: getIt<GetRecommendedBooksUseCase>(),
        getStatsUseCase: getIt<GetStatsUseCase>(),
        getBannersUseCase: getIt<GetBannersUseCase>(),
      ));
}

// ========================================
// CUBITS
// ========================================
void _registerCubits() {
  // User Cubits
  getIt.registerLazySingleton(() => UserCubit(getIt<GetUserListUseCase>()));
}
