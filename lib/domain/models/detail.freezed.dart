// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DomainDetail {

 int? get id; String get title; String? get cover; String? get desc; List<DomainEpisodeGroup>? get episodes; Map<String, String>? get headers; List<String> get downloaded; String get detailUrl; String get package;
/// Create a copy of DomainDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainDetailCopyWith<DomainDetail> get copyWith => _$DomainDetailCopyWithImpl<DomainDetail>(this as DomainDetail, _$identity);

  /// Serializes this DomainDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.cover, cover) || other.cover == cover)&&(identical(other.desc, desc) || other.desc == desc)&&const DeepCollectionEquality().equals(other.episodes, episodes)&&const DeepCollectionEquality().equals(other.headers, headers)&&const DeepCollectionEquality().equals(other.downloaded, downloaded)&&(identical(other.detailUrl, detailUrl) || other.detailUrl == detailUrl)&&(identical(other.package, package) || other.package == package));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,cover,desc,const DeepCollectionEquality().hash(episodes),const DeepCollectionEquality().hash(headers),const DeepCollectionEquality().hash(downloaded),detailUrl,package);

@override
String toString() {
  return 'DomainDetail(id: $id, title: $title, cover: $cover, desc: $desc, episodes: $episodes, headers: $headers, downloaded: $downloaded, detailUrl: $detailUrl, package: $package)';
}


}

/// @nodoc
abstract mixin class $DomainDetailCopyWith<$Res>  {
  factory $DomainDetailCopyWith(DomainDetail value, $Res Function(DomainDetail) _then) = _$DomainDetailCopyWithImpl;
@useResult
$Res call({
 int? id, String title, String? cover, String? desc, List<DomainEpisodeGroup>? episodes, Map<String, String>? headers, List<String> downloaded, String detailUrl, String package
});




}
/// @nodoc
class _$DomainDetailCopyWithImpl<$Res>
    implements $DomainDetailCopyWith<$Res> {
  _$DomainDetailCopyWithImpl(this._self, this._then);

  final DomainDetail _self;
  final $Res Function(DomainDetail) _then;

/// Create a copy of DomainDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? title = null,Object? cover = freezed,Object? desc = freezed,Object? episodes = freezed,Object? headers = freezed,Object? downloaded = null,Object? detailUrl = null,Object? package = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,cover: freezed == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as String?,desc: freezed == desc ? _self.desc : desc // ignore: cast_nullable_to_non_nullable
as String?,episodes: freezed == episodes ? _self.episodes : episodes // ignore: cast_nullable_to_non_nullable
as List<DomainEpisodeGroup>?,headers: freezed == headers ? _self.headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,downloaded: null == downloaded ? _self.downloaded : downloaded // ignore: cast_nullable_to_non_nullable
as List<String>,detailUrl: null == detailUrl ? _self.detailUrl : detailUrl // ignore: cast_nullable_to_non_nullable
as String,package: null == package ? _self.package : package // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainDetail].
extension DomainDetailPatterns on DomainDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainDetail value)  $default,){
final _that = this;
switch (_that) {
case _DomainDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainDetail value)?  $default,){
final _that = this;
switch (_that) {
case _DomainDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  String title,  String? cover,  String? desc,  List<DomainEpisodeGroup>? episodes,  Map<String, String>? headers,  List<String> downloaded,  String detailUrl,  String package)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainDetail() when $default != null:
return $default(_that.id,_that.title,_that.cover,_that.desc,_that.episodes,_that.headers,_that.downloaded,_that.detailUrl,_that.package);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  String title,  String? cover,  String? desc,  List<DomainEpisodeGroup>? episodes,  Map<String, String>? headers,  List<String> downloaded,  String detailUrl,  String package)  $default,) {final _that = this;
switch (_that) {
case _DomainDetail():
return $default(_that.id,_that.title,_that.cover,_that.desc,_that.episodes,_that.headers,_that.downloaded,_that.detailUrl,_that.package);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  String title,  String? cover,  String? desc,  List<DomainEpisodeGroup>? episodes,  Map<String, String>? headers,  List<String> downloaded,  String detailUrl,  String package)?  $default,) {final _that = this;
switch (_that) {
case _DomainDetail() when $default != null:
return $default(_that.id,_that.title,_that.cover,_that.desc,_that.episodes,_that.headers,_that.downloaded,_that.detailUrl,_that.package);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainDetail implements DomainDetail {
  const _DomainDetail({this.id, required this.title, this.cover, this.desc, final  List<DomainEpisodeGroup>? episodes, final  Map<String, String>? headers, final  List<String> downloaded = const [], required this.detailUrl, required this.package}): _episodes = episodes,_headers = headers,_downloaded = downloaded;
  factory _DomainDetail.fromJson(Map<String, dynamic> json) => _$DomainDetailFromJson(json);

@override final  int? id;
@override final  String title;
@override final  String? cover;
@override final  String? desc;
 final  List<DomainEpisodeGroup>? _episodes;
@override List<DomainEpisodeGroup>? get episodes {
  final value = _episodes;
  if (value == null) return null;
  if (_episodes is EqualUnmodifiableListView) return _episodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  Map<String, String>? _headers;
@override Map<String, String>? get headers {
  final value = _headers;
  if (value == null) return null;
  if (_headers is EqualUnmodifiableMapView) return _headers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<String> _downloaded;
@override@JsonKey() List<String> get downloaded {
  if (_downloaded is EqualUnmodifiableListView) return _downloaded;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_downloaded);
}

@override final  String detailUrl;
@override final  String package;

/// Create a copy of DomainDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainDetailCopyWith<_DomainDetail> get copyWith => __$DomainDetailCopyWithImpl<_DomainDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.cover, cover) || other.cover == cover)&&(identical(other.desc, desc) || other.desc == desc)&&const DeepCollectionEquality().equals(other._episodes, _episodes)&&const DeepCollectionEquality().equals(other._headers, _headers)&&const DeepCollectionEquality().equals(other._downloaded, _downloaded)&&(identical(other.detailUrl, detailUrl) || other.detailUrl == detailUrl)&&(identical(other.package, package) || other.package == package));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,cover,desc,const DeepCollectionEquality().hash(_episodes),const DeepCollectionEquality().hash(_headers),const DeepCollectionEquality().hash(_downloaded),detailUrl,package);

@override
String toString() {
  return 'DomainDetail(id: $id, title: $title, cover: $cover, desc: $desc, episodes: $episodes, headers: $headers, downloaded: $downloaded, detailUrl: $detailUrl, package: $package)';
}


}

/// @nodoc
abstract mixin class _$DomainDetailCopyWith<$Res> implements $DomainDetailCopyWith<$Res> {
  factory _$DomainDetailCopyWith(_DomainDetail value, $Res Function(_DomainDetail) _then) = __$DomainDetailCopyWithImpl;
@override @useResult
$Res call({
 int? id, String title, String? cover, String? desc, List<DomainEpisodeGroup>? episodes, Map<String, String>? headers, List<String> downloaded, String detailUrl, String package
});




}
/// @nodoc
class __$DomainDetailCopyWithImpl<$Res>
    implements _$DomainDetailCopyWith<$Res> {
  __$DomainDetailCopyWithImpl(this._self, this._then);

  final _DomainDetail _self;
  final $Res Function(_DomainDetail) _then;

/// Create a copy of DomainDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? title = null,Object? cover = freezed,Object? desc = freezed,Object? episodes = freezed,Object? headers = freezed,Object? downloaded = null,Object? detailUrl = null,Object? package = null,}) {
  return _then(_DomainDetail(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,cover: freezed == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as String?,desc: freezed == desc ? _self.desc : desc // ignore: cast_nullable_to_non_nullable
as String?,episodes: freezed == episodes ? _self._episodes : episodes // ignore: cast_nullable_to_non_nullable
as List<DomainEpisodeGroup>?,headers: freezed == headers ? _self._headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,downloaded: null == downloaded ? _self._downloaded : downloaded // ignore: cast_nullable_to_non_nullable
as List<String>,detailUrl: null == detailUrl ? _self.detailUrl : detailUrl // ignore: cast_nullable_to_non_nullable
as String,package: null == package ? _self.package : package // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$DomainEpisodeGroup {

 String? get name; List<DomainEpisode> get episodes;
/// Create a copy of DomainEpisodeGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainEpisodeGroupCopyWith<DomainEpisodeGroup> get copyWith => _$DomainEpisodeGroupCopyWithImpl<DomainEpisodeGroup>(this as DomainEpisodeGroup, _$identity);

  /// Serializes this DomainEpisodeGroup to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainEpisodeGroup&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.episodes, episodes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,const DeepCollectionEquality().hash(episodes));

@override
String toString() {
  return 'DomainEpisodeGroup(name: $name, episodes: $episodes)';
}


}

/// @nodoc
abstract mixin class $DomainEpisodeGroupCopyWith<$Res>  {
  factory $DomainEpisodeGroupCopyWith(DomainEpisodeGroup value, $Res Function(DomainEpisodeGroup) _then) = _$DomainEpisodeGroupCopyWithImpl;
@useResult
$Res call({
 String? name, List<DomainEpisode> episodes
});




}
/// @nodoc
class _$DomainEpisodeGroupCopyWithImpl<$Res>
    implements $DomainEpisodeGroupCopyWith<$Res> {
  _$DomainEpisodeGroupCopyWithImpl(this._self, this._then);

  final DomainEpisodeGroup _self;
  final $Res Function(DomainEpisodeGroup) _then;

/// Create a copy of DomainEpisodeGroup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? episodes = null,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,episodes: null == episodes ? _self.episodes : episodes // ignore: cast_nullable_to_non_nullable
as List<DomainEpisode>,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainEpisodeGroup].
extension DomainEpisodeGroupPatterns on DomainEpisodeGroup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainEpisodeGroup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainEpisodeGroup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainEpisodeGroup value)  $default,){
final _that = this;
switch (_that) {
case _DomainEpisodeGroup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainEpisodeGroup value)?  $default,){
final _that = this;
switch (_that) {
case _DomainEpisodeGroup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  List<DomainEpisode> episodes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainEpisodeGroup() when $default != null:
return $default(_that.name,_that.episodes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  List<DomainEpisode> episodes)  $default,) {final _that = this;
switch (_that) {
case _DomainEpisodeGroup():
return $default(_that.name,_that.episodes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  List<DomainEpisode> episodes)?  $default,) {final _that = this;
switch (_that) {
case _DomainEpisodeGroup() when $default != null:
return $default(_that.name,_that.episodes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainEpisodeGroup implements DomainEpisodeGroup {
  const _DomainEpisodeGroup({this.name, required final  List<DomainEpisode> episodes}): _episodes = episodes;
  factory _DomainEpisodeGroup.fromJson(Map<String, dynamic> json) => _$DomainEpisodeGroupFromJson(json);

@override final  String? name;
 final  List<DomainEpisode> _episodes;
@override List<DomainEpisode> get episodes {
  if (_episodes is EqualUnmodifiableListView) return _episodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_episodes);
}


/// Create a copy of DomainEpisodeGroup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainEpisodeGroupCopyWith<_DomainEpisodeGroup> get copyWith => __$DomainEpisodeGroupCopyWithImpl<_DomainEpisodeGroup>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainEpisodeGroupToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainEpisodeGroup&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._episodes, _episodes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,const DeepCollectionEquality().hash(_episodes));

@override
String toString() {
  return 'DomainEpisodeGroup(name: $name, episodes: $episodes)';
}


}

/// @nodoc
abstract mixin class _$DomainEpisodeGroupCopyWith<$Res> implements $DomainEpisodeGroupCopyWith<$Res> {
  factory _$DomainEpisodeGroupCopyWith(_DomainEpisodeGroup value, $Res Function(_DomainEpisodeGroup) _then) = __$DomainEpisodeGroupCopyWithImpl;
@override @useResult
$Res call({
 String? name, List<DomainEpisode> episodes
});




}
/// @nodoc
class __$DomainEpisodeGroupCopyWithImpl<$Res>
    implements _$DomainEpisodeGroupCopyWith<$Res> {
  __$DomainEpisodeGroupCopyWithImpl(this._self, this._then);

  final _DomainEpisodeGroup _self;
  final $Res Function(_DomainEpisodeGroup) _then;

/// Create a copy of DomainEpisodeGroup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? episodes = null,}) {
  return _then(_DomainEpisodeGroup(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,episodes: null == episodes ? _self._episodes : episodes // ignore: cast_nullable_to_non_nullable
as List<DomainEpisode>,
  ));
}


}


/// @nodoc
mixin _$DomainEpisode {

 String? get name; String get url;
/// Create a copy of DomainEpisode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainEpisodeCopyWith<DomainEpisode> get copyWith => _$DomainEpisodeCopyWithImpl<DomainEpisode>(this as DomainEpisode, _$identity);

  /// Serializes this DomainEpisode to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainEpisode&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,url);

@override
String toString() {
  return 'DomainEpisode(name: $name, url: $url)';
}


}

/// @nodoc
abstract mixin class $DomainEpisodeCopyWith<$Res>  {
  factory $DomainEpisodeCopyWith(DomainEpisode value, $Res Function(DomainEpisode) _then) = _$DomainEpisodeCopyWithImpl;
@useResult
$Res call({
 String? name, String url
});




}
/// @nodoc
class _$DomainEpisodeCopyWithImpl<$Res>
    implements $DomainEpisodeCopyWith<$Res> {
  _$DomainEpisodeCopyWithImpl(this._self, this._then);

  final DomainEpisode _self;
  final $Res Function(DomainEpisode) _then;

/// Create a copy of DomainEpisode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? url = null,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainEpisode].
extension DomainEpisodePatterns on DomainEpisode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainEpisode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainEpisode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainEpisode value)  $default,){
final _that = this;
switch (_that) {
case _DomainEpisode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainEpisode value)?  $default,){
final _that = this;
switch (_that) {
case _DomainEpisode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainEpisode() when $default != null:
return $default(_that.name,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  String url)  $default,) {final _that = this;
switch (_that) {
case _DomainEpisode():
return $default(_that.name,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  String url)?  $default,) {final _that = this;
switch (_that) {
case _DomainEpisode() when $default != null:
return $default(_that.name,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainEpisode implements DomainEpisode {
  const _DomainEpisode({this.name, required this.url});
  factory _DomainEpisode.fromJson(Map<String, dynamic> json) => _$DomainEpisodeFromJson(json);

@override final  String? name;
@override final  String url;

/// Create a copy of DomainEpisode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainEpisodeCopyWith<_DomainEpisode> get copyWith => __$DomainEpisodeCopyWithImpl<_DomainEpisode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainEpisodeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainEpisode&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,url);

@override
String toString() {
  return 'DomainEpisode(name: $name, url: $url)';
}


}

/// @nodoc
abstract mixin class _$DomainEpisodeCopyWith<$Res> implements $DomainEpisodeCopyWith<$Res> {
  factory _$DomainEpisodeCopyWith(_DomainEpisode value, $Res Function(_DomainEpisode) _then) = __$DomainEpisodeCopyWithImpl;
@override @useResult
$Res call({
 String? name, String url
});




}
/// @nodoc
class __$DomainEpisodeCopyWithImpl<$Res>
    implements _$DomainEpisodeCopyWith<$Res> {
  __$DomainEpisodeCopyWithImpl(this._self, this._then);

  final _DomainEpisode _self;
  final $Res Function(_DomainEpisode) _then;

/// Create a copy of DomainEpisode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? url = null,}) {
  return _then(_DomainEpisode(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
