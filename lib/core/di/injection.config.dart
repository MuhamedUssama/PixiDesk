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
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/image_processing/data/datasources/local_image_datasource.dart'
    as _i495;
import '../../features/image_processing/data/datasources/local_image_datasource_impl.dart'
    as _i220;
import '../../features/image_processing/data/repositories/image_repository_impl.dart'
    as _i246;
import '../../features/image_processing/data/repositories/image_workspace_repository_impl.dart'
    as _i399;
import '../../features/image_processing/data/services/local_image_desktop_gateway.dart'
    as _i386;
import '../../features/image_processing/domain/repositories/image_repository.dart'
    as _i280;
import '../../features/image_processing/domain/repositories/image_workspace_repository.dart'
    as _i569;
import '../../features/image_processing/domain/services/image_desktop_gateway.dart'
    as _i968;
import '../../features/image_processing/domain/usecases/compress_image_usecase.dart'
    as _i89;
import '../../features/image_processing/domain/usecases/convert_image_usecase.dart'
    as _i750;
import '../../features/image_processing/domain/usecases/image_desktop_usecase.dart'
    as _i862;
import '../../features/image_processing/domain/usecases/image_workspace_usecase.dart'
    as _i1058;
import '../../features/image_processing/domain/usecases/preview_image_usecase.dart'
    as _i444;
import '../../features/image_processing/domain/usecases/process_image_usecase.dart'
    as _i510;
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
import '../../features/pdf/pdf_merge/data/repositories/pdf_merge_repository_impl.dart'
    as _i693;
import '../../features/pdf/pdf_merge/data/services/pdf_merge_desktop_gateway_impl.dart'
    as _i1013;
import '../../features/pdf/pdf_merge/data/services/pdf_merge_preview_service.dart'
    as _i0;
import '../../features/pdf/pdf_merge/data/services/qpdf_process_runner.dart'
    as _i286;
import '../../features/pdf/pdf_merge/data/services/qpdf_runtime.dart' as _i378;
import '../../features/pdf/pdf_merge/domain/repositories/pdf_merge_repository.dart'
    as _i530;
import '../../features/pdf/pdf_merge/domain/services/pdf_merge_desktop_gateway.dart'
    as _i1007;
import '../../features/pdf/pdf_merge/presentation/bloc/pdf_merge_bloc.dart'
    as _i515;
import '../../features/pdf/pdf_to_image/data/datasources/pdf_export_dialogs_impl.dart'
    as _i298;
import '../../features/pdf/pdf_to_image/data/pdfium/pdfium_conversion_service.dart'
    as _i731;
import '../../features/pdf/pdf_to_image/data/repositories/pdf_to_image_repository_impl.dart'
    as _i850;
import '../../features/pdf/pdf_to_image/domain/repositories/pdf_to_image_repository.dart'
    as _i114;
import '../../features/pdf/pdf_to_image/domain/services/pdf_export_dialogs.dart'
    as _i406;
import '../../features/pdf/pdf_to_image/domain/usecases/cancel_conversion_usecase.dart'
    as _i796;
import '../../features/pdf/pdf_to_image/domain/usecases/convert_pdf_to_images_usecase.dart'
    as _i45;
import '../../features/pdf/pdf_to_image/domain/usecases/release_pdf_conversion_usecase.dart'
    as _i386;
import '../../features/pdf/pdf_to_image/domain/usecases/save_as_separate_zips_usecase.dart'
    as _i719;
import '../../features/pdf/pdf_to_image/domain/usecases/save_as_zip_usecase.dart'
    as _i423;
import '../../features/pdf/pdf_to_image/domain/usecases/save_images_usecase.dart'
    as _i849;
import '../../features/pdf/pdf_to_image/presentation/bloc/pdf_to_image_bloc.dart'
    as _i296;
import '../../features/pdf/shared/data/pdfium/pdfium_runtime.dart' as _i526;
import '../../features/settings/data/repositories/settings_repository_impl.dart'
    as _i955;
import '../../features/settings/domain/repositories/settings_repository.dart'
    as _i674;
import '../../features/settings/presentation/cubit/settings_cubit.dart'
    as _i792;
import 'pdf_merge_module.dart' as _i442;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    final pdfMergeModule = _$PdfMergeModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.factory<_i725.GhostscriptCompressionService>(
      () => _i725.GhostscriptCompressionService(),
    );
    gh.lazySingleton<_i378.QpdfRuntimeLocator>(
      () => _i378.QpdfRuntimeLocator(),
    );
    gh.lazySingleton<_i526.PdfiumRuntimeLocator>(
      () => _i526.PdfiumRuntimeLocator(),
    );
    gh.lazySingleton<_i731.PdfiumConversionService>(
      () => _i731.PdfiumConversionService(gh<_i526.PdfiumRuntimeLocator>()),
    );
    gh.lazySingleton<_i569.ImageWorkspaceRepository>(
      () => _i399.ImageWorkspaceRepositoryImpl(),
    );
    gh.factory<_i1007.PdfMergeDesktopGateway>(
      () => _i1013.PdfMergeDesktopGatewayImpl(),
    );
    gh.lazySingleton<_i457.PdfCompressionRepository>(
      () => _i561.PdfCompressionRepositoryImpl(),
    );
    gh.lazySingleton<_i347.PdfRepository>(() => _i1022.PdfRepositoryImpl());
    gh.factory<_i406.PdfExportDialogs>(() => _i298.PdfExportDialogsImpl());
    gh.factory<_i968.ImageDesktopGateway>(
      () => _i386.LocalImageDesktopGateway(),
    );
    gh.lazySingleton<_i495.LocalImageDataSource>(
      () => _i220.LocalImageDataSourceImpl(),
    );
    gh.lazySingleton<_i1058.ImageWorkspaceUseCase>(
      () => _i1058.ImageWorkspaceUseCase(gh<_i569.ImageWorkspaceRepository>()),
    );
    gh.lazySingleton<_i674.SettingsRepository>(
      () => _i955.SettingsRepositoryImpl(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i114.PdfToImageRepository>(
      () => _i850.PdfToImageRepositoryImpl(gh<_i731.PdfiumConversionService>()),
    );
    gh.factory<_i263.CompressPdfUseCase>(
      () => _i263.CompressPdfUseCase(gh<_i457.PdfCompressionRepository>()),
    );
    gh.factory<_i400.PdfCompressionCubit>(
      () => _i400.PdfCompressionCubit(gh<_i263.CompressPdfUseCase>()),
    );
    gh.factory<_i0.PdfMergePreviewService>(
      () => _i0.PdfMergePreviewService(gh<_i526.PdfiumRuntimeLocator>()),
    );
    gh.lazySingleton<_i280.ImageRepository>(
      () => _i246.ImageRepositoryImpl(gh<_i495.LocalImageDataSource>()),
    );
    gh.factory<_i286.QpdfProcessRunner>(
      () => _i286.QpdfProcessRunner(gh<_i378.QpdfRuntimeLocator>()),
    );
    gh.factory<_i796.GeneratePdfUseCase>(
      () => _i796.GeneratePdfUseCase(gh<_i347.PdfRepository>()),
    );
    gh.factory<_i1023.PdfConverterCubit>(
      () => _i1023.PdfConverterCubit(gh<_i796.GeneratePdfUseCase>()),
    );
    gh.factory<_i862.ImageDesktopUseCase>(
      () => _i862.ImageDesktopUseCase(gh<_i968.ImageDesktopGateway>()),
    );
    gh.factory<_i719.SaveAsSeparateZipsUseCase>(
      () => _i719.SaveAsSeparateZipsUseCase(gh<_i114.PdfToImageRepository>()),
    );
    gh.factory<_i423.SaveAsZipUseCase>(
      () => _i423.SaveAsZipUseCase(gh<_i114.PdfToImageRepository>()),
    );
    gh.factory<_i530.PdfMergeRepository>(
      () => _i693.PdfMergeRepositoryImpl(
        gh<_i286.QpdfProcessRunner>(),
        gh<_i0.PdfMergePreviewService>(),
      ),
    );
    gh.factory<_i45.ConvertPdfToImagesUseCase>(
      () => _i45.ConvertPdfToImagesUseCase(gh<_i114.PdfToImageRepository>()),
    );
    gh.factory<_i386.ReleasePdfConversionUseCase>(
      () => _i386.ReleasePdfConversionUseCase(gh<_i114.PdfToImageRepository>()),
    );
    gh.factory<_i849.SaveImagesUseCase>(
      () => _i849.SaveImagesUseCase(gh<_i114.PdfToImageRepository>()),
    );
    gh.lazySingleton<_i796.CancelConversionUseCase>(
      () => _i796.CancelConversionUseCase(gh<_i114.PdfToImageRepository>()),
    );
    gh.factory<_i296.PdfToImageBloc>(
      () => _i296.PdfToImageBloc(
        gh<_i45.ConvertPdfToImagesUseCase>(),
        gh<_i849.SaveImagesUseCase>(),
        gh<_i423.SaveAsZipUseCase>(),
        gh<_i719.SaveAsSeparateZipsUseCase>(),
        gh<_i796.CancelConversionUseCase>(),
        gh<_i386.ReleasePdfConversionUseCase>(),
        gh<_i406.PdfExportDialogs>(),
      ),
    );
    gh.factory<_i792.SettingsCubit>(
      () => _i792.SettingsCubit(gh<_i674.SettingsRepository>()),
    );
    gh.lazySingleton<_i444.PreviewImageUseCase>(
      () => _i444.PreviewImageUseCase(gh<_i280.ImageRepository>()),
    );
    gh.lazySingleton<_i510.ProcessImageUseCase>(
      () => _i510.ProcessImageUseCase(gh<_i280.ImageRepository>()),
    );
    gh.lazySingleton<_i89.CompressImageUseCase>(
      () => _i89.CompressImageUseCase(gh<_i510.ProcessImageUseCase>()),
    );
    gh.lazySingleton<_i750.ConvertImageUseCase>(
      () => _i750.ConvertImageUseCase(gh<_i510.ProcessImageUseCase>()),
    );
    gh.factory<_i515.PdfMergeBloc>(
      () => pdfMergeModule.createPdfMergeBloc(
        gh<_i530.PdfMergeRepository>(),
        gh<_i1007.PdfMergeDesktopGateway>(),
      ),
    );
    gh.factory<_i743.ImageCubit>(
      () => _i743.ImageCubit(
        gh<_i510.ProcessImageUseCase>(),
        gh<_i750.ConvertImageUseCase>(),
        gh<_i89.CompressImageUseCase>(),
        gh<_i444.PreviewImageUseCase>(),
        gh<_i862.ImageDesktopUseCase>(),
        gh<_i1058.ImageWorkspaceUseCase>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}

class _$PdfMergeModule extends _i442.PdfMergeModule {}
