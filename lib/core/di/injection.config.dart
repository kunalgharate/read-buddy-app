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
import '../../features/books/data/datasources/book_remote_data_source.dart'
    as _i906;
import '../../features/books/data/repositories/book_repository_impl.dart'
    as _i661;
import '../../features/books/domain/repositories/book_repository.dart' as _i674;
import '../../features/books/domain/usecases/get_books.dart' as _i581;
import '../../features/books/presentation/bloc/book_bloc.dart' as _i903;
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
    gh.factory<_i170.AuthRemoteDataSource>(
        () => _i170.AuthRemoteDataSourceImpl(dio: gh<_i361.Dio>()));
    gh.factory<_i906.BookRemoteDataSource>(
        () => _i906.BookRemoteDataSourceImpl(dio: gh<_i361.Dio>()));
    gh.factory<_i674.BookRepository>(
        () => _i661.BookRepositoryImpl(gh<_i906.BookRemoteDataSource>()));
    gh.factory<_i787.AuthRepository>(
        () => _i153.AuthRepositoryImpl(gh<_i170.AuthRemoteDataSource>()));
    gh.factory<_i581.GetBooks>(
        () => _i581.GetBooks(gh<_i674.BookRepository>()));
    gh.factory<_i903.BookBloc>(() => _i903.BookBloc(gh<_i581.GetBooks>()));
    gh.factory<_i920.SignIn>(() => _i920.SignIn(gh<_i787.AuthRepository>()));
    gh.factory<_i78.SignInBloc>(() => _i78.SignInBloc(gh<_i920.SignIn>()));
    return this;
  }
}

class _$DioModule extends _i667.DioModule {}
