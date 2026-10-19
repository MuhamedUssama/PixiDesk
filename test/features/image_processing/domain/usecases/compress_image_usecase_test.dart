import 'package:flutter_test/flutter_test.dart';
import 'package:pixi_desk/features/image_processing/domain/entities/image_failure.dart';
import 'package:pixi_desk/features/image_processing/domain/entities/image_job.dart';
import 'package:pixi_desk/features/image_processing/domain/entities/image_recipe.dart';
import 'package:pixi_desk/features/image_processing/domain/usecases/process_image_usecase.dart';
import 'package:pixi_desk/features/image_processing/domain/usecases/compress_image_usecase.dart';
import '../../support/fakes.dart';

void main() {
  test(
    'compression requests a smaller result while preserving explicit policy',
    () async {
      final repo = FakeImageRepository();
      final usecase = CompressImageUseCase(ProcessImageUseCase(repo));
      const recipe = ImageRecipe(width: 60, metadata: MetadataPolicy.remove);
      await usecase(
        ImageRequest(
          source: asset('/a.png'),
          recipe: recipe,
          destinationPath: '/output.png',
          conflict: OutputConflict.skip,
        ),
        ImageCancellation(),
      );
      expect(repo.requests.single.keepSmaller, isTrue);
      expect(repo.requests.single.recipe, recipe);
      expect(repo.requests.single.conflict, OutputConflict.skip);
    },
  );
}
