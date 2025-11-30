import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/data/datasources/poppler_service.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/data/repositories/pdf_to_image_repository_impl.dart';
import 'package:path/path.dart' as path;

class MockPopplerService extends Mock implements PopplerService {}

void main() {
  late PdfToImageRepositoryImpl repository;
  late MockPopplerService mockPopplerService;

  setUp(() {
    mockPopplerService = MockPopplerService();
    repository = PdfToImageRepositoryImpl(mockPopplerService);
  });

  test('saveAsSeparateZips creates zip files for each group', () async {
    final tempDir = await Directory.systemTemp.createTemp('test_repo_');
    final sourceFile1 = File(path.join(tempDir.path, 'doc1.pdf'));
    final sourceFile2 = File(path.join(tempDir.path, 'doc2.pdf'));

    // Create dummy image files
    final img1 = File(path.join(tempDir.path, 'img1.jpg'))..createSync();
    final img2 = File(path.join(tempDir.path, 'img2.jpg'))..createSync();

    final groupedImages = {
      sourceFile1.path: [img1],
      sourceFile2.path: [img2],
    };

    final outputDir = await Directory.systemTemp.createTemp('test_output_');

    await repository.saveAsSeparateZips(groupedImages, outputDir.path);

    final zip1 = File(path.join(outputDir.path, 'doc1.zip'));
    final zip2 = File(path.join(outputDir.path, 'doc2.zip'));

    expect(zip1.existsSync(), isTrue);
    expect(zip2.existsSync(), isTrue);

    // Cleanup
    await tempDir.delete(recursive: true);
    await outputDir.delete(recursive: true);
  });
}
