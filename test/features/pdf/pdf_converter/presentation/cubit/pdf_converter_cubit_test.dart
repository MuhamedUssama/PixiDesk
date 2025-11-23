import 'dart:io';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pixi_desk/features/pdf/pdf_converter/domain/entities/pdf_image_item.dart';
import 'package:pixi_desk/features/pdf/pdf_converter/domain/usecases/generate_pdf_use_case.dart';
import 'package:pixi_desk/features/pdf/pdf_converter/presentation/cubit/pdf_converter_cubit.dart';
import 'package:pixi_desk/features/pdf/pdf_converter/presentation/cubit/pdf_converter_state.dart';

class MockGeneratePdfUseCase extends Mock implements GeneratePdfUseCase {}

void main() {
  late PdfConverterCubit cubit;
  late MockGeneratePdfUseCase mockGeneratePdfUseCase;

  setUp(() {
    mockGeneratePdfUseCase = MockGeneratePdfUseCase();
    cubit = PdfConverterCubit(mockGeneratePdfUseCase);
  });

  group('PdfConverterCubit Rotation Tests', () {
    final file = File('test.jpg');

    blocTest<PdfConverterCubit, PdfConverterState>(
      'rotateImage increments quarterTurns correctly',
      build: () => cubit,
      act: (cubit) {
        cubit.addImages([file]);
        // Wait for addImages to emit
      },
      seed: () => PdfConverterState(
        images: [PdfImageItem(id: '1', file: file, quarterTurns: 0)],
      ),
      verify: (cubit) {
        cubit.rotateImage('1');
        expect(cubit.state.images.first.quarterTurns, 1);

        cubit.rotateImage('1');
        expect(cubit.state.images.first.quarterTurns, 2);

        cubit.rotateImage('1');
        expect(cubit.state.images.first.quarterTurns, 3);

        cubit.rotateImage('1');
        expect(cubit.state.images.first.quarterTurns, 0);
      },
    );
  });
}
