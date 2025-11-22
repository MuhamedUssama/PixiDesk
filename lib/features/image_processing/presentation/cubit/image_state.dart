import 'package:equatable/equatable.dart';
import '../../domain/entities/image_entity.dart';
import '../../domain/entities/image_format.dart';

enum ImageStatus { initial, loading, success, error }

class ImageState extends Equatable {
  final ImageStatus status;
  final ImageEntity? selectedImage;
  final ImageFormat? targetFormat;
  final int quality;
  final String? errorMessage;
  final String? successMessage;

  const ImageState({
    this.status = ImageStatus.initial,
    this.selectedImage,
    this.targetFormat,
    this.quality = 80,
    this.errorMessage,
    this.successMessage,
  });

  ImageState copyWith({
    ImageStatus? status,
    ImageEntity? selectedImage,
    ImageFormat? targetFormat,
    int? quality,
    String? errorMessage,
    String? successMessage,
  }) {
    return ImageState(
      status: status ?? this.status,
      selectedImage: selectedImage ?? this.selectedImage,
      targetFormat: targetFormat ?? this.targetFormat,
      quality: quality ?? this.quality,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    selectedImage,
    targetFormat,
    quality,
    errorMessage,
    successMessage,
  ];
}
