import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:async/async.dart';
import 'package:injectable/injectable.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/data/datasources/pdf_task_manager.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/data/datasources/poppler_service.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/entities/pdf_to_image_params.dart';
import 'package:pool/pool.dart';

@lazySingleton
class ParallelConversionService {
  final PopplerService _popplerService;
  final PdfTaskManager _taskManager;

  ParallelConversionService(this._popplerService, this._taskManager);

  Future<Stream<dynamic>> convertInParallel(
    List<File> files,
    PdfToImageParams params,
  ) async {
    log('ParallelService: Creating tasks...');
    final tasks = await _taskManager.createTasks(files, params);
    log('ParallelService: Created ${tasks.length} tasks.');

    if (tasks.isEmpty) {
      log('ParallelService: No tasks created. Returning empty stream.');
      return const Stream.empty();
    }

    final workerCount = _taskManager.calculateWorkerCount();
    log('ParallelService: Worker count: $workerCount. Initializing pool...');
    final pool = Pool(workerCount);
    final streams = <Stream<dynamic>>[];

    log('ParallelService: Preparing streams for ${tasks.length} tasks...');
    for (int i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      // Create a controller for this task
      final controller = StreamController<dynamic>();
      streams.add(controller.stream);

      // Start processing in background (fire and forget, but managed by pool)
      _processTask(task, pool, controller, i, tasks.length);
    }

    log('ParallelService: All streams prepared. Merging...');
    return StreamGroup.merge(streams);
  }

  Future<void> _processTask(
    PdfConversionTask task,
    Pool pool,
    StreamController<dynamic> controller,
    int index,
    int total,
  ) async {
    try {
      log(
        'ParallelService: Requesting resource for task ${task.taskId} (${index + 1}/$total)...',
      );
      final resource = await pool.request();
      log('ParallelService: Resource granted for task ${task.taskId}.');

      try {
        final receivePort = ReceivePort();
        final binaryPath = _popplerService.getPopplerBinaryPath('pdftoppm');

        log('ParallelService: Spawning isolate for task ${task.taskId}...');
        await Isolate.spawn(
          parallelIsolateEntryPoint,
          ParallelIsolateParams(
            sendPort: receivePort.sendPort,
            taskId: task.taskId,
            inputFilePath: task.inputFile.path,
            outputFormat: task.params.outputFormat,
            dpi: task.params.dpi,
            startPage: task.startPage,
            endPage: task.endPage,
            binaryPath: binaryPath,
          ),
        );
        log(
          'ParallelService: Isolate spawned for task ${task.taskId}. Listening...',
        );

        // Pipe events from isolate to controller
        await for (final event in receivePort) {
          if (event is Map) {
            if (event['type'] == 'log') {
              log('ParallelService (Isolate): ${event['message']}');
              continue;
            }
            if (event['type'] == 'done') {
              log('ParallelService: Received DONE for task ${task.taskId}.');
              controller.add(event);
              break;
            }
            if (event['type'] == 'error') {
              log(
                'ParallelService: Received ERROR for task ${task.taskId}: ${event['message']}',
              );
              controller.add(event);
              break;
            }
          }
          controller.add(event);
        }
      } catch (e, stack) {
        log('ParallelService: Error in task ${task.taskId}: $e');
        controller.addError(e, stack);
      } finally {
        log('ParallelService: Releasing resource for task ${task.taskId}.');
        resource.release();
        await controller.close();
      }
    } catch (e) {
      // Error requesting resource (unlikely)
      log(
        'ParallelService: Error requesting resource for task ${task.taskId}: $e',
      );
      controller.addError(e);
      await controller.close();
    }
  }
}
