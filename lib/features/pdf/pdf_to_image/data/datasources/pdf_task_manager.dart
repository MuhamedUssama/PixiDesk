import 'dart:io';
import 'dart:math';
import 'package:injectable/injectable.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/data/datasources/poppler_service.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/entities/pdf_to_image_params.dart';
import 'package:uuid/uuid.dart';

class PdfConversionTask {
  final String taskId;
  final File inputFile;
  final int startPage;
  final int endPage;
  final PdfToImageParams params;

  const PdfConversionTask({
    required this.taskId,
    required this.inputFile,
    required this.startPage,
    required this.endPage,
    required this.params,
  });
}

@lazySingleton
class PdfTaskManager {
  final PopplerService _popplerService;
  final Uuid _uuid;

  PdfTaskManager(this._popplerService) : _uuid = const Uuid();

  int calculateWorkerCount() {
    final totalProcessors = Platform.numberOfProcessors;
    // Use ~75% of available cores, ensuring at least 1 worker.
    return max(1, (totalProcessors * 0.75).ceil());
  }

  Future<List<PdfConversionTask>> createTasks(
    List<File> files,
    PdfToImageParams params,
  ) async {
    final workerCount = calculateWorkerCount();
    final tasks = <PdfConversionTask>[];

    // 1. Calculate total pages across all files
    int totalPages = 0;
    final filePageCounts = <File, int>{};

    for (final file in files) {
      final count = await _popplerService.getPageCount(file);
      filePageCounts[file] = count;
      totalPages += count;
    }

    if (totalPages == 0) return [];

    // 2. Calculate target pages per worker
    // We want to distribute the total load roughly evenly among workers.
    // However, we also want to avoid splitting files into tiny chunks if not necessary.
    final pagesPerWorker = (totalPages / workerCount).ceil();

    // 3. Create tasks
    for (final file in files) {
      final pageCount = filePageCounts[file]!;

      // If the file is small enough (relative to the target load), keep it as one task.
      // Or if it's just a single page, definitely one task.
      if (pageCount <= pagesPerWorker) {
        tasks.add(
          PdfConversionTask(
            taskId: _uuid.v4(),
            inputFile: file,
            startPage: 1,
            endPage: pageCount,
            params: params,
          ),
        );
      } else {
        // Split large file into chunks
        // We use the pagesPerWorker as the chunk size to try and utilize all workers.
        // For very large files, this ensures multiple workers can process it in parallel.
        int currentPage = 1;
        while (currentPage <= pageCount) {
          final remainingPages = pageCount - currentPage + 1;
          final chunkSize = min(remainingPages, pagesPerWorker);
          final endPage = currentPage + chunkSize - 1;

          tasks.add(
            PdfConversionTask(
              taskId: _uuid.v4(),
              inputFile: file,
              startPage: currentPage,
              endPage: endPage,
              params: params,
            ),
          );

          currentPage += chunkSize;
        }
      }
    }

    return tasks;
  }
}
