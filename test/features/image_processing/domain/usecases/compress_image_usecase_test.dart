import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pixi_desk/features/image_processing/domain/repositories/image_repository.dart';
import 'package:pixi_desk/features/image_processing/domain/usecases/compress_image_usecase.dart';

class MockImageRepository extends Mock implements ImageRepository {}

class FakeFile extends Fake implements File {}

void main() {
  late CompressImageUseCase useCase;
  late MockImageRepository mockRepository;

  setUp(() {
    mockRepository = MockImageRepository();
    useCase = CompressImageUseCase(mockRepository);
    registerFallbackValue(FakeFile());
  });

  final tImage = File('test_image.png');
  final tQuality = 80;
  final tDestinationPath = 'test_path_compressed.png';
  final tResultFile = File('test_path_compressed.png');

  test(
    'should call compressImage on repository with correct parameters',
    () async {
      // Arrange
      when(
        () => mockRepository.compressImage(
          image: any(named: 'image'),
          quality: any(named: 'quality'),
          destinationPath: any(named: 'destinationPath'),
        ),
      ).thenAnswer((_) async => tResultFile);

      // Act
      final result = await useCase(
        image: tImage,
        quality: tQuality,
        destinationPath: tDestinationPath,
      );

      // Assert
      expect(result, tResultFile);
      verify(
        () => mockRepository.compressImage(
          image: tImage,
          quality: tQuality,
          destinationPath: tDestinationPath,
        ),
      ).called(1);
    },
  );
}
