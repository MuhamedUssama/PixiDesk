// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

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
import '../../features/pdf/pdf_compression/data/datasources/ghostscript_compression_service.dart'
    as _i725;
import '../../features/pdf/pdf_compression/data/repositories/pdf_compression_repository_impl.dart'
    as _i561;
import '../../features/pdf/pdf_compression/domain/repositories/pdf_compression_repository.dart'
    as _i457;
import '../../features/pdf/pdf_compression/domain/usecases/compress_pdf_usecase.dart'
    as _i263;
import '../../features/pdf/pdf_compression/presentation/cubit/pdf_compression_cubit.dart'
    as _i400;
import '../../features/pdf/pdf_converter/data/repositories/pdf_repository_impl.dart'
    as _i1022;
import '../../features/pdf/pdf_converter/domain/repositories/pdf_repository.dart'
    as _i347;
import '../../features/pdf/pdf_converter/domain/usecases/generate_pdf_use_case.dart'
    as _i796;
import '../../features/pdf/pdf_converter/presentation/cubit/pdf_converter_cubit.dart'
    as _i1023;
import '../../features/pdf/pdf_to_image/data/datasources/poppler_service.dart'
    as _i649;
import '../../features/pdf/pdf_to_image/data/repositories/pdf_to_image_repository_impl.dart'
    as _i850;
import '../../features/pdf/pdf_to_image/domain/repositories/pdf_to_image_repository.dart'
    as _i114;
import '../../features/pdf/pdf_to_image/domain/usecases/convert_pdf_to_images_usecase.dart'
    as _i45;
import '../../features/pdf/pdf_to_image/presentation/cubit/pdf_to_image_cubit.dart'
    as _i748;
import '../../features/settings/data/repositories/settings_repository_impl.dart'
    as _i955;
import '../../features/settings/domain/repositories/settings_repository.dart'
    as _i674;
import '../../features/settings/presentation/cubit/settings_cubit.dart'
    as _i792;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.factory<_i725.GhostscriptCompressionService>(
      () => _i725.GhostscriptCompressionService(),
    );
    gh.factory<_i649.PopplerService>(() => _i649.PopplerService());
    gh.lazySingleton<_i457.PdfCompressionRepository>(
      () => _i561.PdfCompressionRepositoryImpl(),
    );
    gh.lazySingleton<_i347.PdfRepository>(() => _i1022.PdfRepositoryImpl());
    gh.lazySingleton<_i495.LocalImageDataSource>(
      () => _i220.LocalImageDataSourceImpl(),
    );
    gh.lazySingleton<_i674.SettingsRepository>(
      () => _i955.SettingsRepositoryImpl(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i280.ImageRepository>(
      () => _i246.ImageRepositoryImpl(gh<_i495.LocalImageDataSource>()),
    );
    gh.factory<_i263.CompressPdfUseCase>(
      () => _i263.CompressPdfUseCase(gh<_i457.PdfCompressionRepository>()),
    );
    gh.lazySingleton<_i89.CompressImageUseCase>(
      () => _i89.CompressImageUseCase(gh<_i280.ImageRepository>()),
    );
    gh.lazySingleton<_i750.ConvertImageUseCase>(
      () => _i750.ConvertImageUseCase(gh<_i280.ImageRepository>()),
    );
    gh.factory<_i400.PdfCompressionCubit>(
      () => _i400.PdfCompressionCubit(gh<_i263.CompressPdfUseCase>()),
    );
    gh.lazySingleton<_i114.PdfToImageRepository>(
      () => _i850.PdfToImageRepositoryImpl(gh<_i649.PopplerService>()),
    );
    gh.factory<_i743.ImageCubit>(
      () => _i743.ImageCubit(
        gh<_i750.ConvertImageUseCase>(),
        gh<_i89.CompressImageUseCase>(),
      ),
    );
    gh.factory<_i796.GeneratePdfUseCase>(
      () => _i796.GeneratePdfUseCase(gh<_i347.PdfRepository>()),
    );
    gh.factory<_i1023.PdfConverterCubit>(
      () => _i1023.PdfConverterCubit(gh<_i796.GeneratePdfUseCase>()),
    );
    gh.factory<_i45.ConvertPdfToImagesUseCase>(
      () => _i45.ConvertPdfToImagesUseCase(gh<_i114.PdfToImageRepository>()),
    );
    gh.factory<_i792.SettingsCubit>(
      () => _i792.SettingsCubit(gh<_i674.SettingsRepository>()),
    );
    gh.factory<_i748.PdfToImageCubit>(
      () => _i748.PdfToImageCubit(gh<_i45.ConvertPdfToImagesUseCase>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
