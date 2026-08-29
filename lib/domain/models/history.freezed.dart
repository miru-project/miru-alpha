// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'history.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DomainHistoryItem {

 String get id; String get package; String get detailUrl; String get title; String? get cover; int get episodeIndex; String? get episodeTitle; int get watchedDuration; int get totalDuration; double get progress; DateTime get watchedAt; String? get lastPosition;
/// Create a copy of DomainHistoryItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainHistoryItemCopyWith<DomainHistoryItem> get copyWith => _$DomainHistoryItemCopyWithImpl<DomainHistoryItem>(this as DomainHistoryItem, _$identity);

  /// Serializes this DomainHistoryItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainHistoryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.package, package) || other.package == package)&&(identical(other.detailUrl, detailUrl) || other.detailUrl == detailUrl)&&(identical(other.title, title) || other.title == title)&&(identical(other.cover, cover) || other.cover == cover)&&(identical(other.episodeIndex, episodeIndex) || other.episodeIndex == episodeIndex)&&(identical(other.episodeTitle, episodeTitle) || other.episodeTitle == episodeTitle)&&(identical(other.watchedDuration, watchedDuration) || other.watchedDuration == watchedDuration)&&(identical(other.totalDuration, totalDuration) || other.totalDuration == totalDuration)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.watchedAt, watchedAt) || other.watchedAt == watchedAt)&&(identical(other.lastPosition, lastPosition) || other.lastPosition == lastPosition));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,package,detailUrl,title,cover,episodeIndex,episodeTitle,watchedDuration,totalDuration,progress,watchedAt,lastPosition);

@override
String toString() {
  return 'DomainHistoryItem(id: $id, package: $package, detailUrl: $detailUrl, title: $title, cover: $cover, episodeIndex: $episodeIndex, episodeTitle: $episodeTitle, watchedDuration: $watchedDuration, totalDuration: $totalDuration, progress: $progress, watchedAt: $watchedAt, lastPosition: $lastPosition)';
}


}

/// @nodoc
abstract mixin class $DomainHistoryItemCopyWith<$Res>  {
  factory $DomainHistoryItemCopyWith(DomainHistoryItem value, $Res Function(DomainHistoryItem) _then) = _$DomainHistoryItemCopyWithImpl;
@useResult
$Res call({
 String id, String package, String detailUrl, String title, String? cover, int episodeIndex, String? episodeTitle, int watchedDuration, int totalDuration, double progress, DateTime watchedAt, String? lastPosition
});




}
/// @nodoc
class _$DomainHistoryItemCopyWithImpl<$Res>
    implements $DomainHistoryItemCopyWith<$Res> {
  _$DomainHistoryItemCopyWithImpl(this._self, this._then);

  final DomainHistoryItem _self;
  final $Res Function(DomainHistoryItem) _then;

/// Create a copy of DomainHistoryItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? package = null,Object? detailUrl = null,Object? title = null,Object? cover = freezed,Object? episodeIndex = null,Object? episodeTitle = freezed,Object? watchedDuration = null,Object? totalDuration = null,Object? progress = null,Object? watchedAt = null,Object? lastPosition = freezed,}) {
  return _then(DomainHistoryItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,package: null == package ? _self.package : package // ignore: cast_nullable_to_non_nullable
as String,detailUrl: null == detailUrl ? _self.detailUrl : detailUrl // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,cover: freezed == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as String?,episodeIndex: null == episodeIndex ? _self.episodeIndex : episodeIndex // ignore: cast_nullable_to_non_nullable
as int,episodeTitle: freezed == episodeTitle ? _self.episodeTitle : episodeTitle // ignore: cast_nullable_to_non_nullable
as String?,watchedDuration: null == watchedDuration ? _self.watchedDuration : watchedDuration // ignore: cast_nullable_to_non_nullable
as int,totalDuration: null == totalDuration ? _self.totalDuration : totalDuration // ignore: cast_nullable_to_non_nullable
as int,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,watchedAt: null == watchedAt ? _self.watchedAt : watchedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastPosition: freezed == lastPosition ? _self.lastPosition : lastPosition // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainHistoryItem].
extension DomainHistoryItemPatterns on DomainHistoryItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainHistoryItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainHistoryItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainHistoryItem value)  $default,){
final _that = this;
switch (_that) {
case _DomainHistoryItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainHistoryItem value)?  $default,){
final _that = this;
switch (_that) {
case _DomainHistoryItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String package,  String detailUrl,  String title,  String? cover,  int episodeIndex,  String? episodeTitle,  int watchedDuration,  int totalDuration,  double progress,  DateTime watchedAt,  String? lastPosition)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainHistoryItem() when $default != null:
return $default(_that.id,_that.package,_that.detailUrl,_that.title,_that.cover,_that.episodeIndex,_that.episodeTitle,_that.watchedDuration,_that.totalDuration,_that.progress,_that.watchedAt,_that.lastPosition);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String package,  String detailUrl,  String title,  String? cover,  int episodeIndex,  String? episodeTitle,  int watchedDuration,  int totalDuration,  double progress,  DateTime watchedAt,  String? lastPosition)  $default,) {final _that = this;
switch (_that) {
case _DomainHistoryItem():
return $default(_that.id,_that.package,_that.detailUrl,_that.title,_that.cover,_that.episodeIndex,_that.episodeTitle,_that.watchedDuration,_that.totalDuration,_that.progress,_that.watchedAt,_that.lastPosition);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String package,  String detailUrl,  String title,  String? cover,  int episodeIndex,  String? episodeTitle,  int watchedDuration,  int totalDuration,  double progress,  DateTime watchedAt,  String? lastPosition)?  $default,) {final _that = this;
switch (_that) {
case _DomainHistoryItem() when $default != null:
return $default(_that.id,_that.package,_that.detailUrl,_that.title,_that.cover,_that.episodeIndex,_that.episodeTitle,_that.watchedDuration,_that.totalDuration,_that.progress,_that.watchedAt,_that.lastPosition);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainHistoryItem implements DomainHistoryItem {
  const _DomainHistoryItem({required this.id, required this.package, required this.detailUrl, required this.title, this.cover, required this.episodeIndex, this.episodeTitle, required this.watchedDuration, required this.totalDuration, required this.progress, required this.watchedAt, this.lastPosition});
  factory _DomainHistoryItem.fromJson(Map<String, dynamic> json) => _$DomainHistoryItemFromJson(json);

@override final  String id;
@override final  String package;
@override final  String detailUrl;
@override final  String title;
@override final  String? cover;
@override final  int episodeIndex;
@override final  String? episodeTitle;
@override final  int watchedDuration;
@override final  int totalDuration;
@override final  double progress;
@override final  DateTime watchedAt;
@override final  String? lastPosition;

/// Create a copy of DomainHistoryItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainHistoryItemCopyWith<_DomainHistoryItem> get copyWith => __$DomainHistoryItemCopyWithImpl<_DomainHistoryItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainHistoryItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainHistoryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.package, package) || other.package == package)&&(identical(other.detailUrl, detailUrl) || other.detailUrl == detailUrl)&&(identical(other.title, title) || other.title == title)&&(identical(other.cover, cover) || other.cover == cover)&&(identical(other.episodeIndex, episodeIndex) || other.episodeIndex == episodeIndex)&&(identical(other.episodeTitle, episodeTitle) || other.episodeTitle == episodeTitle)&&(identical(other.watchedDuration, watchedDuration) || other.watchedDuration == watchedDuration)&&(identical(other.totalDuration, totalDuration) || other.totalDuration == totalDuration)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.watchedAt, watchedAt) || other.watchedAt == watchedAt)&&(identical(other.lastPosition, lastPosition) || other.lastPosition == lastPosition));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,package,detailUrl,title,cover,episodeIndex,episodeTitle,watchedDuration,totalDuration,progress,watchedAt,lastPosition);

@override
String toString() {
  return 'DomainHistoryItem(id: $id, package: $package, detailUrl: $detailUrl, title: $title, cover: $cover, episodeIndex: $episodeIndex, episodeTitle: $episodeTitle, watchedDuration: $watchedDuration, totalDuration: $totalDuration, progress: $progress, watchedAt: $watchedAt, lastPosition: $lastPosition)';
}


}

/// @nodoc
abstract mixin class _$DomainHistoryItemCopyWith<$Res> implements $DomainHistoryItemCopyWith<$Res> {
  factory _$DomainHistoryItemCopyWith(_DomainHistoryItem value, $Res Function(_DomainHistoryItem) _then) = __$DomainHistoryItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String package, String detailUrl, String title, String? cover, int episodeIndex, String? episodeTitle, int watchedDuration, int totalDuration, double progress, DateTime watchedAt, String? lastPosition
});




}
/// @nodoc
class __$DomainHistoryItemCopyWithImpl<$Res>
    implements _$DomainHistoryItemCopyWith<$Res> {
  __$DomainHistoryItemCopyWithImpl(this._self, this._then);

  final _DomainHistoryItem _self;
  final $Res Function(_DomainHistoryItem) _then;

/// Create a copy of DomainHistoryItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? package = null,Object? detailUrl = null,Object? title = null,Object? cover = freezed,Object? episodeIndex = null,Object? episodeTitle = freezed,Object? watchedDuration = null,Object? totalDuration = null,Object? progress = null,Object? watchedAt = null,Object? lastPosition = freezed,}) {
  return _then(_DomainHistoryItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,package: null == package ? _self.package : package // ignore: cast_nullable_to_non_nullable
as String,detailUrl: null == detailUrl ? _self.detailUrl : detailUrl // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,cover: freezed == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as String?,episodeIndex: null == episodeIndex ? _self.episodeIndex : episodeIndex // ignore: cast_nullable_to_non_nullable
as int,episodeTitle: freezed == episodeTitle ? _self.episodeTitle : episodeTitle // ignore: cast_nullable_to_non_nullable
as String?,watchedDuration: null == watchedDuration ? _self.watchedDuration : watchedDuration // ignore: cast_nullable_to_non_nullable
as int,totalDuration: null == totalDuration ? _self.totalDuration : totalDuration // ignore: cast_nullable_to_non_nullable
as int,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,watchedAt: null == watchedAt ? _self.watchedAt : watchedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastPosition: freezed == lastPosition ? _self.lastPosition : lastPosition // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
