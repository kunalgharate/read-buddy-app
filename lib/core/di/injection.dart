import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:read_buddy_app/features/banner/domain/usecase/delete_banner.dart';
import 'package:read_buddy_app/features/banner/domain/usecase/get_banner.dart';
import 'package:read_buddy_app/features/banner/domain/usecase/update_banner.dart';
import 'package:read_buddy_app/features/bookcrud/data/repositories/search_location_repo_impl.dart';
import 'package:read_buddy_app/features/bookcrud/domain/respository/search_location_repo.dart';
import 'package:read_buddy_app/features/bookcrud/domain/usecases/search_book.dart';
import 'package:read_buddy_app/features/bookcrud/domain/usecases/search_location.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/cubit/cubit/location_cubit.dart';
import 'package:read_buddy_app/features/profile/domain/usecases/get_profile.dart';

// Core
import 'package:read_buddy_app/features/donate/domain/usecases/upload_receipt.dart';
import 'package:read_buddy_app/features/profile/data/datasource/profile_remote_data_source.dart';
import 'package:read_buddy_app/features/profile/domain/usecases/update_user_avatar.dart';
import 'package:read_buddy_app/core/network/dio_client.dart';
import 'package:read_buddy_app/core/utils/secure_storage_utils.dart';

// Auth
import 'package:read_buddy_app/features/auth/data/remotesource/auth_remote_data_source.dart';
import 'package:read_buddy_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:read_buddy_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:read_buddy_app/features/auth/domain/usecases/register_user_usecase.dart';
import 'package:read_buddy_app/features/auth/domain/usecases/sign_in.dart';
import 'package:read_buddy_app/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:read_buddy_app/features/auth/domain/usecases/verify_email_usecase.dart';
import 'package:read_buddy_app/features/auth/domain/usecases/send_otp_usecase.dart';
import 'package:read_buddy_app/features/auth/domain/usecases/verify_reset_otp_usecase.dart';
import 'package:read_buddy_app/features/auth/domain/usecases/change_password_usecase.dart';
import 'package:read_buddy_app/features/auth/presentation/blocs/google_sign_in/google_sign_in_bloc.dart';
import 'package:read_buddy_app/features/auth/presentation/blocs/sign_in/sign_in_bloc.dart';
import 'package:read_buddy_app/features/auth/presentation/blocs/sign_up/sign_up_bloc.dart';

// Profile
import 'package:read_buddy_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:read_buddy_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:read_buddy_app/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:read_buddy_app/features/profile/presentation/blocs/profile_bloc.dart';

// Home Books
import 'package:read_buddy_app/features/homebooks/data/datasource/home_remote_datasource.dart';
import 'package:read_buddy_app/features/homebooks/data/repositories/home_book_repository_impl.dart';
import 'package:read_buddy_app/features/homebooks/domain/repositories/home_book_repository.dart';
import 'package:read_buddy_app/features/homebooks/domain/usecases/get_latest_books_usecase.dart';
import 'package:read_buddy_app/features/homebooks/domain/usecases/get_trending_books_usecase.dart';
import 'package:read_buddy_app/features/homebooks/domain/usecases/get_recommended_books_usecase.dart';
import 'package:read_buddy_app/features/homebooks/presentation/bloc/home_book_bloc.dart';

// Books
import 'package:read_buddy_app/features/books/data/datasources/book_remote_data_source.dart';
import 'package:read_buddy_app/features/books/data/repositories/book_repository_impl.dart';
import 'package:read_buddy_app/features/books/domain/repositories/book_repository.dart';
import 'package:read_buddy_app/features/books/domain/usecases/get_books.dart';
import 'package:read_buddy_app/features/books/presentation/bloc/book_bloc.dart';

// Book CRUD
import 'package:read_buddy_app/features/bookcrud/data/dataresources/book_crud_remote_resources.dart';
import 'package:read_buddy_app/features/bookcrud/data/dataresources/user_remote_resources.dart';
import 'package:read_buddy_app/features/bookcrud/data/dataresources/search_location_remote_resources.dart';
import 'package:read_buddy_app/features/bookcrud/data/dataresources/variant_remote_data_source.dart';
import 'package:read_buddy_app/features/bookcrud/data/repositories/bookcrud_repo_impl.dart';
import 'package:read_buddy_app/features/bookcrud/data/repositories/user_repo_impl.dart';
import 'package:read_buddy_app/features/bookcrud/domain/respository/bookcrud_repo.dart';
import 'package:read_buddy_app/features/bookcrud/domain/respository/user_repo.dart';
import 'package:read_buddy_app/features/bookcrud/domain/respository/variant_repository.dart';
import 'package:read_buddy_app/features/bookcrud/data/repositories/variant_repository_impl.dart';
import 'package:read_buddy_app/features/bookcrud/domain/usecases/add_book.dart';
import 'package:read_buddy_app/features/bookcrud/domain/usecases/delete_book.dart';
import 'package:read_buddy_app/features/bookcrud/domain/usecases/get_books.dart';
import 'package:read_buddy_app/features/bookcrud/domain/usecases/get_books_by_id.dart';
import 'package:read_buddy_app/features/bookcrud/domain/usecases/update_book.dart';
import 'package:read_buddy_app/features/bookcrud/domain/usecases/user_listcase.dart';
import 'package:read_buddy_app/features/bookcrud/domain/usecases/create_variant.dart';
import 'package:read_buddy_app/features/bookcrud/domain/usecases/update_variant.dart';
import 'package:read_buddy_app/features/bookcrud/domain/usecases/delete_variant.dart';
import 'package:read_buddy_app/features/bookcrud/domain/usecases/add_format.dart';
import 'package:read_buddy_app/features/bookcrud/domain/usecases/remove_format.dart';
import 'package:read_buddy_app/features/bookcrud/domain/usecases/get_variants_for_book.dart';
import 'package:read_buddy_app/features/bookcrud/domain/usecases/add_parts_to_format.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/bloc/book_crud_bloc.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/variant/variant_bloc.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/cubit/cubit/user_cubit.dart';

// Category CRUD
import 'package:read_buddy_app/features/category_crud/data/datasources/category_remote_dataresources.dart';
import 'package:read_buddy_app/features/category_crud/data/repositories/category_repo_impl.dart';
import 'package:read_buddy_app/features/category_crud/domain/repository/category_repository.dart';
import 'package:read_buddy_app/features/category_crud/domain/usecases/add_categories.dart';
import 'package:read_buddy_app/features/category_crud/domain/usecases/dele_category.dart';
import 'package:read_buddy_app/features/category_crud/domain/usecases/get_caategories.dart';
import 'package:read_buddy_app/features/category_crud/domain/usecases/update_category.dart';
import 'package:read_buddy_app/features/category_crud/presentation/bloc/bloc/category_bloc.dart';

// Banner
import 'package:read_buddy_app/features/banner/datasources/data/createbanner_remote_datasource.dart';
import 'package:read_buddy_app/features/banner/datasources/repositories/banner_repo_impl.dart';
import 'package:read_buddy_app/features/banner/domain/repository/banner_repository.dart';
import 'package:read_buddy_app/features/banner/domain/usecase/create_banner.dart';
import 'package:read_buddy_app/features/banner/presentation/bloc/banner_bloc.dart';

// Questionaries
import 'package:read_buddy_app/features/questionaries/data/datasources/onboarding_remote_datasource.dart';
import 'package:read_buddy_app/features/questionaries/data/repositories/question_repository_impl.dart';
import 'package:read_buddy_app/features/questionaries/domain/repositories/onboarding_repository.dart';
import 'package:read_buddy_app/features/questionaries/domain/usecases/get_questions.dart';
import 'package:read_buddy_app/features/questionaries/domain/usecases/set_preferences.dart';
import 'package:read_buddy_app/features/questionaries/domain/usecases/update_user_preferences.dart';
import 'package:read_buddy_app/features/questionaries/domain/usecases/delete_user_preferences.dart';
import 'package:read_buddy_app/features/questionaries/domain/usecases/set_onboarding_status.dart';
import 'package:read_buddy_app/features/questionaries/presentations/bloc/on_boarding_bloc.dart';

// Donated Books
import 'package:read_buddy_app/features/donated_books/data/datasources/donation_remote_data_source.dart';
import 'package:read_buddy_app/features/donated_books/data/repositories/donated_books_repository_impl.dart';
import 'package:read_buddy_app/features/donated_books/domain/repositories/donated_books_repository.dart';
import 'package:read_buddy_app/features/donated_books/domain/usecases/get_donated_books.dart';
import 'package:read_buddy_app/features/donated_books/presentation/bloc/donated_books_bloc.dart';

// Book Request
import '../../features/book_request/data/datasources/book_request_remote_datasource.dart';
import '../../features/book_request/data/repositories/book_request_repository_impl.dart';
import '../../features/book_request/domain/repositories/book_request_repository.dart';
import '../../features/book_request/domain/usecases/get_book_detail.dart';
import '../../features/book_request/domain/usecases/create_book_request.dart';
import '../../features/book_request/domain/usecases/get_my_book_requests.dart';
import '../../features/book_request/domain/usecases/get_all_book_requests.dart';
import '../../features/book_request/domain/usecases/accept_book_request.dart';
import '../../features/book_request/domain/usecases/decline_book_request.dart';
import '../../features/book_request/domain/usecases/get_library_details.dart';
import '../../features/book_request/domain/usecases/schedule_pickup.dart';
import '../../features/book_request/domain/usecases/schedule_delivery.dart';
import '../../features/book_request/domain/usecases/update_request_status.dart';
import '../../features/book_request/domain/usecases/get_upcoming_pickups.dart';
import '../../features/book_request/domain/usecases/cancel_book_request.dart';
import '../../features/book_request/presentation/bloc/book_request_bloc.dart';
import '../../features/book_request/presentation/bloc/my_requests_bloc.dart';
import '../../features/book_request/presentation/bloc/admin_requests_bloc.dart';
import '../../features/book_request/presentation/bloc/admin_upcoming_pickups_bloc.dart';

// Notification
import '../../features/notification/data/datasources/notification_remote_datasource.dart';
import '../../features/notification/data/repositories/notification_repository_impl.dart';
import '../../features/notification/domain/repositories/notification_repository.dart';
import '../../features/notification/domain/usecases/get_my_notifications.dart';
import '../../features/notification/domain/usecases/send_notification.dart';
import '../../features/notification/presentation/bloc/notification_bloc.dart';

// Question CRUD (Admin)
import 'package:read_buddy_app/features/question_crud/data/datasources/question_remote_datasource.dart'
    as question_crud_data_source;
import 'package:read_buddy_app/features/question_crud/data/repositories/question_repository_impl.dart'
    as question_crud_repo;
import 'package:read_buddy_app/features/question_crud/domain/repositories/question_repository.dart'
    as question_crud_domain;
import 'package:read_buddy_app/features/question_crud/domain/usecases/get_questions.dart'
    as question_crud_use_cases;
import 'package:read_buddy_app/features/question_crud/domain/usecases/add_question.dart'
    as question_crud_use_cases;
import 'package:read_buddy_app/features/question_crud/domain/usecases/update_question.dart'
    as question_crud_use_cases;
import 'package:read_buddy_app/features/question_crud/domain/usecases/delete_question.dart'
    as question_crud_use_cases;

// Donation Stats

// Donate
import 'package:read_buddy_app/features/donate/data/datasources/donate_remote_datasource.dart';
import 'package:read_buddy_app/features/donate/data/repositories/donate_repository_impl.dart';
import 'package:read_buddy_app/features/donate/domain/repositories/donate_repository.dart';
import 'package:read_buddy_app/features/donate/domain/usecases/get_donation_stats.dart'
    as donate_use_cases;
import 'package:read_buddy_app/features/donate/domain/usecases/get_nearest_agents.dart';
import 'package:read_buddy_app/features/donate/domain/usecases/create_book_donation.dart';
import 'package:read_buddy_app/features/donate/presentation/bloc/donate_book_bloc.dart';
import 'package:read_buddy_app/features/explore/presentation/bloc/explore_bloc.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  await GetIt.instance.reset();
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
  getIt.registerSingleton<SecureStorageUtil>(SecureStorageUtil());
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

  // Profile
  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(
      dio: getIt<Dio>(),
      secureStorage: getIt<SecureStorageUtil>(),
    ),
  );

  // Home Books
  getIt.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  // Books
  getIt.registerLazySingleton<BookRemoteDataSource>(
    () => BookRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  // Book CRUD
  getIt.registerLazySingleton<BookCrudRemoteDataSource>(
    () => BookCrudRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  // Book Variants Remote
  getIt.registerLazySingleton<VariantRemoteDataSource>(
    () => VariantRemoteDataSourceImpl(dio: getIt<Dio>()),
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

  // Donated Books
  getIt.registerLazySingleton<DonatedBooksRemoteDataSource>(
    () => DonatedBooksRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  // Book Request
  getIt.registerLazySingleton<BookRequestRemoteDataSource>(
    () => BookRequestRemoteDataSourceImpl(
      dio: getIt<Dio>(),
      secureStorage: getIt<SecureStorageUtil>(),
    ),
  );

  // Question CRUD (Admin)
  getIt.registerLazySingleton<
      question_crud_data_source.QuestionRemoteDataSource>(
    () => question_crud_data_source.QuestionRemoteDataSource(
      getIt<Dio>(),
      getIt<SecureStorageUtil>(),
    ),
  );

  // Donate
  getIt.registerLazySingleton<DonateRemoteDataSource>(
    () => DonateRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  // Notification
  getIt.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(dio: getIt<Dio>()),
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

  // Profile
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(getIt<ProfileRemoteDataSource>()),
  );

  // Home Books
  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remoteDataSource: getIt<HomeRemoteDataSource>()),
  );

  // Books
  getIt.registerLazySingleton<BookRepository>(
    () => BookRepositoryImpl(getIt<BookRemoteDataSource>()),
  );

  // Book CRUD
  getIt.registerLazySingleton<BookCrudRepository>(
    () => BookCrudRepositoryImpl(getIt<BookCrudRemoteDataSource>()),
  );

  // Book Variants
  getIt.registerLazySingleton<VariantRepository>(
    () => VariantRepositoryImpl(getIt<VariantRemoteDataSource>()),
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

  // Donated Books
  getIt.registerLazySingleton<DonatedBooksRepository>(
    () => DonatedBooksRepositoryImpl(getIt<DonatedBooksRemoteDataSource>()),
  );

  // Book Request
  getIt.registerLazySingleton<BookRequestRepository>(
    () => BookRequestRepositoryImpl(getIt<BookRequestRemoteDataSource>()),
  );

  // Question CRUD (Admin)
  getIt.registerLazySingleton<question_crud_domain.QuestionRepository>(
    () => question_crud_repo.QuestionRepositoryImpl(
      getIt<question_crud_data_source.QuestionRemoteDataSource>(),
    ),
  );

  // Donate
  getIt.registerLazySingleton<DonateRepository>(
    () => DonateRepositoryImpl(
      remoteDataSource: getIt<DonateRemoteDataSource>(),
    ),
  );

  // Notification — was previously missing; required by SendNotificationUsecase
  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(getIt<NotificationRemoteDataSource>()),
  );
}

// ========================================
// USE CASES
// ========================================
void _registerUseCases() {
  // Auth
  getIt.registerLazySingleton(() => SignIn(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => SignInWithGoogle(getIt<AuthRepository>()));
  getIt.registerLazySingleton(
      () => RegisterUserUseCase(getIt<AuthRepository>()));
  getIt
      .registerLazySingleton(() => VerifyEmailUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => SendOtpUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(
      () => VerifyResetOtpUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(
      () => ChangePasswordUseCase(getIt<AuthRepository>()));

// Profile
  getIt.registerLazySingleton(
      () => GetProfileUseCase(getIt<ProfileRepository>()));
  getIt.registerLazySingleton(
      () => UpdateProfileUseCase(getIt<ProfileRepository>()));
  getIt.registerLazySingleton(
      () => UpdateAvatarUseCase(getIt<ProfileRepository>()));
  // Home Books
  getIt.registerLazySingleton(
      () => GetLatestBooksUseCase(getIt<HomeRepository>()));
  getIt.registerLazySingleton(
      () => GetTrendingBooksUseCase(getIt<HomeRepository>()));
  getIt.registerLazySingleton(
      () => GetRecommendedBookUseCase(getIt<HomeRepository>()));

  // Books
  getIt.registerLazySingleton(() => GetBooks(getIt<BookRepository>()));

  // Book CRUD
  getIt.registerLazySingleton(
      () => SearchBookUsecase(getIt<BookCrudRepository>()));
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

  // Book Variant Use Cases
  getIt.registerLazySingleton(
      () => CreateVariantUsecase(getIt<VariantRepository>()));
  getIt.registerLazySingleton(
      () => UpdateVariantUsecase(getIt<VariantRepository>()));
  getIt.registerLazySingleton(
      () => DeleteVariantUsecase(getIt<VariantRepository>()));
  getIt.registerLazySingleton(
      () => AddFormatUsecase(getIt<VariantRepository>()));
  getIt.registerLazySingleton(
      () => RemoveFormatUsecase(getIt<VariantRepository>()));
  getIt.registerLazySingleton(
      () => GetVariantsForBookUsecase(getIt<VariantRepository>()));
  getIt.registerLazySingleton(
      () => AddPartsToFormatUsecase(getIt<VariantRepository>()));

  // User
  getIt
      .registerLazySingleton(() => GetUserListUseCase(getIt<UserRepository>()));

  // Search Location
  getIt.registerLazySingleton(
      () => SearchLocationUsecase(getIt<SearchLocationRepository>()));

  // Category CRUD
  getIt.registerLazySingleton(
      () => AddCategoryUsecase(getIt<CategoryRepository>()));
  getIt.registerLazySingleton(
      () => DeleteCategoryUsecase(getIt<CategoryRepository>()));
  getIt.registerLazySingleton(
      () => GetCategoriesUsecase(getIt<CategoryRepository>()));
  getIt.registerLazySingleton(
      () => UpdateCategoryUsecase(getIt<CategoryRepository>()));

  // Banner
  getIt
      .registerLazySingleton(() => GetBannerUsecase(getIt<BannerRepository>()));
  getIt.registerLazySingleton(
      () => CreateBannerUsecase(getIt<BannerRepository>()));
  getIt.registerLazySingleton(
      () => UpdateBannerUsecase(getIt<BannerRepository>()));
  getIt.registerLazySingleton(
      () => DeleteBannerUsecase(getIt<BannerRepository>()));

  // Questionaries
  getIt.registerLazySingleton(
      () => GetQuestionsUseCase(getIt<OnboardingRepository>()));
  getIt.registerLazySingleton(
      () => SetPreferencesUseCase(getIt<OnboardingRepository>()));
  getIt.registerLazySingleton(
      () => UpdatePreferencesUseCase(getIt<OnboardingRepository>()));
  getIt.registerLazySingleton(
      () => DeletePreferencesUseCase(getIt<OnboardingRepository>()));
  getIt.registerLazySingleton(
      () => SetOnboardingStatusUseCase(getIt<OnboardingRepository>()));

  // Donated Books
  getIt.registerLazySingleton(
      () => GetDonatedBooks(getIt<DonatedBooksRepository>()));

  // Book Request
  getIt.registerLazySingleton(
      () => GetBookDetailUsecase(getIt<BookRequestRepository>()));
  getIt.registerLazySingleton(
      () => CreateBookRequestUsecase(getIt<BookRequestRepository>()));
  getIt.registerLazySingleton(
      () => GetMyBookRequestsUsecase(getIt<BookRequestRepository>()));
  getIt.registerLazySingleton(
      () => CancelBookRequestUsecase(getIt<BookRequestRepository>()));
  getIt.registerLazySingleton(
      () => GetAllBookRequestsUsecase(getIt<BookRequestRepository>()));
  getIt.registerLazySingleton(
      () => AcceptBookRequestUsecase(getIt<BookRequestRepository>()));
  getIt.registerLazySingleton(
      () => DeclineBookRequestUsecase(getIt<BookRequestRepository>()));
  getIt.registerLazySingleton(
      () => GetLibraryDetailsUsecase(getIt<BookRequestRepository>()));
  getIt.registerLazySingleton(
      () => SchedulePickupUsecase(getIt<BookRequestRepository>()));
  getIt.registerLazySingleton(
      () => ScheduleDeliveryUsecase(getIt<BookRequestRepository>()));
  getIt.registerLazySingleton(
      () => UpdateRequestStatusUsecase(getIt<BookRequestRepository>()));
  getIt.registerLazySingleton(
      () => GetUpcomingPickupsUsecase(getIt<BookRequestRepository>()));

  // Question CRUD (Admin)
  getIt.registerLazySingleton(() => question_crud_use_cases.GetQuestions(
      getIt<question_crud_domain.QuestionRepository>()));
  getIt.registerLazySingleton(() => question_crud_use_cases.AddQuestion(
      getIt<question_crud_domain.QuestionRepository>()));
  getIt.registerLazySingleton(() => question_crud_use_cases.UpdateQuestion(
      getIt<question_crud_domain.QuestionRepository>()));
  getIt.registerLazySingleton(() => question_crud_use_cases.DeleteQuestion(
      getIt<question_crud_domain.QuestionRepository>()));

  // Donate
  getIt.registerLazySingleton(() =>
      donate_use_cases.GetDonationStats(repository: getIt<DonateRepository>()));
  getIt.registerLazySingleton(
      () => GetNearestAgents(repository: getIt<DonateRepository>()));
  getIt.registerLazySingleton(
      () => CreateBookDonation(repository: getIt<DonateRepository>()));
  getIt.registerLazySingleton(
      () => UploadReceipt(repository: getIt<DonateRepository>()));

  // Notification
  getIt.registerLazySingleton(
      () => GetMyNotificationsUsecase(getIt<NotificationRepository>()));
  getIt.registerLazySingleton(
      () => SendNotificationUsecase(getIt<NotificationRepository>()));
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
  getIt
      .registerLazySingleton(() => GoogleSignInBloc(getIt<SignInWithGoogle>()));
  getIt.registerLazySingleton(() => SignUpBloc(
        getIt<RegisterUserUseCase>(),
        getIt<VerifyEmailUseCase>(),
      ));

  // Profile
  getIt.registerFactory(() => ProfileBloc(
        getIt<SecureStorageUtil>(),
        getIt<GetProfileUseCase>(),
        getIt<UpdateAvatarUseCase>(),
        getIt<UpdateProfileUseCase>(),
      ));

  // Home Books
  getIt.registerFactory(() => HomeBloc(
        getLatestBooks: getIt<GetLatestBooksUseCase>(),
        getTrendingBooks: getIt<GetTrendingBooksUseCase>(),
        getRecommendedBooks: getIt<GetRecommendedBookUseCase>(),
        secureStorage: getIt<SecureStorageUtil>(),
      ));

  // Donated Books
  getIt.registerLazySingleton(() => DonatedBooksBloc(getIt<GetDonatedBooks>()));

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

  // Book Variant
  getIt.registerFactory(() => VariantBloc(
        getVariantsForBook: getIt<GetVariantsForBookUsecase>(),
        createVariant: getIt<CreateVariantUsecase>(),
        updateVariant: getIt<UpdateVariantUsecase>(),
        deleteVariant: getIt<DeleteVariantUsecase>(),
        addFormat: getIt<AddFormatUsecase>(),
        removeFormat: getIt<RemoveFormatUsecase>(),
        addPartsToFormat: getIt<AddPartsToFormatUsecase>(),
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

  // Donate
  getIt.registerFactory(() => DonateBookBloc(
        getDonationStats: getIt<donate_use_cases.GetDonationStats>(),
        getNearestAgents: getIt<GetNearestAgents>(),
        createBookDonation: getIt<CreateBookDonation>(),
        uploadReceipt: getIt<UploadReceipt>(),
      ));

  // Book Request
  getIt.registerFactory(() => BookRequestBloc(
        getBookDetail: getIt<GetBookDetailUsecase>(),
        createBookRequest: getIt<CreateBookRequestUsecase>(),
        getLibraryDetails: getIt<GetLibraryDetailsUsecase>(),
        schedulePickup: getIt<SchedulePickupUsecase>(),
        scheduleDelivery: getIt<ScheduleDeliveryUsecase>(),
      ));
  getIt.registerFactory(() => MyRequestsBloc(
        getMyBookRequests: getIt<GetMyBookRequestsUsecase>(),
        cancelBookRequest: getIt<CancelBookRequestUsecase>(),
        updateRequestStatus: getIt<UpdateRequestStatusUsecase>(),
      ));
  getIt.registerFactory(() => AdminRequestsBloc(
        getAllBookRequests: getIt<GetAllBookRequestsUsecase>(),
        acceptBookRequest: getIt<AcceptBookRequestUsecase>(),
        declineBookRequest: getIt<DeclineBookRequestUsecase>(),
        updateRequestStatus: getIt<UpdateRequestStatusUsecase>(),
        sendNotification: getIt<SendNotificationUsecase>(),
      ));
  getIt.registerFactory(() => AdminUpcomingPickupsBloc(
        getUpcomingPickups: getIt<GetUpcomingPickupsUsecase>(),
      ));

  // Notification
  getIt.registerFactory(() => NotificationBloc(
        getMyNotifications: getIt<GetMyNotificationsUsecase>(),
        repository: getIt<NotificationRepository>(),
      ));

  // Explore
  getIt.registerFactory(() => ExploreBloc(
        categoryDataSource: getIt<CategoryRemoteDataSource>(),
        bookDataSource: getIt<BookCrudRemoteDataSource>(),
      ));
}

// ========================================
// CUBITS
// ========================================
void _registerCubits() {
  getIt.registerLazySingleton(() => UserCubit(getIt<GetUserListUseCase>()));
  getIt.registerLazySingleton(
      () => LocationCubit(getIt<SearchLocationUsecase>()));
}
