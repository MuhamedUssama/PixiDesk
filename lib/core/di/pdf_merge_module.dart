import 'package:injectable/injectable.dart';
import '../../features/pdf/pdf_merge/domain/repositories/pdf_merge_repository.dart';
import '../../features/pdf/pdf_merge/domain/services/pdf_merge_desktop_gateway.dart';
import '../../features/pdf/pdf_merge/domain/usecases/pdf_merge_usecases.dart';
import '../../features/pdf/pdf_merge/presentation/bloc/pdf_merge_bloc.dart';

@module
abstract class PdfMergeModule {
  // Every page owns one repository session. Its use cases must share that exact
  // instance so inspected documents, credentials, cancellation and previews have
  // one owner, without leaking a singleton session between open routes.
  PdfMergeBloc createPdfMergeBloc(
    PdfMergeRepository repository,
    PdfMergeDesktopGateway desktop,
  ) => PdfMergeBloc(
    InspectPdfForMergeUseCase(repository),
    MergePdfsUseCase(repository),
    PreviewMergePageUseCase(repository),
    ManagePdfMergeSessionUseCase(repository),
    desktop,
  );
}
