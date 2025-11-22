// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/image_processing/data/datasources/local_image_datasource.dart'
    as _i495;
import '../../features/image_processing/data/datasources/local_image_datasource_impl.dart'
    as _i220;
import '../../features/image_processing/data/repositories/image_repository_impl.dart'
    as _i246;
import '../../features/image_processing/domain/repositories/image_repository.dart'
    as _i280;
import '../../features/image_processing/domain/usecases/compress_image_usecase.dart'
    as _i89;
import '../../features/image_processing/domain/usecases/convert_image_usecase.dart'
    as _i750;
import '../../features/image_processing/presentation/cubit/image_cubit.dart'
    as _i743;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i495.LocalImageDataSource>(
      () => _i220.LocalImageDataSourceImpl(),
    );
    gh.lazySingleton<_i280.ImageRepository>(
      () => _i246.ImageRepositoryImpl(gh<_i495.LocalImageDataSource>()),
    );
    gh.lazySingleton<_i89.CompressImageUseCase>(
      () => _i89.CompressImageUseCase(gh<_i280.ImageRepository>()),
    );
    gh.lazySingleton<_i750.ConvertImageUseCase>(
      () => _i750.ConvertImageUseCase(gh<_i280.ImageRepository>()),
    );
    gh.factory<_i743.ImageCubit>(
      () => _i743.ImageCubit(
        gh<_i750.ConvertImageUseCase>(),
        gh<_i89.CompressImageUseCase>(),
      ),
    );
    return this;
  }
}
