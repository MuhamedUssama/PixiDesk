import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pixi_desk/features/image_processing/data/datasources/local_image_datasource.dart';
import 'package:pixi_desk/features/image_processing/data/repositories/image_repository_impl.dart';
import 'package:pixi_desk/features/image_processing/domain/entities/image_format.dart';

class MockLocalImageDataSource extends Mock implements LocalImageDataSource {}

class FakeFile extends Fake implements File {}

void main() {
  late ImageRepositoryImpl repository;
  late MockLocalImageDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockLocalImageDataSource();
    repository = ImageRepositoryImpl(mockDataSource);
    registerFallbackValue(FakeFile());
    registerFallbackValue(ImageFormat.png);
  });

  final tImage = File('test.png');
  final tTargetFormat = ImageFormat.jpg;
  final tDestinationPath = 'result.jpg';
  final tResultFile = File('result.jpg');

  group('ImageRepositoryImpl', () {
    test('convertImage should call dataSource.convertImage', () async {
      // Arrange
      when(
        () => mockDataSource.convertImage(
          image: any(named: 'image'),
          targetFormat: any(named: 'targetFormat'),
          destinationPath: any(named: 'destinationPath'),
        ),
      ).thenAnswer((_) async => tResultFile);

      // Act
      final result = await repository.convertImage(
        image: tImage,
        targetFormat: tTargetFormat,
        destinationPath: tDestinationPath,
      );

      // Assert
      expect(result, tResultFile);
      verify(
        () => mockDataSource.convertImage(
          image: tImage,
          targetFormat: tTargetFormat,
          destinationPath: tDestinationPath,
        ),
      ).called(1);
    });

    test('compressImage should call dataSource.compressImage', () async {
      // Arrange
      when(
        () => mockDataSource.compressImage(
          image: any(named: 'image'),
          quality: any(named: 'quality'),
          destinationPath: any(named: 'destinationPath'),
        ),
      ).thenAnswer((_) async => tResultFile);

      // Act
      final result = await repository.compressImage(
        image: tImage,
        quality: 80,
        destinationPath: tDestinationPath,
      );

      // Assert
      expect(result, tResultFile);
      verify(
        () => mockDataSource.compressImage(
          image: tImage,
          quality: 80,
          destinationPath: tDestinationPath,
        ),
      ).called(1);
    });
  });
}
