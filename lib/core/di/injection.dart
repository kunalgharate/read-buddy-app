// lib/core/di/injection.dart

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:read_buddy_app/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:read_buddy_app/features/auth/presentation/blocs/google_sign_in/google_sign_in_bloc.dart';
import 'package:read_buddy_app/features/bookcrud/data/dataresources/bookCrud_remote_resources.dart';
import 'package:read_buddy_app/features/bookcrud/data/dataresources/user_remote_resources.dart';
import 'package:read_buddy_app/features/bookcrud/data/repositories/bookcrud_repo_impl.dart';
import 'package:read_buddy_app/features/bookcrud/data/repositories/user_repo_impl.dart';
import 'package:read_buddy_app/features/bookcrud/domain/respository/bookcrud_repo.dart';
import 'package:read_buddy_app/features/bookcrud/domain/respository/user_repo.dart';
import 'package:read_buddy_app/features/bookcrud/domain/usecases/add_book.dart';
import 'package:read_buddy_app/features/bookcrud/domain/usecases/delete_book.dart';
import 'package:read_buddy_app/features/bookcrud/domain/usecases/get_books.dart';
import 'package:read_buddy_app/features/bookcrud/domain/usecases/get_books_by_id.dart';
import 'package:read_buddy_app/features/bookcrud/domain/usecases/update_book.dart';
import 'package:read_buddy_app/features/bookcrud/domain/usecases/user_listcase.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/bloc/book_crud_bloc.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/cubit/cubit/user_cubit.dart';
import 'package:read_buddy_app/features/books/data/datasources/book_remote_data_source.dart';
import 'package:read_buddy_app/features/books/data/repositories/book_repository_impl.dart';
import 'package:read_buddy_app/features/books/domain/repositories/book_repository.dart';
import 'package:read_buddy_app/features/books/domain/usecases/get_books.dart';
import 'package:read_buddy_app/features/books/presentation/bloc/book_bloc.dart';
import 'package:read_buddy_app/features/category_crud/data/datasources/category_remote_dataresources.dart';
import 'package:read_buddy_app/features/category_crud/data/repositories/category_repo_impl.dart';
import 'package:read_buddy_app/features/category_crud/domain/repository/category_repository.dart';
import 'package:read_buddy_app/features/category_crud/domain/usecases/add_categories.dart';
import 'package:read_buddy_app/features/category_crud/domain/usecases/dele_category.dart';
import 'package:read_buddy_app/features/category_crud/domain/usecases/get_caategories.dart';
import 'package:read_buddy_app/features/category_crud/domain/usecases/update_category.dart';
import 'package:read_buddy_app/features/category_crud/presentation/bloc/bloc/category_bloc.dart';

import '../../features/auth/data/remotesource/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_in.dart';
import '../../features/auth/presentation/blocs/sign_in/sign_in_bloc.dart';
import '../utils/secure_storage_utils.dart';
import 'injection.config.dart'; // Import generated file

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: true, // default
)
Future<void> configureDependencies() async => getIt.init();
