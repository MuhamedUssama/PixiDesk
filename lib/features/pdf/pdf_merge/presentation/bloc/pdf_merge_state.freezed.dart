// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pdf_merge_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PdfMergeState {

 List<PdfMergeDocument> get documents; PdfMergeStatus get status; bool get acknowledgeDocumentChanges; Set<String> get invalidRangeDocumentIds; PdfMergeStage? get stage; double? get progress; PdfMergeResult? get result; PdfMergeFailureCode? get failure; int get messageId; String? get passwordPath; List<String> get pendingImportPaths; String? get previewDocumentId; int get previewPageIndex; String? get previewPath; bool get isPreviewLoading; PdfMergeFailureCode? get previewFailure;
/// Create a copy of PdfMergeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PdfMergeStateCopyWith<PdfMergeState> get copyWith => _$PdfMergeStateCopyWithImpl<PdfMergeState>(this as PdfMergeState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PdfMergeState&&const DeepCollectionEquality().equals(other.documents, documents)&&(identical(other.status, status) || other.status == status)&&(identical(other.acknowledgeDocumentChanges, acknowledgeDocumentChanges) || other.acknowledgeDocumentChanges == acknowledgeDocumentChanges)&&const DeepCollectionEquality().equals(other.invalidRangeDocumentIds, invalidRangeDocumentIds)&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.result, result) || other.result == result)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.passwordPath, passwordPath) || other.passwordPath == passwordPath)&&const DeepCollectionEquality().equals(other.pendingImportPaths, pendingImportPaths)&&(identical(other.previewDocumentId, previewDocumentId) || other.previewDocumentId == previewDocumentId)&&(identical(other.previewPageIndex, previewPageIndex) || other.previewPageIndex == previewPageIndex)&&(identical(other.previewPath, previewPath) || other.previewPath == previewPath)&&(identical(other.isPreviewLoading, isPreviewLoading) || other.isPreviewLoading == isPreviewLoading)&&(identical(other.previewFailure, previewFailure) || other.previewFailure == previewFailure));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(documents),status,acknowledgeDocumentChanges,const DeepCollectionEquality().hash(invalidRangeDocumentIds),stage,progress,result,failure,messageId,passwordPath,const DeepCollectionEquality().hash(pendingImportPaths),previewDocumentId,previewPageIndex,previewPath,isPreviewLoading,previewFailure);

@override
String toString() {
  return 'PdfMergeState(documents: $documents, status: $status, acknowledgeDocumentChanges: $acknowledgeDocumentChanges, invalidRangeDocumentIds: $invalidRangeDocumentIds, stage: $stage, progress: $progress, result: $result, failure: $failure, messageId: $messageId, passwordPath: $passwordPath, pendingImportPaths: $pendingImportPaths, previewDocumentId: $previewDocumentId, previewPageIndex: $previewPageIndex, previewPath: $previewPath, isPreviewLoading: $isPreviewLoading, previewFailure: $previewFailure)';
}


}

/// @nodoc
abstract mixin class $PdfMergeStateCopyWith<$Res>  {
  factory $PdfMergeStateCopyWith(PdfMergeState value, $Res Function(PdfMergeState) _then) = _$PdfMergeStateCopyWithImpl;
@useResult
$Res call({
 List<PdfMergeDocument> documents, PdfMergeStatus status, bool acknowledgeDocumentChanges, Set<String> invalidRangeDocumentIds, PdfMergeStage? stage, double? progress, PdfMergeResult? result, PdfMergeFailureCode? failure, int messageId, String? passwordPath, List<String> pendingImportPaths, String? previewDocumentId, int previewPageIndex, String? previewPath, bool isPreviewLoading, PdfMergeFailureCode? previewFailure
});




}
/// @nodoc
class _$PdfMergeStateCopyWithImpl<$Res>
    implements $PdfMergeStateCopyWith<$Res> {
  _$PdfMergeStateCopyWithImpl(this._self, this._then);

  final PdfMergeState _self;
  final $Res Function(PdfMergeState) _then;

/// Create a copy of PdfMergeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? documents = null,Object? status = null,Object? acknowledgeDocumentChanges = null,Object? invalidRangeDocumentIds = null,Object? stage = freezed,Object? progress = freezed,Object? result = freezed,Object? failure = freezed,Object? messageId = null,Object? passwordPath = freezed,Object? pendingImportPaths = null,Object? previewDocumentId = freezed,Object? previewPageIndex = null,Object? previewPath = freezed,Object? isPreviewLoading = null,Object? previewFailure = freezed,}) {
  return _then(_self.copyWith(
documents: null == documents ? _self.documents : documents // ignore: cast_nullable_to_non_nullable
as List<PdfMergeDocument>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PdfMergeStatus,acknowledgeDocumentChanges: null == acknowledgeDocumentChanges ? _self.acknowledgeDocumentChanges : acknowledgeDocumentChanges // ignore: cast_nullable_to_non_nullable
as bool,invalidRangeDocumentIds: null == invalidRangeDocumentIds ? _self.invalidRangeDocumentIds : invalidRangeDocumentIds // ignore: cast_nullable_to_non_nullable
as Set<String>,stage: freezed == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as PdfMergeStage?,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double?,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as PdfMergeResult?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as PdfMergeFailureCode?,messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as int,passwordPath: freezed == passwordPath ? _self.passwordPath : passwordPath // ignore: cast_nullable_to_non_nullable
as String?,pendingImportPaths: null == pendingImportPaths ? _self.pendingImportPaths : pendingImportPaths // ignore: cast_nullable_to_non_nullable
as List<String>,previewDocumentId: freezed == previewDocumentId ? _self.previewDocumentId : previewDocumentId // ignore: cast_nullable_to_non_nullable
as String?,previewPageIndex: null == previewPageIndex ? _self.previewPageIndex : previewPageIndex // ignore: cast_nullable_to_non_nullable
as int,previewPath: freezed == previewPath ? _self.previewPath : previewPath // ignore: cast_nullable_to_non_nullable
as String?,isPreviewLoading: null == isPreviewLoading ? _self.isPreviewLoading : isPreviewLoading // ignore: cast_nullable_to_non_nullable
as bool,previewFailure: freezed == previewFailure ? _self.previewFailure : previewFailure // ignore: cast_nullable_to_non_nullable
as PdfMergeFailureCode?,
  ));
}

}


/// Adds pattern-matching-related methods to [PdfMergeState].
extension PdfMergeStatePatterns on PdfMergeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PdfMergeState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PdfMergeState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PdfMergeState value)  $default,){
final _that = this;
switch (_that) {
case _PdfMergeState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PdfMergeState value)?  $default,){
final _that = this;
switch (_that) {
case _PdfMergeState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<PdfMergeDocument> documents,  PdfMergeStatus status,  bool acknowledgeDocumentChanges,  Set<String> invalidRangeDocumentIds,  PdfMergeStage? stage,  double? progress,  PdfMergeResult? result,  PdfMergeFailureCode? failure,  int messageId,  String? passwordPath,  List<String> pendingImportPaths,  String? previewDocumentId,  int previewPageIndex,  String? previewPath,  bool isPreviewLoading,  PdfMergeFailureCode? previewFailure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PdfMergeState() when $default != null:
return $default(_that.documents,_that.status,_that.acknowledgeDocumentChanges,_that.invalidRangeDocumentIds,_that.stage,_that.progress,_that.result,_that.failure,_that.messageId,_that.passwordPath,_that.pendingImportPaths,_that.previewDocumentId,_that.previewPageIndex,_that.previewPath,_that.isPreviewLoading,_that.previewFailure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<PdfMergeDocument> documents,  PdfMergeStatus status,  bool acknowledgeDocumentChanges,  Set<String> invalidRangeDocumentIds,  PdfMergeStage? stage,  double? progress,  PdfMergeResult? result,  PdfMergeFailureCode? failure,  int messageId,  String? passwordPath,  List<String> pendingImportPaths,  String? previewDocumentId,  int previewPageIndex,  String? previewPath,  bool isPreviewLoading,  PdfMergeFailureCode? previewFailure)  $default,) {final _that = this;
switch (_that) {
case _PdfMergeState():
return $default(_that.documents,_that.status,_that.acknowledgeDocumentChanges,_that.invalidRangeDocumentIds,_that.stage,_that.progress,_that.result,_that.failure,_that.messageId,_that.passwordPath,_that.pendingImportPaths,_that.previewDocumentId,_that.previewPageIndex,_that.previewPath,_that.isPreviewLoading,_that.previewFailure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<PdfMergeDocument> documents,  PdfMergeStatus status,  bool acknowledgeDocumentChanges,  Set<String> invalidRangeDocumentIds,  PdfMergeStage? stage,  double? progress,  PdfMergeResult? result,  PdfMergeFailureCode? failure,  int messageId,  String? passwordPath,  List<String> pendingImportPaths,  String? previewDocumentId,  int previewPageIndex,  String? previewPath,  bool isPreviewLoading,  PdfMergeFailureCode? previewFailure)?  $default,) {final _that = this;
switch (_that) {
case _PdfMergeState() when $default != null:
return $default(_that.documents,_that.status,_that.acknowledgeDocumentChanges,_that.invalidRangeDocumentIds,_that.stage,_that.progress,_that.result,_that.failure,_that.messageId,_that.passwordPath,_that.pendingImportPaths,_that.previewDocumentId,_that.previewPageIndex,_that.previewPath,_that.isPreviewLoading,_that.previewFailure);case _:
  return null;

}
}

}

/// @nodoc


class _PdfMergeState extends PdfMergeState {
  const _PdfMergeState({final  List<PdfMergeDocument> documents = const [], this.status = PdfMergeStatus.initial, this.acknowledgeDocumentChanges = false, final  Set<String> invalidRangeDocumentIds = const {}, this.stage, this.progress, this.result, this.failure, this.messageId = 0, this.passwordPath, final  List<String> pendingImportPaths = const [], this.previewDocumentId, this.previewPageIndex = 0, this.previewPath, this.isPreviewLoading = false, this.previewFailure}): _documents = documents,_invalidRangeDocumentIds = invalidRangeDocumentIds,_pendingImportPaths = pendingImportPaths,super._();


 final  List<PdfMergeDocument> _documents;
@override@JsonKey() List<PdfMergeDocument> get documents {
  if (_documents is EqualUnmodifiableListView) return _documents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_documents);
}

@override@JsonKey() final  PdfMergeStatus status;
@override@JsonKey() final  bool acknowledgeDocumentChanges;
 final  Set<String> _invalidRangeDocumentIds;
@override@JsonKey() Set<String> get invalidRangeDocumentIds {
  if (_invalidRangeDocumentIds is EqualUnmodifiableSetView) return _invalidRangeDocumentIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_invalidRangeDocumentIds);
}

@override final  PdfMergeStage? stage;
@override final  double? progress;
@override final  PdfMergeResult? result;
@override final  PdfMergeFailureCode? failure;
@override@JsonKey() final  int messageId;
@override final  String? passwordPath;
 final  List<String> _pendingImportPaths;
@override@JsonKey() List<String> get pendingImportPaths {
  if (_pendingImportPaths is EqualUnmodifiableListView) return _pendingImportPaths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pendingImportPaths);
}

@override final  String? previewDocumentId;
@override@JsonKey() final  int previewPageIndex;
@override final  String? previewPath;
@override@JsonKey() final  bool isPreviewLoading;
@override final  PdfMergeFailureCode? previewFailure;

/// Create a copy of PdfMergeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PdfMergeStateCopyWith<_PdfMergeState> get copyWith => __$PdfMergeStateCopyWithImpl<_PdfMergeState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PdfMergeState&&const DeepCollectionEquality().equals(other._documents, _documents)&&(identical(other.status, status) || other.status == status)&&(identical(other.acknowledgeDocumentChanges, acknowledgeDocumentChanges) || other.acknowledgeDocumentChanges == acknowledgeDocumentChanges)&&const DeepCollectionEquality().equals(other._invalidRangeDocumentIds, _invalidRangeDocumentIds)&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.result, result) || other.result == result)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.passwordPath, passwordPath) || other.passwordPath == passwordPath)&&const DeepCollectionEquality().equals(other._pendingImportPaths, _pendingImportPaths)&&(identical(other.previewDocumentId, previewDocumentId) || other.previewDocumentId == previewDocumentId)&&(identical(other.previewPageIndex, previewPageIndex) || other.previewPageIndex == previewPageIndex)&&(identical(other.previewPath, previewPath) || other.previewPath == previewPath)&&(identical(other.isPreviewLoading, isPreviewLoading) || other.isPreviewLoading == isPreviewLoading)&&(identical(other.previewFailure, previewFailure) || other.previewFailure == previewFailure));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_documents),status,acknowledgeDocumentChanges,const DeepCollectionEquality().hash(_invalidRangeDocumentIds),stage,progress,result,failure,messageId,passwordPath,const DeepCollectionEquality().hash(_pendingImportPaths),previewDocumentId,previewPageIndex,previewPath,isPreviewLoading,previewFailure);

@override
String toString() {
  return 'PdfMergeState(documents: $documents, status: $status, acknowledgeDocumentChanges: $acknowledgeDocumentChanges, invalidRangeDocumentIds: $invalidRangeDocumentIds, stage: $stage, progress: $progress, result: $result, failure: $failure, messageId: $messageId, passwordPath: $passwordPath, pendingImportPaths: $pendingImportPaths, previewDocumentId: $previewDocumentId, previewPageIndex: $previewPageIndex, previewPath: $previewPath, isPreviewLoading: $isPreviewLoading, previewFailure: $previewFailure)';
}


}

/// @nodoc
abstract mixin class _$PdfMergeStateCopyWith<$Res> implements $PdfMergeStateCopyWith<$Res> {
  factory _$PdfMergeStateCopyWith(_PdfMergeState value, $Res Function(_PdfMergeState) _then) = __$PdfMergeStateCopyWithImpl;
@override @useResult
$Res call({
 List<PdfMergeDocument> documents, PdfMergeStatus status, bool acknowledgeDocumentChanges, Set<String> invalidRangeDocumentIds, PdfMergeStage? stage, double? progress, PdfMergeResult? result, PdfMergeFailureCode? failure, int messageId, String? passwordPath, List<String> pendingImportPaths, String? previewDocumentId, int previewPageIndex, String? previewPath, bool isPreviewLoading, PdfMergeFailureCode? previewFailure
});




}
/// @nodoc
class __$PdfMergeStateCopyWithImpl<$Res>
    implements _$PdfMergeStateCopyWith<$Res> {
  __$PdfMergeStateCopyWithImpl(this._self, this._then);

  final _PdfMergeState _self;
  final $Res Function(_PdfMergeState) _then;

/// Create a copy of PdfMergeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? documents = null,Object? status = null,Object? acknowledgeDocumentChanges = null,Object? invalidRangeDocumentIds = null,Object? stage = freezed,Object? progress = freezed,Object? result = freezed,Object? failure = freezed,Object? messageId = null,Object? passwordPath = freezed,Object? pendingImportPaths = null,Object? previewDocumentId = freezed,Object? previewPageIndex = null,Object? previewPath = freezed,Object? isPreviewLoading = null,Object? previewFailure = freezed,}) {
  return _then(_PdfMergeState(
documents: null == documents ? _self._documents : documents // ignore: cast_nullable_to_non_nullable
as List<PdfMergeDocument>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PdfMergeStatus,acknowledgeDocumentChanges: null == acknowledgeDocumentChanges ? _self.acknowledgeDocumentChanges : acknowledgeDocumentChanges // ignore: cast_nullable_to_non_nullable
as bool,invalidRangeDocumentIds: null == invalidRangeDocumentIds ? _self._invalidRangeDocumentIds : invalidRangeDocumentIds // ignore: cast_nullable_to_non_nullable
as Set<String>,stage: freezed == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as PdfMergeStage?,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double?,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as PdfMergeResult?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as PdfMergeFailureCode?,messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as int,passwordPath: freezed == passwordPath ? _self.passwordPath : passwordPath // ignore: cast_nullable_to_non_nullable
as String?,pendingImportPaths: null == pendingImportPaths ? _self._pendingImportPaths : pendingImportPaths // ignore: cast_nullable_to_non_nullable
as List<String>,previewDocumentId: freezed == previewDocumentId ? _self.previewDocumentId : previewDocumentId // ignore: cast_nullable_to_non_nullable
as String?,previewPageIndex: null == previewPageIndex ? _self.previewPageIndex : previewPageIndex // ignore: cast_nullable_to_non_nullable
as int,previewPath: freezed == previewPath ? _self.previewPath : previewPath // ignore: cast_nullable_to_non_nullable
as String?,isPreviewLoading: null == isPreviewLoading ? _self.isPreviewLoading : isPreviewLoading // ignore: cast_nullable_to_non_nullable
as bool,previewFailure: freezed == previewFailure ? _self.previewFailure : previewFailure // ignore: cast_nullable_to_non_nullable
as PdfMergeFailureCode?,
  ));
}


}

// dart format on
