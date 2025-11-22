import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pixi_desk/features/image_processing/domain/entities/image_format.dart';
import 'package:pixi_desk/features/image_processing/domain/repositories/image_repository.dart';
import 'package:pixi_desk/features/image_processing/domain/usecases/convert_image_usecase.dart';

class MockImageRepository extends Mock implements ImageRepository {}

class FakeFile extends Fake implements File {}

void main() {
  late ConvertImageUseCase useCase;
  late MockImageRepository mockRepository;

  setUp(() {
    mockRepository = MockImageRepository();
    useCase = ConvertImageUseCase(mockRepository);
    registerFallbackValue(FakeFile());
    registerFallbackValue(ImageFormat.png);
  });

  final tImage = File('test_image.png');
  final tTargetFormat = ImageFormat.jpg;
  final tDestinationPath = 'test_path.jpg';
  final tResultFile = File('test_path.jpg');

  test(
    'should call convertImage on repository with correct parameters',
    () async {
      // Arrange
      when(
        () => mockRepository.convertImage(
          image: any(named: 'image'),
          targetFormat: any(named: 'targetFormat'),
          destinationPath: any(named: 'destinationPath'),
        ),
      ).thenAnswer((_) async => tResultFile);

      // Act
      final result = await useCase(
        image: tImage,
        targetFormat: tTargetFormat,
        destinationPath: tDestinationPath,
      );

      // Assert
      expect(result, tResultFile);
      verify(
        () => mockRepository.convertImage(
          image: tImage,
          targetFormat: tTargetFormat,
          destinationPath: tDestinationPath,
        ),
      ).called(1);
    },
  );
}
