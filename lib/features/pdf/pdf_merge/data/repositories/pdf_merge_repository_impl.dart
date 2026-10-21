import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../../domain/entities/pdf_merge_document.dart';
import '../../domain/entities/pdf_merge_event.dart';
import '../../domain/entities/pdf_merge_failure.dart';
import '../../domain/entities/pdf_merge_request.dart';
import '../../domain/repositories/pdf_merge_repository.dart';
import '../services/pdf_merge_preview_service.dart';
import '../services/qpdf_process_runner.dart';

@Injectable(as: PdfMergeRepository)
class PdfMergeRepositoryImpl implements PdfMergeRepository {
  final QpdfProcessRunner _runner;
  final PdfMergePreviewService _previews;
  final Map<String, String> _passwords = {};
  final Map<String, PdfMergeDocument> _documents = {};
  bool _closed = false;
  bool _merging = false;
  Object? _activeToken;
  int _generation = 0;
  int _previewGeneration = 0;
  Future<void>? _activeMerge;
  PdfMergeRepositoryImpl(this._runner, this._previews);

  @override
  Future<PdfMergeDocument> inspect(
    String sourcePath, {
    String? password,
  }) async {
    final generation = _generation;
    try {
      if (_closed || _merging) {
        throw const PdfMergeFailure(PdfMergeFailureCode.busy);
      }
      final source = File(await File(sourcePath).resolveSymbolicLinks());
      final before = await source.stat();
      if (before.type != FileSystemEntityType.file || before.size < 1) {
        throw const PdfMergeFailure(PdfMergeFailureCode.invalidDocument);
      }
      if (before.size > 512 * 1024 * 1024) {
        throw const PdfMergeFailure(PdfMergeFailureCode.resourceLimit);
      }
      final output = await _runner.run({
        'inputFile': source.path,
        'json': '2',
        'jsonKey': ['pages', 'acroform', 'encrypt'],
        if (password != null) 'password': password,
      });
      final metadata = await Isolate.run(
        () => jsonDecode(output) as Map<String, dynamic>,
      );
      final pages = metadata['pages'] as List;
      if (pages.isEmpty || pages.length > 20000) {
        throw const PdfMergeFailure(PdfMergeFailureCode.resourceLimit);
      }
      if ((metadata['acroform'] as Map)['hasacroform'] == true) {
        throw const PdfMergeFailure(PdfMergeFailureCode.unsupportedDocument);
      }
      final encryption = metadata['encrypt'] as Map;
      if (encryption['encrypted'] == true &&
          encryption['ownerpasswordmatched'] != true &&
          (encryption['capabilities'] as Map)['modifyassembly'] != true) {
        throw const PdfMergeFailure(PdfMergeFailureCode.sourceProtected);
      }
      final after = await source.stat();
      if (before.modified != after.modified ||
          before.changed != after.changed ||
          before.size != after.size) {
        throw const PdfMergeFailure(PdfMergeFailureCode.sourceChanged);
      }
      if (_closed || generation != _generation) {
        throw const PdfMergeFailure(PdfMergeFailureCode.cancelled);
      }
      final document = PdfMergeDocument(
        id: const Uuid().v4(),
        path: source.path,
        displayName: path.basename(source.path),
        pageCount: pages.length,
        sizeBytes: before.size,
        modifiedMicroseconds: before.modified.microsecondsSinceEpoch,
        changedMicroseconds: before.changed.microsecondsSinceEpoch,
        isEncrypted: encryption['encrypted'] == true,
        selectedPages: List.generate(pages.length, (index) => index),
      );
      _documents[document.id] = document;
      if (password != null) _passwords[document.id] = password;
      return document;
    } on PdfMergeFailure {
      rethrow;
    } on FileSystemException {
      throw const PdfMergeFailure(PdfMergeFailureCode.permissionDenied);
    } catch (_) {
      throw const PdfMergeFailure(PdfMergeFailureCode.invalidDocument);
    }
  }

  @override
  Stream<PdfMergeEvent> merge(PdfMergeRequest request) {
    late final StreamController<PdfMergeEvent> controller;
    var ownsJob = false;
    final token = Object();
    controller = StreamController<PdfMergeEvent>(
      onListen: () {
        if (_closed || _merging) {
          controller.addError(const PdfMergeFailure(PdfMergeFailureCode.busy));
          unawaited(controller.close());
          return;
        }
        ownsJob = true;
        _activeToken = token;
        _merging = true;
        _activeMerge = _execute(request, controller);
      },
      onCancel: () async {
        if (ownsJob && _merging && identical(_activeToken, token)) {
          await cancel();
        }
      },
    );
    return controller.stream;
  }

  Future<void> _execute(
    PdfMergeRequest request,
    StreamController<PdfMergeEvent> controller,
  ) async {
    final generation = _generation;
    Directory? stagingDirectory;
    File? reservation;
    var published = false;
    void checkCancelled() {
      if (_closed || generation != _generation) {
        throw const PdfMergeFailure(PdfMergeFailureCode.cancelled);
      }
    }

    try {
      request.validate();
      controller.add(const PdfMergeProgress(PdfMergeStage.preparing));
      await _previews.cancel();
      checkCancelled();
      final activeDocuments = request.documents
          .where((document) => document.selectedPages.isNotEmpty)
          .toList();
      for (final document in activeDocuments) {
        _assertOwned(document);
        await _assertUnchanged(document);
      }
      final destination = File(
        request.destinationPath.toLowerCase().endsWith('.pdf')
            ? request.destinationPath
            : '${request.destinationPath}.pdf',
      ).absolute;
      final parent = await destination.parent.resolveSymbolicLinks();
      final canonicalDestination = path.join(
        parent,
        path.basename(destination.path),
      );
      for (final document in request.documents) {
        if (path.equals(
              path.normalize(document.path),
              path.normalize(canonicalDestination),
            ) ||
            (await destination.exists() &&
                await FileSystemEntity.identical(
                  document.path,
                  destination.path,
                ))) {
          throw const PdfMergeFailure(PdfMergeFailureCode.sourceProtected);
        }
      }
      if (await FileSystemEntity.type(
            canonicalDestination,
            followLinks: false,
          ) !=
          FileSystemEntityType.notFound) {
        throw const PdfMergeFailure(PdfMergeFailureCode.destinationConflict);
      }
      stagingDirectory = await Directory(parent).createTemp('.pixidesk-merge-');
      final staged = File(path.join(stagingDirectory.path, 'merged.pdf'));
      final rotations = <int, List<int>>{};
      var outputPage = 0;
      for (final document in activeDocuments) {
        for (final sourcePage in document.selectedPages) {
          outputPage++;
          final rotation = document.rotations[sourcePage] ?? 0;
          if (rotation != 0) (rotations[rotation] ??= []).add(outputPage);
        }
      }
      checkCancelled();
      controller.add(const PdfMergeProgress(PdfMergeStage.merging));
      await _runner.run(
        {
          'empty': '',
          'outputFile': staged.path,
          'streamData': 'preserve',
          'progress': '',
          'pages': [
            for (final document in activeDocuments)
              {
                'file': document.path,
                'range': document.selectedPages
                    .map((page) => page + 1)
                    .join(','),
                if (_passwords[document.id] case final password?)
                  'password': password,
              },
          ],
          if (rotations.isNotEmpty)
            'rotate': [
              for (final entry in rotations.entries)
                '+${entry.key * 90}:${entry.value.join(',')}',
            ],
        },
        timeout: const Duration(minutes: 30),
        onProgress: (fraction) {
          if (!_closed && generation == _generation) {
            controller.add(
              PdfMergeProgress(PdfMergeStage.merging, fraction: fraction),
            );
          }
        },
      );
      checkCancelled();
      controller.add(const PdfMergeProgress(PdfMergeStage.validating));
      final count = int.tryParse(
        (await _runner.run({
          'inputFile': staged.path,
          'showNpages': '',
        })).trim(),
      );
      if (count != request.totalPages ||
          !await staged.exists() ||
          await staged.length() == 0) {
        throw const PdfMergeFailure(PdfMergeFailureCode.mergeFailed);
      }
      for (final document in activeDocuments) {
        await _assertUnchanged(document);
      }
      checkCancelled();
      controller.add(const PdfMergeProgress(PdfMergeStage.saving));
      try {
        reservation = await File(canonicalDestination).create(exclusive: true);
      } on FileSystemException {
        if (await FileSystemEntity.type(
              canonicalDestination,
              followLinks: false,
            ) !=
            FileSystemEntityType.notFound) {
          throw const PdfMergeFailure(PdfMergeFailureCode.destinationConflict);
        }
        rethrow;
      }
      checkCancelled();
      final output = await staged.rename(canonicalDestination);
      published = true;
      controller.add(
        PdfMergeCompleted(
          PdfMergeResult(
            path: output.path,
            pageCount: count!,
            sizeBytes: await output.length(),
          ),
        ),
      );
    } catch (error, stack) {
      controller.addError(
        error is PdfMergeFailure
            ? error
            : PdfMergeFailure(
                error is FileSystemException
                    ? PdfMergeFailureCode.permissionDenied
                    : PdfMergeFailureCode.mergeFailed,
              ),
        stack,
      );
    } finally {
      try {
        if (!published && reservation != null && await reservation.exists()) {
          await reservation.delete();
        }
        if (stagingDirectory != null && await stagingDirectory.exists()) {
          await stagingDirectory.delete(recursive: true);
        }
      } on FileSystemException {
        // Cleanup is best effort if the filesystem disappears or permissions
        // change. It must never strand the stream or replace its typed result.
      } finally {
        _activeToken = null;
        _merging = false;
        unawaited(controller.close());
      }
    }
  }

  void _assertOwned(PdfMergeDocument document) {
    final original = _documents[document.id];
    if (original == null ||
        original.path != document.path ||
        original.pageCount != document.pageCount ||
        original.sizeBytes != document.sizeBytes ||
        original.modifiedMicroseconds != document.modifiedMicroseconds ||
        original.changedMicroseconds != document.changedMicroseconds ||
        original.isEncrypted != document.isEncrypted) {
      throw const PdfMergeFailure(PdfMergeFailureCode.sourceChanged);
    }
  }

  Future<void> _assertUnchanged(PdfMergeDocument document) async {
    final metadata = await File(document.path).stat();
    if (metadata.type != FileSystemEntityType.file ||
        metadata.size != document.sizeBytes ||
        metadata.modified.microsecondsSinceEpoch !=
            document.modifiedMicroseconds ||
        metadata.changed.microsecondsSinceEpoch !=
            document.changedMicroseconds) {
      throw const PdfMergeFailure(PdfMergeFailureCode.sourceChanged);
    }
  }

  @override
  Future<String> preview(PdfMergeDocument document, int pageIndex) async {
    final generation = ++_previewGeneration;
    if (_closed || _merging) {
      throw const PdfMergeFailure(PdfMergeFailureCode.busy);
    }
    _assertOwned(document);
    await _assertUnchanged(document);
    if (_closed || _merging || generation != _previewGeneration) {
      throw const PdfMergeFailure(PdfMergeFailureCode.cancelled);
    }
    return _previews.render(document, pageIndex, _passwords[document.id]);
  }

  @override
  Future<void> forget(String documentId) async {
    _documents.remove(documentId);
    _passwords.remove(documentId);
  }

  @override
  Future<void> cancel() async {
    _generation++;
    _previewGeneration++;
    final active = _activeMerge;
    await Future.wait([_runner.cancel(), _previews.cancel()]);
    await active;
  }

  @override
  Future<void> dispose() async {
    _closed = true;
    await cancel();
    await _activeMerge;
    _documents.clear();
    _passwords.clear();
    await _previews.dispose();
  }
}
