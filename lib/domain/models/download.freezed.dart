// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'download.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DomainDownload {

 String get id; String get package; String get detailUrl; String get title; String get episode; String? get cover; double get progress; DownloadStatus get status; int get speed; int get size; int? get downloadedBytes; String? get error; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of DomainDownload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainDownloadCopyWith<DomainDownload> get copyWith => _$DomainDownloadCopyWithImpl<DomainDownload>(this as DomainDownload, _$identity);

  /// Serializes this DomainDownload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainDownload&&(identical(other.id, id) || other.id == id)&&(identical(other.package, package) || other.package == package)&&(identical(other.detailUrl, detailUrl) || other.detailUrl == detailUrl)&&(identical(other.title, title) || other.title == title)&&(identical(other.episode, episode) || other.episode == episode)&&(identical(other.cover, cover) || other.cover == cover)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.status, status) || other.status == status)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.size, size) || other.size == size)&&(identical(other.downloadedBytes, downloadedBytes) || other.downloadedBytes == downloadedBytes)&&(identical(other.error, error) || other.error == error)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,package,detailUrl,title,episode,cover,progress,status,speed,size,downloadedBytes,error,createdAt,updatedAt);

@override
String toString() {
  return 'DomainDownload(id: $id, package: $package, detailUrl: $detailUrl, title: $title, episode: $episode, cover: $cover, progress: $progress, status: $status, speed: $speed, size: $size, downloadedBytes: $downloadedBytes, error: $error, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $DomainDownloadCopyWith<$Res>  {
  factory $DomainDownloadCopyWith(DomainDownload value, $Res Function(DomainDownload) _then) = _$DomainDownloadCopyWithImpl;
@useResult
$Res call({
 String id, String package, String detailUrl, String title, String episode, String? cover, double progress, DownloadStatus status, int speed, int size, int? downloadedBytes, String? error, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$DomainDownloadCopyWithImpl<$Res>
    implements $DomainDownloadCopyWith<$Res> {
  _$DomainDownloadCopyWithImpl(this._self, this._then);

  final DomainDownload _self;
  final $Res Function(DomainDownload) _then;

/// Create a copy of DomainDownload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? package = null,Object? detailUrl = null,Object? title = null,Object? episode = null,Object? cover = freezed,Object? progress = null,Object? status = null,Object? speed = null,Object? size = null,Object? downloadedBytes = freezed,Object? error = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,package: null == package ? _self.package : package // ignore: cast_nullable_to_non_nullable
as String,detailUrl: null == detailUrl ? _self.detailUrl : detailUrl // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,episode: null == episode ? _self.episode : episode // ignore: cast_nullable_to_non_nullable
as String,cover: freezed == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as String?,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DownloadStatus,speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,downloadedBytes: freezed == downloadedBytes ? _self.downloadedBytes : downloadedBytes // ignore: cast_nullable_to_non_nullable
as int?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainDownload].
extension DomainDownloadPatterns on DomainDownload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainDownload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainDownload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainDownload value)  $default,){
final _that = this;
switch (_that) {
case _DomainDownload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainDownload value)?  $default,){
final _that = this;
switch (_that) {
case _DomainDownload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String package,  String detailUrl,  String title,  String episode,  String? cover,  double progress,  DownloadStatus status,  int speed,  int size,  int? downloadedBytes,  String? error,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainDownload() when $default != null:
return $default(_that.id,_that.package,_that.detailUrl,_that.title,_that.episode,_that.cover,_that.progress,_that.status,_that.speed,_that.size,_that.downloadedBytes,_that.error,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String package,  String detailUrl,  String title,  String episode,  String? cover,  double progress,  DownloadStatus status,  int speed,  int size,  int? downloadedBytes,  String? error,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _DomainDownload():
return $default(_that.id,_that.package,_that.detailUrl,_that.title,_that.episode,_that.cover,_that.progress,_that.status,_that.speed,_that.size,_that.downloadedBytes,_that.error,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String package,  String detailUrl,  String title,  String episode,  String? cover,  double progress,  DownloadStatus status,  int speed,  int size,  int? downloadedBytes,  String? error,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _DomainDownload() when $default != null:
return $default(_that.id,_that.package,_that.detailUrl,_that.title,_that.episode,_that.cover,_that.progress,_that.status,_that.speed,_that.size,_that.downloadedBytes,_that.error,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainDownload implements DomainDownload {
  const _DomainDownload({required this.id, required this.package, required this.detailUrl, required this.title, required this.episode, this.cover, required this.progress, required this.status, required this.speed, required this.size, this.downloadedBytes, this.error, this.createdAt, this.updatedAt});
  factory _DomainDownload.fromJson(Map<String, dynamic> json) => _$DomainDownloadFromJson(json);

@override final  String id;
@override final  String package;
@override final  String detailUrl;
@override final  String title;
@override final  String episode;
@override final  String? cover;
@override final  double progress;
@override final  DownloadStatus status;
@override final  int speed;
@override final  int size;
@override final  int? downloadedBytes;
@override final  String? error;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of DomainDownload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainDownloadCopyWith<_DomainDownload> get copyWith => __$DomainDownloadCopyWithImpl<_DomainDownload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainDownloadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainDownload&&(identical(other.id, id) || other.id == id)&&(identical(other.package, package) || other.package == package)&&(identical(other.detailUrl, detailUrl) || other.detailUrl == detailUrl)&&(identical(other.title, title) || other.title == title)&&(identical(other.episode, episode) || other.episode == episode)&&(identical(other.cover, cover) || other.cover == cover)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.status, status) || other.status == status)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.size, size) || other.size == size)&&(identical(other.downloadedBytes, downloadedBytes) || other.downloadedBytes == downloadedBytes)&&(identical(other.error, error) || other.error == error)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,package,detailUrl,title,episode,cover,progress,status,speed,size,downloadedBytes,error,createdAt,updatedAt);

@override
String toString() {
  return 'DomainDownload(id: $id, package: $package, detailUrl: $detailUrl, title: $title, episode: $episode, cover: $cover, progress: $progress, status: $status, speed: $speed, size: $size, downloadedBytes: $downloadedBytes, error: $error, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$DomainDownloadCopyWith<$Res> implements $DomainDownloadCopyWith<$Res> {
  factory _$DomainDownloadCopyWith(_DomainDownload value, $Res Function(_DomainDownload) _then) = __$DomainDownloadCopyWithImpl;
@override @useResult
$Res call({
 String id, String package, String detailUrl, String title, String episode, String? cover, double progress, DownloadStatus status, int speed, int size, int? downloadedBytes, String? error, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$DomainDownloadCopyWithImpl<$Res>
    implements _$DomainDownloadCopyWith<$Res> {
  __$DomainDownloadCopyWithImpl(this._self, this._then);

  final _DomainDownload _self;
  final $Res Function(_DomainDownload) _then;

/// Create a copy of DomainDownload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? package = null,Object? detailUrl = null,Object? title = null,Object? episode = null,Object? cover = freezed,Object? progress = null,Object? status = null,Object? speed = null,Object? size = null,Object? downloadedBytes = freezed,Object? error = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_DomainDownload(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,package: null == package ? _self.package : package // ignore: cast_nullable_to_non_nullable
as String,detailUrl: null == detailUrl ? _self.detailUrl : detailUrl // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,episode: null == episode ? _self.episode : episode // ignore: cast_nullable_to_non_nullable
as String,cover: freezed == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as String?,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DownloadStatus,speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,downloadedBytes: freezed == downloadedBytes ? _self.downloadedBytes : downloadedBytes // ignore: cast_nullable_to_non_nullable
as int?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$DomainDownloadProgress {

 String get downloadId; double get progress; int get speed; int get downloadedBytes; int get totalBytes; DownloadStatus? get status; String? get error;
/// Create a copy of DomainDownloadProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainDownloadProgressCopyWith<DomainDownloadProgress> get copyWith => _$DomainDownloadProgressCopyWithImpl<DomainDownloadProgress>(this as DomainDownloadProgress, _$identity);

  /// Serializes this DomainDownloadProgress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainDownloadProgress&&(identical(other.downloadId, downloadId) || other.downloadId == downloadId)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.downloadedBytes, downloadedBytes) || other.downloadedBytes == downloadedBytes)&&(identical(other.totalBytes, totalBytes) || other.totalBytes == totalBytes)&&(identical(other.status, status) || other.status == status)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,downloadId,progress,speed,downloadedBytes,totalBytes,status,error);

@override
String toString() {
  return 'DomainDownloadProgress(downloadId: $downloadId, progress: $progress, speed: $speed, downloadedBytes: $downloadedBytes, totalBytes: $totalBytes, status: $status, error: $error)';
}


}

/// @nodoc
abstract mixin class $DomainDownloadProgressCopyWith<$Res>  {
  factory $DomainDownloadProgressCopyWith(DomainDownloadProgress value, $Res Function(DomainDownloadProgress) _then) = _$DomainDownloadProgressCopyWithImpl;
@useResult
$Res call({
 String downloadId, double progress, int speed, int downloadedBytes, int totalBytes, DownloadStatus? status, String? error
});




}
/// @nodoc
class _$DomainDownloadProgressCopyWithImpl<$Res>
    implements $DomainDownloadProgressCopyWith<$Res> {
  _$DomainDownloadProgressCopyWithImpl(this._self, this._then);

  final DomainDownloadProgress _self;
  final $Res Function(DomainDownloadProgress) _then;

/// Create a copy of DomainDownloadProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? downloadId = null,Object? progress = null,Object? speed = null,Object? downloadedBytes = null,Object? totalBytes = null,Object? status = freezed,Object? error = freezed,}) {
  return _then(_self.copyWith(
downloadId: null == downloadId ? _self.downloadId : downloadId // ignore: cast_nullable_to_non_nullable
as String,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as int,downloadedBytes: null == downloadedBytes ? _self.downloadedBytes : downloadedBytes // ignore: cast_nullable_to_non_nullable
as int,totalBytes: null == totalBytes ? _self.totalBytes : totalBytes // ignore: cast_nullable_to_non_nullable
as int,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DownloadStatus?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainDownloadProgress].
extension DomainDownloadProgressPatterns on DomainDownloadProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainDownloadProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainDownloadProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainDownloadProgress value)  $default,){
final _that = this;
switch (_that) {
case _DomainDownloadProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainDownloadProgress value)?  $default,){
final _that = this;
switch (_that) {
case _DomainDownloadProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String downloadId,  double progress,  int speed,  int downloadedBytes,  int totalBytes,  DownloadStatus? status,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainDownloadProgress() when $default != null:
return $default(_that.downloadId,_that.progress,_that.speed,_that.downloadedBytes,_that.totalBytes,_that.status,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String downloadId,  double progress,  int speed,  int downloadedBytes,  int totalBytes,  DownloadStatus? status,  String? error)  $default,) {final _that = this;
switch (_that) {
case _DomainDownloadProgress():
return $default(_that.downloadId,_that.progress,_that.speed,_that.downloadedBytes,_that.totalBytes,_that.status,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String downloadId,  double progress,  int speed,  int downloadedBytes,  int totalBytes,  DownloadStatus? status,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _DomainDownloadProgress() when $default != null:
return $default(_that.downloadId,_that.progress,_that.speed,_that.downloadedBytes,_that.totalBytes,_that.status,_that.error);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainDownloadProgress implements DomainDownloadProgress {
  const _DomainDownloadProgress({required this.downloadId, required this.progress, required this.speed, required this.downloadedBytes, required this.totalBytes, this.status, this.error});
  factory _DomainDownloadProgress.fromJson(Map<String, dynamic> json) => _$DomainDownloadProgressFromJson(json);

@override final  String downloadId;
@override final  double progress;
@override final  int speed;
@override final  int downloadedBytes;
@override final  int totalBytes;
@override final  DownloadStatus? status;
@override final  String? error;

/// Create a copy of DomainDownloadProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainDownloadProgressCopyWith<_DomainDownloadProgress> get copyWith => __$DomainDownloadProgressCopyWithImpl<_DomainDownloadProgress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainDownloadProgressToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainDownloadProgress&&(identical(other.downloadId, downloadId) || other.downloadId == downloadId)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.downloadedBytes, downloadedBytes) || other.downloadedBytes == downloadedBytes)&&(identical(other.totalBytes, totalBytes) || other.totalBytes == totalBytes)&&(identical(other.status, status) || other.status == status)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,downloadId,progress,speed,downloadedBytes,totalBytes,status,error);

@override
String toString() {
  return 'DomainDownloadProgress(downloadId: $downloadId, progress: $progress, speed: $speed, downloadedBytes: $downloadedBytes, totalBytes: $totalBytes, status: $status, error: $error)';
}


}

/// @nodoc
abstract mixin class _$DomainDownloadProgressCopyWith<$Res> implements $DomainDownloadProgressCopyWith<$Res> {
  factory _$DomainDownloadProgressCopyWith(_DomainDownloadProgress value, $Res Function(_DomainDownloadProgress) _then) = __$DomainDownloadProgressCopyWithImpl;
@override @useResult
$Res call({
 String downloadId, double progress, int speed, int downloadedBytes, int totalBytes, DownloadStatus? status, String? error
});




}
/// @nodoc
class __$DomainDownloadProgressCopyWithImpl<$Res>
    implements _$DomainDownloadProgressCopyWith<$Res> {
  __$DomainDownloadProgressCopyWithImpl(this._self, this._then);

  final _DomainDownloadProgress _self;
  final $Res Function(_DomainDownloadProgress) _then;

/// Create a copy of DomainDownloadProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? downloadId = null,Object? progress = null,Object? speed = null,Object? downloadedBytes = null,Object? totalBytes = null,Object? status = freezed,Object? error = freezed,}) {
  return _then(_DomainDownloadProgress(
downloadId: null == downloadId ? _self.downloadId : downloadId // ignore: cast_nullable_to_non_nullable
as String,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as int,downloadedBytes: null == downloadedBytes ? _self.downloadedBytes : downloadedBytes // ignore: cast_nullable_to_non_nullable
as int,totalBytes: null == totalBytes ? _self.totalBytes : totalBytes // ignore: cast_nullable_to_non_nullable
as int,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DownloadStatus?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
