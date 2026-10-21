import 'package:flutter_test/flutter_test.dart';
import 'package:pixi_desk/features/pdf/pdf_merge/domain/entities/pdf_merge_request.dart';
import 'package:pixi_desk/features/pdf/pdf_merge/domain/entities/pdf_merge_failure.dart';

void main() {
  test(
    'preserves explicit page order, reverse ranges, duplicates and final-page token',
    () {
      expect(parsePdfPageRange('3,1-2,2,5-4', 5), [2, 0, 1, 1, 4, 3]);
      expect(parsePdfPageRange('2-z', 5), [1, 2, 3, 4]);
      expect(parsePdfPageRange('', 3), [0, 1, 2]);
    },
  );
  for (final value in [
    '1' * 200001,
    '0',
    '6',
    '1-9',
    '-1',
    '1,',
    'a',
    '2--3',
    '99999999999999999999999',
  ]) {
    test(
      'rejects invalid page range ${value.length > 30 ? 'oversized input' : value}',
      () => expect(
        () => parsePdfPageRange(value, 5),
        throwsA(isA<PdfMergeFailure>()),
      ),
    );
  }
}
