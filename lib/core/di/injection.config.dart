// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:read_buddy_app/core/network/dio_client.dart' as _i707;
import 'package:read_buddy_app/features/books/domain/usecases/get_books.dart'
    as _i24;
import 'package:read_buddy_app/features/books/presentation/bloc/book_bloc.dart'
    as _i861;

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
    gh.lazySingleton<_i361.Dio>(() => dioModule.dio);
    gh.factory<_i861.BookBloc>(() => _i861.BookBloc(gh<_i24.GetBooks>()));
    return this;
  }
}

class _$DioModule extends _i707.DioModule {}
