// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pdf_to_image_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PdfToImageState {

 PdfToImageStatus get status; List<File> get selectedFiles; String get outputFormat; int get dpi; ConversionProgress? get progress; List<File>? get generatedImages; PdfConversionFailureCode? get failure; PdfExportSuccess? get success; int get messageId; Map<String, String> get previewPaths; Map<String, String> get thumbnailPaths; Set<String> get selectedImagePaths; Map<String, int> get imageRotations; Map<String, List<File>> get groupedImages;
/// Create a copy of PdfToImageState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PdfToImageStateCopyWith<PdfToImageState> get copyWith => _$PdfToImageStateCopyWithImpl<PdfToImageState>(this as PdfToImageState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PdfToImageState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.selectedFiles, selectedFiles)&&(identical(other.outputFormat, outputFormat) || other.outputFormat == outputFormat)&&(identical(other.dpi, dpi) || other.dpi == dpi)&&(identical(other.progress, progress) || other.progress == progress)&&const DeepCollectionEquality().equals(other.generatedImages, generatedImages)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.success, success) || other.success == success)&&(identical(other.messageId, messageId) || other.messageId == messageId)&&const DeepCollectionEquality().equals(other.previewPaths, previewPaths)&&const DeepCollectionEquality().equals(other.thumbnailPaths, thumbnailPaths)&&const DeepCollectionEquality().equals(other.selectedImagePaths, selectedImagePaths)&&const DeepCollectionEquality().equals(other.imageRotations, imageRotations)&&const DeepCollectionEquality().equals(other.groupedImages, groupedImages));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(selectedFiles),outputFormat,dpi,progress,const DeepCollectionEquality().hash(generatedImages),failure,success,messageId,const DeepCollectionEquality().hash(previewPaths),const DeepCollectionEquality().hash(thumbnailPaths),const DeepCollectionEquality().hash(selectedImagePaths),const DeepCollectionEquality().hash(imageRotations),const DeepCollectionEquality().hash(groupedImages));

@override
String toString() {
  return 'PdfToImageState(status: $status, selectedFiles: $selectedFiles, outputFormat: $outputFormat, dpi: $dpi, progress: $progress, generatedImages: $generatedImages, failure: $failure, success: $success, messageId: $messageId, previewPaths: $previewPaths, thumbnailPaths: $thumbnailPaths, selectedImagePaths: $selectedImagePaths, imageRotations: $imageRotations, groupedImages: $groupedImages)';
}


}

/// @nodoc
abstract mixin class $PdfToImageStateCopyWith<$Res>  {
  factory $PdfToImageStateCopyWith(PdfToImageState value, $Res Function(PdfToImageState) _then) = _$PdfToImageStateCopyWithImpl;
@useResult
$Res call({
 PdfToImageStatus status, List<File> selectedFiles, String outputFormat, int dpi, ConversionProgress? progress, List<File>? generatedImages, PdfConversionFailureCode? failure, PdfExportSuccess? success, int messageId, Map<String, String> previewPaths, Map<String, String> thumbnailPaths, Set<String> selectedImagePaths, Map<String, int> imageRotations, Map<String, List<File>> groupedImages
});




}
/// @nodoc
class _$PdfToImageStateCopyWithImpl<$Res>
    implements $PdfToImageStateCopyWith<$Res> {
  _$PdfToImageStateCopyWithImpl(this._self, this._then);

  final PdfToImageState _self;
  final $Res Function(PdfToImageState) _then;

/// Create a copy of PdfToImageState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? selectedFiles = null,Object? outputFormat = null,Object? dpi = null,Object? progress = freezed,Object? generatedImages = freezed,Object? failure = freezed,Object? success = freezed,Object? messageId = null,Object? previewPaths = null,Object? thumbnailPaths = null,Object? selectedImagePaths = null,Object? imageRotations = null,Object? groupedImages = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PdfToImageStatus,selectedFiles: null == selectedFiles ? _self.selectedFiles : selectedFiles // ignore: cast_nullable_to_non_nullable
as List<File>,outputFormat: null == outputFormat ? _self.outputFormat : outputFormat // ignore: cast_nullable_to_non_nullable
as String,dpi: null == dpi ? _self.dpi : dpi // ignore: cast_nullable_to_non_nullable
as int,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as ConversionProgress?,generatedImages: freezed == generatedImages ? _self.generatedImages : generatedImages // ignore: cast_nullable_to_non_nullable
as List<File>?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as PdfConversionFailureCode?,success: freezed == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as PdfExportSuccess?,messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as int,previewPaths: null == previewPaths ? _self.previewPaths : previewPaths // ignore: cast_nullable_to_non_nullable
as Map<String, String>,thumbnailPaths: null == thumbnailPaths ? _self.thumbnailPaths : thumbnailPaths // ignore: cast_nullable_to_non_nullable
as Map<String, String>,selectedImagePaths: null == selectedImagePaths ? _self.selectedImagePaths : selectedImagePaths // ignore: cast_nullable_to_non_nullable
as Set<String>,imageRotations: null == imageRotations ? _self.imageRotations : imageRotations // ignore: cast_nullable_to_non_nullable
as Map<String, int>,groupedImages: null == groupedImages ? _self.groupedImages : groupedImages // ignore: cast_nullable_to_non_nullable
as Map<String, List<File>>,
  ));
}

}


/// Adds pattern-matching-related methods to [PdfToImageState].
extension PdfToImageStatePatterns on PdfToImageState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PdfToImageState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PdfToImageState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PdfToImageState value)  $default,){
final _that = this;
switch (_that) {
case _PdfToImageState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PdfToImageState value)?  $default,){
final _that = this;
switch (_that) {
case _PdfToImageState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PdfToImageStatus status,  List<File> selectedFiles,  String outputFormat,  int dpi,  ConversionProgress? progress,  List<File>? generatedImages,  PdfConversionFailureCode? failure,  PdfExportSuccess? success,  int messageId,  Map<String, String> previewPaths,  Map<String, String> thumbnailPaths,  Set<String> selectedImagePaths,  Map<String, int> imageRotations,  Map<String, List<File>> groupedImages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PdfToImageState() when $default != null:
return $default(_that.status,_that.selectedFiles,_that.outputFormat,_that.dpi,_that.progress,_that.generatedImages,_that.failure,_that.success,_that.messageId,_that.previewPaths,_that.thumbnailPaths,_that.selectedImagePaths,_that.imageRotations,_that.groupedImages);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PdfToImageStatus status,  List<File> selectedFiles,  String outputFormat,  int dpi,  ConversionProgress? progress,  List<File>? generatedImages,  PdfConversionFailureCode? failure,  PdfExportSuccess? success,  int messageId,  Map<String, String> previewPaths,  Map<String, String> thumbnailPaths,  Set<String> selectedImagePaths,  Map<String, int> imageRotations,  Map<String, List<File>> groupedImages)  $default,) {final _that = this;
switch (_that) {
case _PdfToImageState():
return $default(_that.status,_that.selectedFiles,_that.outputFormat,_that.dpi,_that.progress,_that.generatedImages,_that.failure,_that.success,_that.messageId,_that.previewPaths,_that.thumbnailPaths,_that.selectedImagePaths,_that.imageRotations,_that.groupedImages);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PdfToImageStatus status,  List<File> selectedFiles,  String outputFormat,  int dpi,  ConversionProgress? progress,  List<File>? generatedImages,  PdfConversionFailureCode? failure,  PdfExportSuccess? success,  int messageId,  Map<String, String> previewPaths,  Map<String, String> thumbnailPaths,  Set<String> selectedImagePaths,  Map<String, int> imageRotations,  Map<String, List<File>> groupedImages)?  $default,) {final _that = this;
switch (_that) {
case _PdfToImageState() when $default != null:
return $default(_that.status,_that.selectedFiles,_that.outputFormat,_that.dpi,_that.progress,_that.generatedImages,_that.failure,_that.success,_that.messageId,_that.previewPaths,_that.thumbnailPaths,_that.selectedImagePaths,_that.imageRotations,_that.groupedImages);case _:
  return null;

}
}

}

/// @nodoc


class _PdfToImageState extends PdfToImageState {
  const _PdfToImageState({this.status = PdfToImageStatus.initial, final  List<File> selectedFiles = const [], this.outputFormat = 'jpg', this.dpi = 150, this.progress, final  List<File>? generatedImages, this.failure, this.success, this.messageId = 0, final  Map<String, String> previewPaths = const {}, final  Map<String, String> thumbnailPaths = const {}, final  Set<String> selectedImagePaths = const {}, final  Map<String, int> imageRotations = const {}, final  Map<String, List<File>> groupedImages = const {}}): _selectedFiles = selectedFiles,_generatedImages = generatedImages,_previewPaths = previewPaths,_thumbnailPaths = thumbnailPaths,_selectedImagePaths = selectedImagePaths,_imageRotations = imageRotations,_groupedImages = groupedImages,super._();


@override@JsonKey() final  PdfToImageStatus status;
 final  List<File> _selectedFiles;
@override@JsonKey() List<File> get selectedFiles {
  if (_selectedFiles is EqualUnmodifiableListView) return _selectedFiles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedFiles);
}

@override@JsonKey() final  String outputFormat;
@override@JsonKey() final  int dpi;
@override final  ConversionProgress? progress;
 final  List<File>? _generatedImages;
@override List<File>? get generatedImages {
  final value = _generatedImages;
  if (value == null) return null;
  if (_generatedImages is EqualUnmodifiableListView) return _generatedImages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  PdfConversionFailureCode? failure;
@override final  PdfExportSuccess? success;
@override@JsonKey() final  int messageId;
 final  Map<String, String> _previewPaths;
@override@JsonKey() Map<String, String> get previewPaths {
  if (_previewPaths is EqualUnmodifiableMapView) return _previewPaths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_previewPaths);
}

 final  Map<String, String> _thumbnailPaths;
@override@JsonKey() Map<String, String> get thumbnailPaths {
  if (_thumbnailPaths is EqualUnmodifiableMapView) return _thumbnailPaths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_thumbnailPaths);
}

 final  Set<String> _selectedImagePaths;
@override@JsonKey() Set<String> get selectedImagePaths {
  if (_selectedImagePaths is EqualUnmodifiableSetView) return _selectedImagePaths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_selectedImagePaths);
}

 final  Map<String, int> _imageRotations;
@override@JsonKey() Map<String, int> get imageRotations {
  if (_imageRotations is EqualUnmodifiableMapView) return _imageRotations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_imageRotations);
}

 final  Map<String, List<File>> _groupedImages;
@override@JsonKey() Map<String, List<File>> get groupedImages {
  if (_groupedImages is EqualUnmodifiableMapView) return _groupedImages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_groupedImages);
}


/// Create a copy of PdfToImageState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PdfToImageStateCopyWith<_PdfToImageState> get copyWith => __$PdfToImageStateCopyWithImpl<_PdfToImageState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PdfToImageState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._selectedFiles, _selectedFiles)&&(identical(other.outputFormat, outputFormat) || other.outputFormat == outputFormat)&&(identical(other.dpi, dpi) || other.dpi == dpi)&&(identical(other.progress, progress) || other.progress == progress)&&const DeepCollectionEquality().equals(other._generatedImages, _generatedImages)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.success, success) || other.success == success)&&(identical(other.messageId, messageId) || other.messageId == messageId)&&const DeepCollectionEquality().equals(other._previewPaths, _previewPaths)&&const DeepCollectionEquality().equals(other._thumbnailPaths, _thumbnailPaths)&&const DeepCollectionEquality().equals(other._selectedImagePaths, _selectedImagePaths)&&const DeepCollectionEquality().equals(other._imageRotations, _imageRotations)&&const DeepCollectionEquality().equals(other._groupedImages, _groupedImages));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_selectedFiles),outputFormat,dpi,progress,const DeepCollectionEquality().hash(_generatedImages),failure,success,messageId,const DeepCollectionEquality().hash(_previewPaths),const DeepCollectionEquality().hash(_thumbnailPaths),const DeepCollectionEquality().hash(_selectedImagePaths),const DeepCollectionEquality().hash(_imageRotations),const DeepCollectionEquality().hash(_groupedImages));

@override
String toString() {
  return 'PdfToImageState(status: $status, selectedFiles: $selectedFiles, outputFormat: $outputFormat, dpi: $dpi, progress: $progress, generatedImages: $generatedImages, failure: $failure, success: $success, messageId: $messageId, previewPaths: $previewPaths, thumbnailPaths: $thumbnailPaths, selectedImagePaths: $selectedImagePaths, imageRotations: $imageRotations, groupedImages: $groupedImages)';
}


}

/// @nodoc
abstract mixin class _$PdfToImageStateCopyWith<$Res> implements $PdfToImageStateCopyWith<$Res> {
  factory _$PdfToImageStateCopyWith(_PdfToImageState value, $Res Function(_PdfToImageState) _then) = __$PdfToImageStateCopyWithImpl;
@override @useResult
$Res call({
 PdfToImageStatus status, List<File> selectedFiles, String outputFormat, int dpi, ConversionProgress? progress, List<File>? generatedImages, PdfConversionFailureCode? failure, PdfExportSuccess? success, int messageId, Map<String, String> previewPaths, Map<String, String> thumbnailPaths, Set<String> selectedImagePaths, Map<String, int> imageRotations, Map<String, List<File>> groupedImages
});




}
/// @nodoc
class __$PdfToImageStateCopyWithImpl<$Res>
    implements _$PdfToImageStateCopyWith<$Res> {
  __$PdfToImageStateCopyWithImpl(this._self, this._then);

  final _PdfToImageState _self;
  final $Res Function(_PdfToImageState) _then;

/// Create a copy of PdfToImageState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? selectedFiles = null,Object? outputFormat = null,Object? dpi = null,Object? progress = freezed,Object? generatedImages = freezed,Object? failure = freezed,Object? success = freezed,Object? messageId = null,Object? previewPaths = null,Object? thumbnailPaths = null,Object? selectedImagePaths = null,Object? imageRotations = null,Object? groupedImages = null,}) {
  return _then(_PdfToImageState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PdfToImageStatus,selectedFiles: null == selectedFiles ? _self._selectedFiles : selectedFiles // ignore: cast_nullable_to_non_nullable
as List<File>,outputFormat: null == outputFormat ? _self.outputFormat : outputFormat // ignore: cast_nullable_to_non_nullable
as String,dpi: null == dpi ? _self.dpi : dpi // ignore: cast_nullable_to_non_nullable
as int,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as ConversionProgress?,generatedImages: freezed == generatedImages ? _self._generatedImages : generatedImages // ignore: cast_nullable_to_non_nullable
as List<File>?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as PdfConversionFailureCode?,success: freezed == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as PdfExportSuccess?,messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as int,previewPaths: null == previewPaths ? _self._previewPaths : previewPaths // ignore: cast_nullable_to_non_nullable
as Map<String, String>,thumbnailPaths: null == thumbnailPaths ? _self._thumbnailPaths : thumbnailPaths // ignore: cast_nullable_to_non_nullable
as Map<String, String>,selectedImagePaths: null == selectedImagePaths ? _self._selectedImagePaths : selectedImagePaths // ignore: cast_nullable_to_non_nullable
as Set<String>,imageRotations: null == imageRotations ? _self._imageRotations : imageRotations // ignore: cast_nullable_to_non_nullable
as Map<String, int>,groupedImages: null == groupedImages ? _self._groupedImages : groupedImages // ignore: cast_nullable_to_non_nullable
as Map<String, List<File>>,
  ));
}


}

// dart format on
