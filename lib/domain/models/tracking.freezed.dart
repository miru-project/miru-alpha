// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tracking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DomainTrackingAccount {

 int get id; String get name; String? get avatar; TrackingProvider get provider;
/// Create a copy of DomainTrackingAccount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainTrackingAccountCopyWith<DomainTrackingAccount> get copyWith => _$DomainTrackingAccountCopyWithImpl<DomainTrackingAccount>(this as DomainTrackingAccount, _$identity);

  /// Serializes this DomainTrackingAccount to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainTrackingAccount&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.provider, provider) || other.provider == provider));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,avatar,provider);

@override
String toString() {
  return 'DomainTrackingAccount(id: $id, name: $name, avatar: $avatar, provider: $provider)';
}


}

/// @nodoc
abstract mixin class $DomainTrackingAccountCopyWith<$Res>  {
  factory $DomainTrackingAccountCopyWith(DomainTrackingAccount value, $Res Function(DomainTrackingAccount) _then) = _$DomainTrackingAccountCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? avatar, TrackingProvider provider
});




}
/// @nodoc
class _$DomainTrackingAccountCopyWithImpl<$Res>
    implements $DomainTrackingAccountCopyWith<$Res> {
  _$DomainTrackingAccountCopyWithImpl(this._self, this._then);

  final DomainTrackingAccount _self;
  final $Res Function(DomainTrackingAccount) _then;

/// Create a copy of DomainTrackingAccount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? avatar = freezed,Object? provider = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as TrackingProvider,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainTrackingAccount].
extension DomainTrackingAccountPatterns on DomainTrackingAccount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainTrackingAccount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainTrackingAccount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainTrackingAccount value)  $default,){
final _that = this;
switch (_that) {
case _DomainTrackingAccount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainTrackingAccount value)?  $default,){
final _that = this;
switch (_that) {
case _DomainTrackingAccount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? avatar,  TrackingProvider provider)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainTrackingAccount() when $default != null:
return $default(_that.id,_that.name,_that.avatar,_that.provider);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? avatar,  TrackingProvider provider)  $default,) {final _that = this;
switch (_that) {
case _DomainTrackingAccount():
return $default(_that.id,_that.name,_that.avatar,_that.provider);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? avatar,  TrackingProvider provider)?  $default,) {final _that = this;
switch (_that) {
case _DomainTrackingAccount() when $default != null:
return $default(_that.id,_that.name,_that.avatar,_that.provider);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainTrackingAccount implements DomainTrackingAccount {
  const _DomainTrackingAccount({required this.id, required this.name, this.avatar, required this.provider});
  factory _DomainTrackingAccount.fromJson(Map<String, dynamic> json) => _$DomainTrackingAccountFromJson(json);

@override final  int id;
@override final  String name;
@override final  String? avatar;
@override final  TrackingProvider provider;

/// Create a copy of DomainTrackingAccount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainTrackingAccountCopyWith<_DomainTrackingAccount> get copyWith => __$DomainTrackingAccountCopyWithImpl<_DomainTrackingAccount>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainTrackingAccountToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainTrackingAccount&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.provider, provider) || other.provider == provider));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,avatar,provider);

@override
String toString() {
  return 'DomainTrackingAccount(id: $id, name: $name, avatar: $avatar, provider: $provider)';
}


}

/// @nodoc
abstract mixin class _$DomainTrackingAccountCopyWith<$Res> implements $DomainTrackingAccountCopyWith<$Res> {
  factory _$DomainTrackingAccountCopyWith(_DomainTrackingAccount value, $Res Function(_DomainTrackingAccount) _then) = __$DomainTrackingAccountCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? avatar, TrackingProvider provider
});




}
/// @nodoc
class __$DomainTrackingAccountCopyWithImpl<$Res>
    implements _$DomainTrackingAccountCopyWith<$Res> {
  __$DomainTrackingAccountCopyWithImpl(this._self, this._then);

  final _DomainTrackingAccount _self;
  final $Res Function(_DomainTrackingAccount) _then;

/// Create a copy of DomainTrackingAccount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? avatar = freezed,Object? provider = null,}) {
  return _then(_DomainTrackingAccount(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as TrackingProvider,
  ));
}


}


/// @nodoc
mixin _$DomainTrackingProgress {

 int get id; int get mediaId; String get status; int get progress; double? get score; String? get mediaType; String? get title; String? get cover;
/// Create a copy of DomainTrackingProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainTrackingProgressCopyWith<DomainTrackingProgress> get copyWith => _$DomainTrackingProgressCopyWithImpl<DomainTrackingProgress>(this as DomainTrackingProgress, _$identity);

  /// Serializes this DomainTrackingProgress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainTrackingProgress&&(identical(other.id, id) || other.id == id)&&(identical(other.mediaId, mediaId) || other.mediaId == mediaId)&&(identical(other.status, status) || other.status == status)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.score, score) || other.score == score)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.title, title) || other.title == title)&&(identical(other.cover, cover) || other.cover == cover));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,mediaId,status,progress,score,mediaType,title,cover);

@override
String toString() {
  return 'DomainTrackingProgress(id: $id, mediaId: $mediaId, status: $status, progress: $progress, score: $score, mediaType: $mediaType, title: $title, cover: $cover)';
}


}

/// @nodoc
abstract mixin class $DomainTrackingProgressCopyWith<$Res>  {
  factory $DomainTrackingProgressCopyWith(DomainTrackingProgress value, $Res Function(DomainTrackingProgress) _then) = _$DomainTrackingProgressCopyWithImpl;
@useResult
$Res call({
 int id, int mediaId, String status, int progress, double? score, String? mediaType, String? title, String? cover
});




}
/// @nodoc
class _$DomainTrackingProgressCopyWithImpl<$Res>
    implements $DomainTrackingProgressCopyWith<$Res> {
  _$DomainTrackingProgressCopyWithImpl(this._self, this._then);

  final DomainTrackingProgress _self;
  final $Res Function(DomainTrackingProgress) _then;

/// Create a copy of DomainTrackingProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? mediaId = null,Object? status = null,Object? progress = null,Object? score = freezed,Object? mediaType = freezed,Object? title = freezed,Object? cover = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,mediaId: null == mediaId ? _self.mediaId : mediaId // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as int,score: freezed == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double?,mediaType: freezed == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,cover: freezed == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainTrackingProgress].
extension DomainTrackingProgressPatterns on DomainTrackingProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainTrackingProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainTrackingProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainTrackingProgress value)  $default,){
final _that = this;
switch (_that) {
case _DomainTrackingProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainTrackingProgress value)?  $default,){
final _that = this;
switch (_that) {
case _DomainTrackingProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int mediaId,  String status,  int progress,  double? score,  String? mediaType,  String? title,  String? cover)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainTrackingProgress() when $default != null:
return $default(_that.id,_that.mediaId,_that.status,_that.progress,_that.score,_that.mediaType,_that.title,_that.cover);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int mediaId,  String status,  int progress,  double? score,  String? mediaType,  String? title,  String? cover)  $default,) {final _that = this;
switch (_that) {
case _DomainTrackingProgress():
return $default(_that.id,_that.mediaId,_that.status,_that.progress,_that.score,_that.mediaType,_that.title,_that.cover);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int mediaId,  String status,  int progress,  double? score,  String? mediaType,  String? title,  String? cover)?  $default,) {final _that = this;
switch (_that) {
case _DomainTrackingProgress() when $default != null:
return $default(_that.id,_that.mediaId,_that.status,_that.progress,_that.score,_that.mediaType,_that.title,_that.cover);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainTrackingProgress implements DomainTrackingProgress {
  const _DomainTrackingProgress({required this.id, required this.mediaId, required this.status, required this.progress, this.score, this.mediaType, this.title, this.cover});
  factory _DomainTrackingProgress.fromJson(Map<String, dynamic> json) => _$DomainTrackingProgressFromJson(json);

@override final  int id;
@override final  int mediaId;
@override final  String status;
@override final  int progress;
@override final  double? score;
@override final  String? mediaType;
@override final  String? title;
@override final  String? cover;

/// Create a copy of DomainTrackingProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainTrackingProgressCopyWith<_DomainTrackingProgress> get copyWith => __$DomainTrackingProgressCopyWithImpl<_DomainTrackingProgress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainTrackingProgressToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainTrackingProgress&&(identical(other.id, id) || other.id == id)&&(identical(other.mediaId, mediaId) || other.mediaId == mediaId)&&(identical(other.status, status) || other.status == status)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.score, score) || other.score == score)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.title, title) || other.title == title)&&(identical(other.cover, cover) || other.cover == cover));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,mediaId,status,progress,score,mediaType,title,cover);

@override
String toString() {
  return 'DomainTrackingProgress(id: $id, mediaId: $mediaId, status: $status, progress: $progress, score: $score, mediaType: $mediaType, title: $title, cover: $cover)';
}


}

/// @nodoc
abstract mixin class _$DomainTrackingProgressCopyWith<$Res> implements $DomainTrackingProgressCopyWith<$Res> {
  factory _$DomainTrackingProgressCopyWith(_DomainTrackingProgress value, $Res Function(_DomainTrackingProgress) _then) = __$DomainTrackingProgressCopyWithImpl;
@override @useResult
$Res call({
 int id, int mediaId, String status, int progress, double? score, String? mediaType, String? title, String? cover
});




}
/// @nodoc
class __$DomainTrackingProgressCopyWithImpl<$Res>
    implements _$DomainTrackingProgressCopyWith<$Res> {
  __$DomainTrackingProgressCopyWithImpl(this._self, this._then);

  final _DomainTrackingProgress _self;
  final $Res Function(_DomainTrackingProgress) _then;

/// Create a copy of DomainTrackingProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? mediaId = null,Object? status = null,Object? progress = null,Object? score = freezed,Object? mediaType = freezed,Object? title = freezed,Object? cover = freezed,}) {
  return _then(_DomainTrackingProgress(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,mediaId: null == mediaId ? _self.mediaId : mediaId // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as int,score: freezed == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double?,mediaType: freezed == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,cover: freezed == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$DomainTMDBTrack {

 int get id; int get mediaId; String get mediaType; String get title; String? get cover; String? get overview; String? get status; int? get runtime; List<String>? get genres; DateTime get updatedAt;
/// Create a copy of DomainTMDBTrack
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainTMDBTrackCopyWith<DomainTMDBTrack> get copyWith => _$DomainTMDBTrackCopyWithImpl<DomainTMDBTrack>(this as DomainTMDBTrack, _$identity);

  /// Serializes this DomainTMDBTrack to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainTMDBTrack&&(identical(other.id, id) || other.id == id)&&(identical(other.mediaId, mediaId) || other.mediaId == mediaId)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.title, title) || other.title == title)&&(identical(other.cover, cover) || other.cover == cover)&&(identical(other.overview, overview) || other.overview == overview)&&(identical(other.status, status) || other.status == status)&&(identical(other.runtime, runtime) || other.runtime == runtime)&&const DeepCollectionEquality().equals(other.genres, genres)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,mediaId,mediaType,title,cover,overview,status,runtime,const DeepCollectionEquality().hash(genres),updatedAt);

@override
String toString() {
  return 'DomainTMDBTrack(id: $id, mediaId: $mediaId, mediaType: $mediaType, title: $title, cover: $cover, overview: $overview, status: $status, runtime: $runtime, genres: $genres, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $DomainTMDBTrackCopyWith<$Res>  {
  factory $DomainTMDBTrackCopyWith(DomainTMDBTrack value, $Res Function(DomainTMDBTrack) _then) = _$DomainTMDBTrackCopyWithImpl;
@useResult
$Res call({
 int id, int mediaId, String mediaType, String title, String? cover, String? overview, String? status, int? runtime, List<String>? genres, DateTime updatedAt
});




}
/// @nodoc
class _$DomainTMDBTrackCopyWithImpl<$Res>
    implements $DomainTMDBTrackCopyWith<$Res> {
  _$DomainTMDBTrackCopyWithImpl(this._self, this._then);

  final DomainTMDBTrack _self;
  final $Res Function(DomainTMDBTrack) _then;

/// Create a copy of DomainTMDBTrack
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? mediaId = null,Object? mediaType = null,Object? title = null,Object? cover = freezed,Object? overview = freezed,Object? status = freezed,Object? runtime = freezed,Object? genres = freezed,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,mediaId: null == mediaId ? _self.mediaId : mediaId // ignore: cast_nullable_to_non_nullable
as int,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,cover: freezed == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as String?,overview: freezed == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,runtime: freezed == runtime ? _self.runtime : runtime // ignore: cast_nullable_to_non_nullable
as int?,genres: freezed == genres ? _self.genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainTMDBTrack].
extension DomainTMDBTrackPatterns on DomainTMDBTrack {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainTMDBTrack value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainTMDBTrack() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainTMDBTrack value)  $default,){
final _that = this;
switch (_that) {
case _DomainTMDBTrack():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainTMDBTrack value)?  $default,){
final _that = this;
switch (_that) {
case _DomainTMDBTrack() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int mediaId,  String mediaType,  String title,  String? cover,  String? overview,  String? status,  int? runtime,  List<String>? genres,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainTMDBTrack() when $default != null:
return $default(_that.id,_that.mediaId,_that.mediaType,_that.title,_that.cover,_that.overview,_that.status,_that.runtime,_that.genres,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int mediaId,  String mediaType,  String title,  String? cover,  String? overview,  String? status,  int? runtime,  List<String>? genres,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _DomainTMDBTrack():
return $default(_that.id,_that.mediaId,_that.mediaType,_that.title,_that.cover,_that.overview,_that.status,_that.runtime,_that.genres,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int mediaId,  String mediaType,  String title,  String? cover,  String? overview,  String? status,  int? runtime,  List<String>? genres,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _DomainTMDBTrack() when $default != null:
return $default(_that.id,_that.mediaId,_that.mediaType,_that.title,_that.cover,_that.overview,_that.status,_that.runtime,_that.genres,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainTMDBTrack implements DomainTMDBTrack {
  const _DomainTMDBTrack({required this.id, required this.mediaId, required this.mediaType, required this.title, this.cover, this.overview, this.status, this.runtime, final  List<String>? genres, required this.updatedAt}): _genres = genres;
  factory _DomainTMDBTrack.fromJson(Map<String, dynamic> json) => _$DomainTMDBTrackFromJson(json);

@override final  int id;
@override final  int mediaId;
@override final  String mediaType;
@override final  String title;
@override final  String? cover;
@override final  String? overview;
@override final  String? status;
@override final  int? runtime;
 final  List<String>? _genres;
@override List<String>? get genres {
  final value = _genres;
  if (value == null) return null;
  if (_genres is EqualUnmodifiableListView) return _genres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  DateTime updatedAt;

/// Create a copy of DomainTMDBTrack
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainTMDBTrackCopyWith<_DomainTMDBTrack> get copyWith => __$DomainTMDBTrackCopyWithImpl<_DomainTMDBTrack>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainTMDBTrackToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainTMDBTrack&&(identical(other.id, id) || other.id == id)&&(identical(other.mediaId, mediaId) || other.mediaId == mediaId)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.title, title) || other.title == title)&&(identical(other.cover, cover) || other.cover == cover)&&(identical(other.overview, overview) || other.overview == overview)&&(identical(other.status, status) || other.status == status)&&(identical(other.runtime, runtime) || other.runtime == runtime)&&const DeepCollectionEquality().equals(other._genres, _genres)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,mediaId,mediaType,title,cover,overview,status,runtime,const DeepCollectionEquality().hash(_genres),updatedAt);

@override
String toString() {
  return 'DomainTMDBTrack(id: $id, mediaId: $mediaId, mediaType: $mediaType, title: $title, cover: $cover, overview: $overview, status: $status, runtime: $runtime, genres: $genres, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$DomainTMDBTrackCopyWith<$Res> implements $DomainTMDBTrackCopyWith<$Res> {
  factory _$DomainTMDBTrackCopyWith(_DomainTMDBTrack value, $Res Function(_DomainTMDBTrack) _then) = __$DomainTMDBTrackCopyWithImpl;
@override @useResult
$Res call({
 int id, int mediaId, String mediaType, String title, String? cover, String? overview, String? status, int? runtime, List<String>? genres, DateTime updatedAt
});




}
/// @nodoc
class __$DomainTMDBTrackCopyWithImpl<$Res>
    implements _$DomainTMDBTrackCopyWith<$Res> {
  __$DomainTMDBTrackCopyWithImpl(this._self, this._then);

  final _DomainTMDBTrack _self;
  final $Res Function(_DomainTMDBTrack) _then;

/// Create a copy of DomainTMDBTrack
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? mediaId = null,Object? mediaType = null,Object? title = null,Object? cover = freezed,Object? overview = freezed,Object? status = freezed,Object? runtime = freezed,Object? genres = freezed,Object? updatedAt = null,}) {
  return _then(_DomainTMDBTrack(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,mediaId: null == mediaId ? _self.mediaId : mediaId // ignore: cast_nullable_to_non_nullable
as int,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,cover: freezed == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as String?,overview: freezed == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,runtime: freezed == runtime ? _self.runtime : runtime // ignore: cast_nullable_to_non_nullable
as int?,genres: freezed == genres ? _self._genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$DomainTMDBCast {

 String get name; String get character; String? get profilePath;
/// Create a copy of DomainTMDBCast
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainTMDBCastCopyWith<DomainTMDBCast> get copyWith => _$DomainTMDBCastCopyWithImpl<DomainTMDBCast>(this as DomainTMDBCast, _$identity);

  /// Serializes this DomainTMDBCast to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainTMDBCast&&(identical(other.name, name) || other.name == name)&&(identical(other.character, character) || other.character == character)&&(identical(other.profilePath, profilePath) || other.profilePath == profilePath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,character,profilePath);

@override
String toString() {
  return 'DomainTMDBCast(name: $name, character: $character, profilePath: $profilePath)';
}


}

/// @nodoc
abstract mixin class $DomainTMDBCastCopyWith<$Res>  {
  factory $DomainTMDBCastCopyWith(DomainTMDBCast value, $Res Function(DomainTMDBCast) _then) = _$DomainTMDBCastCopyWithImpl;
@useResult
$Res call({
 String name, String character, String? profilePath
});




}
/// @nodoc
class _$DomainTMDBCastCopyWithImpl<$Res>
    implements $DomainTMDBCastCopyWith<$Res> {
  _$DomainTMDBCastCopyWithImpl(this._self, this._then);

  final DomainTMDBCast _self;
  final $Res Function(DomainTMDBCast) _then;

/// Create a copy of DomainTMDBCast
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? character = null,Object? profilePath = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,character: null == character ? _self.character : character // ignore: cast_nullable_to_non_nullable
as String,profilePath: freezed == profilePath ? _self.profilePath : profilePath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainTMDBCast].
extension DomainTMDBCastPatterns on DomainTMDBCast {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainTMDBCast value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainTMDBCast() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainTMDBCast value)  $default,){
final _that = this;
switch (_that) {
case _DomainTMDBCast():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainTMDBCast value)?  $default,){
final _that = this;
switch (_that) {
case _DomainTMDBCast() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String character,  String? profilePath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainTMDBCast() when $default != null:
return $default(_that.name,_that.character,_that.profilePath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String character,  String? profilePath)  $default,) {final _that = this;
switch (_that) {
case _DomainTMDBCast():
return $default(_that.name,_that.character,_that.profilePath);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String character,  String? profilePath)?  $default,) {final _that = this;
switch (_that) {
case _DomainTMDBCast() when $default != null:
return $default(_that.name,_that.character,_that.profilePath);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainTMDBCast implements DomainTMDBCast {
  const _DomainTMDBCast({required this.name, required this.character, this.profilePath});
  factory _DomainTMDBCast.fromJson(Map<String, dynamic> json) => _$DomainTMDBCastFromJson(json);

@override final  String name;
@override final  String character;
@override final  String? profilePath;

/// Create a copy of DomainTMDBCast
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainTMDBCastCopyWith<_DomainTMDBCast> get copyWith => __$DomainTMDBCastCopyWithImpl<_DomainTMDBCast>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainTMDBCastToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainTMDBCast&&(identical(other.name, name) || other.name == name)&&(identical(other.character, character) || other.character == character)&&(identical(other.profilePath, profilePath) || other.profilePath == profilePath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,character,profilePath);

@override
String toString() {
  return 'DomainTMDBCast(name: $name, character: $character, profilePath: $profilePath)';
}


}

/// @nodoc
abstract mixin class _$DomainTMDBCastCopyWith<$Res> implements $DomainTMDBCastCopyWith<$Res> {
  factory _$DomainTMDBCastCopyWith(_DomainTMDBCast value, $Res Function(_DomainTMDBCast) _then) = __$DomainTMDBCastCopyWithImpl;
@override @useResult
$Res call({
 String name, String character, String? profilePath
});




}
/// @nodoc
class __$DomainTMDBCastCopyWithImpl<$Res>
    implements _$DomainTMDBCastCopyWith<$Res> {
  __$DomainTMDBCastCopyWithImpl(this._self, this._then);

  final _DomainTMDBCast _self;
  final $Res Function(_DomainTMDBCast) _then;

/// Create a copy of DomainTMDBCast
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? character = null,Object? profilePath = freezed,}) {
  return _then(_DomainTMDBCast(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,character: null == character ? _self.character : character // ignore: cast_nullable_to_non_nullable
as String,profilePath: freezed == profilePath ? _self.profilePath : profilePath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
