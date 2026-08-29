// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'watch.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DomainWatchResult {

 DomainWatchData get data; DomainV2Watch? get v2watch;
/// Create a copy of DomainWatchResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainWatchResultCopyWith<DomainWatchResult> get copyWith => _$DomainWatchResultCopyWithImpl<DomainWatchResult>(this as DomainWatchResult, _$identity);

  /// Serializes this DomainWatchResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainWatchResult&&(identical(other.data, data) || other.data == data)&&(identical(other.v2watch, v2watch) || other.v2watch == v2watch));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,data,v2watch);

@override
String toString() {
  return 'DomainWatchResult(data: $data, v2watch: $v2watch)';
}


}

/// @nodoc
abstract mixin class $DomainWatchResultCopyWith<$Res>  {
  factory $DomainWatchResultCopyWith(DomainWatchResult value, $Res Function(DomainWatchResult) _then) = _$DomainWatchResultCopyWithImpl;
@useResult
$Res call({
 DomainWatchData data, DomainV2Watch? v2watch
});


$DomainWatchDataCopyWith<$Res> get data;$DomainV2WatchCopyWith<$Res>? get v2watch;

}
/// @nodoc
class _$DomainWatchResultCopyWithImpl<$Res>
    implements $DomainWatchResultCopyWith<$Res> {
  _$DomainWatchResultCopyWithImpl(this._self, this._then);

  final DomainWatchResult _self;
  final $Res Function(DomainWatchResult) _then;

/// Create a copy of DomainWatchResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,Object? v2watch = freezed,}) {
  return _then(DomainWatchResult(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as DomainWatchData,v2watch: freezed == v2watch ? _self.v2watch : v2watch // ignore: cast_nullable_to_non_nullable
as DomainV2Watch?,
  ));
}
/// Create a copy of DomainWatchResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DomainWatchDataCopyWith<$Res> get data {
  
  return $DomainWatchDataCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}/// Create a copy of DomainWatchResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DomainV2WatchCopyWith<$Res>? get v2watch {
    if (_self.v2watch == null) {
    return null;
  }

  return $DomainV2WatchCopyWith<$Res>(_self.v2watch!, (value) {
    return _then(_self.copyWith(v2watch: value));
  });
}
}


/// Adds pattern-matching-related methods to [DomainWatchResult].
extension DomainWatchResultPatterns on DomainWatchResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainWatchResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainWatchResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainWatchResult value)  $default,){
final _that = this;
switch (_that) {
case _DomainWatchResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainWatchResult value)?  $default,){
final _that = this;
switch (_that) {
case _DomainWatchResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DomainWatchData data,  DomainV2Watch? v2watch)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainWatchResult() when $default != null:
return $default(_that.data,_that.v2watch);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DomainWatchData data,  DomainV2Watch? v2watch)  $default,) {final _that = this;
switch (_that) {
case _DomainWatchResult():
return $default(_that.data,_that.v2watch);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DomainWatchData data,  DomainV2Watch? v2watch)?  $default,) {final _that = this;
switch (_that) {
case _DomainWatchResult() when $default != null:
return $default(_that.data,_that.v2watch);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainWatchResult implements DomainWatchResult {
  const _DomainWatchResult({required this.data, this.v2watch});
  factory _DomainWatchResult.fromJson(Map<String, dynamic> json) => _$DomainWatchResultFromJson(json);

@override final  DomainWatchData data;
@override final  DomainV2Watch? v2watch;

/// Create a copy of DomainWatchResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainWatchResultCopyWith<_DomainWatchResult> get copyWith => __$DomainWatchResultCopyWithImpl<_DomainWatchResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainWatchResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainWatchResult&&(identical(other.data, data) || other.data == data)&&(identical(other.v2watch, v2watch) || other.v2watch == v2watch));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,data,v2watch);

@override
String toString() {
  return 'DomainWatchResult(data: $data, v2watch: $v2watch)';
}


}

/// @nodoc
abstract mixin class _$DomainWatchResultCopyWith<$Res> implements $DomainWatchResultCopyWith<$Res> {
  factory _$DomainWatchResultCopyWith(_DomainWatchResult value, $Res Function(_DomainWatchResult) _then) = __$DomainWatchResultCopyWithImpl;
@override @useResult
$Res call({
 DomainWatchData data, DomainV2Watch? v2watch
});


@override $DomainWatchDataCopyWith<$Res> get data;@override $DomainV2WatchCopyWith<$Res>? get v2watch;

}
/// @nodoc
class __$DomainWatchResultCopyWithImpl<$Res>
    implements _$DomainWatchResultCopyWith<$Res> {
  __$DomainWatchResultCopyWithImpl(this._self, this._then);

  final _DomainWatchResult _self;
  final $Res Function(_DomainWatchResult) _then;

/// Create a copy of DomainWatchResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,Object? v2watch = freezed,}) {
  return _then(_DomainWatchResult(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as DomainWatchData,v2watch: freezed == v2watch ? _self.v2watch : v2watch // ignore: cast_nullable_to_non_nullable
as DomainV2Watch?,
  ));
}

/// Create a copy of DomainWatchResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DomainWatchDataCopyWith<$Res> get data {
  
  return $DomainWatchDataCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}/// Create a copy of DomainWatchResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DomainV2WatchCopyWith<$Res>? get v2watch {
    if (_self.v2watch == null) {
    return null;
  }

  return $DomainV2WatchCopyWith<$Res>(_self.v2watch!, (value) {
    return _then(_self.copyWith(v2watch: value));
  });
}
}


/// @nodoc
mixin _$DomainWatchData {

 DomainBangumiWatch? get bangumi; DomainMangaWatch? get manga; DomainNovelWatch? get novel;
/// Create a copy of DomainWatchData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainWatchDataCopyWith<DomainWatchData> get copyWith => _$DomainWatchDataCopyWithImpl<DomainWatchData>(this as DomainWatchData, _$identity);

  /// Serializes this DomainWatchData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainWatchData&&(identical(other.bangumi, bangumi) || other.bangumi == bangumi)&&(identical(other.manga, manga) || other.manga == manga)&&(identical(other.novel, novel) || other.novel == novel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bangumi,manga,novel);

@override
String toString() {
  return 'DomainWatchData(bangumi: $bangumi, manga: $manga, novel: $novel)';
}


}

/// @nodoc
abstract mixin class $DomainWatchDataCopyWith<$Res>  {
  factory $DomainWatchDataCopyWith(DomainWatchData value, $Res Function(DomainWatchData) _then) = _$DomainWatchDataCopyWithImpl;
@useResult
$Res call({
 DomainBangumiWatch? bangumi, DomainMangaWatch? manga, DomainNovelWatch? novel
});


$DomainBangumiWatchCopyWith<$Res>? get bangumi;$DomainMangaWatchCopyWith<$Res>? get manga;$DomainNovelWatchCopyWith<$Res>? get novel;

}
/// @nodoc
class _$DomainWatchDataCopyWithImpl<$Res>
    implements $DomainWatchDataCopyWith<$Res> {
  _$DomainWatchDataCopyWithImpl(this._self, this._then);

  final DomainWatchData _self;
  final $Res Function(DomainWatchData) _then;

/// Create a copy of DomainWatchData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bangumi = freezed,Object? manga = freezed,Object? novel = freezed,}) {
  return _then(DomainWatchData(
bangumi: freezed == bangumi ? _self.bangumi : bangumi // ignore: cast_nullable_to_non_nullable
as DomainBangumiWatch?,manga: freezed == manga ? _self.manga : manga // ignore: cast_nullable_to_non_nullable
as DomainMangaWatch?,novel: freezed == novel ? _self.novel : novel // ignore: cast_nullable_to_non_nullable
as DomainNovelWatch?,
  ));
}
/// Create a copy of DomainWatchData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DomainBangumiWatchCopyWith<$Res>? get bangumi {
    if (_self.bangumi == null) {
    return null;
  }

  return $DomainBangumiWatchCopyWith<$Res>(_self.bangumi!, (value) {
    return _then(_self.copyWith(bangumi: value));
  });
}/// Create a copy of DomainWatchData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DomainMangaWatchCopyWith<$Res>? get manga {
    if (_self.manga == null) {
    return null;
  }

  return $DomainMangaWatchCopyWith<$Res>(_self.manga!, (value) {
    return _then(_self.copyWith(manga: value));
  });
}/// Create a copy of DomainWatchData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DomainNovelWatchCopyWith<$Res>? get novel {
    if (_self.novel == null) {
    return null;
  }

  return $DomainNovelWatchCopyWith<$Res>(_self.novel!, (value) {
    return _then(_self.copyWith(novel: value));
  });
}
}


/// Adds pattern-matching-related methods to [DomainWatchData].
extension DomainWatchDataPatterns on DomainWatchData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainWatchData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainWatchData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainWatchData value)  $default,){
final _that = this;
switch (_that) {
case _DomainWatchData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainWatchData value)?  $default,){
final _that = this;
switch (_that) {
case _DomainWatchData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DomainBangumiWatch? bangumi,  DomainMangaWatch? manga,  DomainNovelWatch? novel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainWatchData() when $default != null:
return $default(_that.bangumi,_that.manga,_that.novel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DomainBangumiWatch? bangumi,  DomainMangaWatch? manga,  DomainNovelWatch? novel)  $default,) {final _that = this;
switch (_that) {
case _DomainWatchData():
return $default(_that.bangumi,_that.manga,_that.novel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DomainBangumiWatch? bangumi,  DomainMangaWatch? manga,  DomainNovelWatch? novel)?  $default,) {final _that = this;
switch (_that) {
case _DomainWatchData() when $default != null:
return $default(_that.bangumi,_that.manga,_that.novel);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainWatchData implements DomainWatchData {
  const _DomainWatchData({this.bangumi, this.manga, this.novel});
  factory _DomainWatchData.fromJson(Map<String, dynamic> json) => _$DomainWatchDataFromJson(json);

@override final  DomainBangumiWatch? bangumi;
@override final  DomainMangaWatch? manga;
@override final  DomainNovelWatch? novel;

/// Create a copy of DomainWatchData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainWatchDataCopyWith<_DomainWatchData> get copyWith => __$DomainWatchDataCopyWithImpl<_DomainWatchData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainWatchDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainWatchData&&(identical(other.bangumi, bangumi) || other.bangumi == bangumi)&&(identical(other.manga, manga) || other.manga == manga)&&(identical(other.novel, novel) || other.novel == novel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bangumi,manga,novel);

@override
String toString() {
  return 'DomainWatchData(bangumi: $bangumi, manga: $manga, novel: $novel)';
}


}

/// @nodoc
abstract mixin class _$DomainWatchDataCopyWith<$Res> implements $DomainWatchDataCopyWith<$Res> {
  factory _$DomainWatchDataCopyWith(_DomainWatchData value, $Res Function(_DomainWatchData) _then) = __$DomainWatchDataCopyWithImpl;
@override @useResult
$Res call({
 DomainBangumiWatch? bangumi, DomainMangaWatch? manga, DomainNovelWatch? novel
});


@override $DomainBangumiWatchCopyWith<$Res>? get bangumi;@override $DomainMangaWatchCopyWith<$Res>? get manga;@override $DomainNovelWatchCopyWith<$Res>? get novel;

}
/// @nodoc
class __$DomainWatchDataCopyWithImpl<$Res>
    implements _$DomainWatchDataCopyWith<$Res> {
  __$DomainWatchDataCopyWithImpl(this._self, this._then);

  final _DomainWatchData _self;
  final $Res Function(_DomainWatchData) _then;

/// Create a copy of DomainWatchData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bangumi = freezed,Object? manga = freezed,Object? novel = freezed,}) {
  return _then(_DomainWatchData(
bangumi: freezed == bangumi ? _self.bangumi : bangumi // ignore: cast_nullable_to_non_nullable
as DomainBangumiWatch?,manga: freezed == manga ? _self.manga : manga // ignore: cast_nullable_to_non_nullable
as DomainMangaWatch?,novel: freezed == novel ? _self.novel : novel // ignore: cast_nullable_to_non_nullable
as DomainNovelWatch?,
  ));
}

/// Create a copy of DomainWatchData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DomainBangumiWatchCopyWith<$Res>? get bangumi {
    if (_self.bangumi == null) {
    return null;
  }

  return $DomainBangumiWatchCopyWith<$Res>(_self.bangumi!, (value) {
    return _then(_self.copyWith(bangumi: value));
  });
}/// Create a copy of DomainWatchData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DomainMangaWatchCopyWith<$Res>? get manga {
    if (_self.manga == null) {
    return null;
  }

  return $DomainMangaWatchCopyWith<$Res>(_self.manga!, (value) {
    return _then(_self.copyWith(manga: value));
  });
}/// Create a copy of DomainWatchData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DomainNovelWatchCopyWith<$Res>? get novel {
    if (_self.novel == null) {
    return null;
  }

  return $DomainNovelWatchCopyWith<$Res>(_self.novel!, (value) {
    return _then(_self.copyWith(novel: value));
  });
}
}


/// @nodoc
mixin _$DomainBangumiWatch {

 String? get type; String? get url; List<DomainBangumiWatchSubtitle>? get subtitles; Map<String, String>? get headers; DomainBangumiTorrent? get torrent;
/// Create a copy of DomainBangumiWatch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainBangumiWatchCopyWith<DomainBangumiWatch> get copyWith => _$DomainBangumiWatchCopyWithImpl<DomainBangumiWatch>(this as DomainBangumiWatch, _$identity);

  /// Serializes this DomainBangumiWatch to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainBangumiWatch&&(identical(other.type, type) || other.type == type)&&(identical(other.url, url) || other.url == url)&&const DeepCollectionEquality().equals(other.subtitles, subtitles)&&const DeepCollectionEquality().equals(other.headers, headers)&&(identical(other.torrent, torrent) || other.torrent == torrent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,url,const DeepCollectionEquality().hash(subtitles),const DeepCollectionEquality().hash(headers),torrent);

@override
String toString() {
  return 'DomainBangumiWatch(type: $type, url: $url, subtitles: $subtitles, headers: $headers, torrent: $torrent)';
}


}

/// @nodoc
abstract mixin class $DomainBangumiWatchCopyWith<$Res>  {
  factory $DomainBangumiWatchCopyWith(DomainBangumiWatch value, $Res Function(DomainBangumiWatch) _then) = _$DomainBangumiWatchCopyWithImpl;
@useResult
$Res call({
 String? type, String? url, List<DomainBangumiWatchSubtitle>? subtitles, Map<String, String>? headers, DomainBangumiTorrent? torrent
});


$DomainBangumiTorrentCopyWith<$Res>? get torrent;

}
/// @nodoc
class _$DomainBangumiWatchCopyWithImpl<$Res>
    implements $DomainBangumiWatchCopyWith<$Res> {
  _$DomainBangumiWatchCopyWithImpl(this._self, this._then);

  final DomainBangumiWatch _self;
  final $Res Function(DomainBangumiWatch) _then;

/// Create a copy of DomainBangumiWatch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = freezed,Object? url = freezed,Object? subtitles = freezed,Object? headers = freezed,Object? torrent = freezed,}) {
  return _then(DomainBangumiWatch(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,subtitles: freezed == subtitles ? _self.subtitles : subtitles // ignore: cast_nullable_to_non_nullable
as List<DomainBangumiWatchSubtitle>?,headers: freezed == headers ? _self.headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,torrent: freezed == torrent ? _self.torrent : torrent // ignore: cast_nullable_to_non_nullable
as DomainBangumiTorrent?,
  ));
}
/// Create a copy of DomainBangumiWatch
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DomainBangumiTorrentCopyWith<$Res>? get torrent {
    if (_self.torrent == null) {
    return null;
  }

  return $DomainBangumiTorrentCopyWith<$Res>(_self.torrent!, (value) {
    return _then(_self.copyWith(torrent: value));
  });
}
}


/// Adds pattern-matching-related methods to [DomainBangumiWatch].
extension DomainBangumiWatchPatterns on DomainBangumiWatch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainBangumiWatch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainBangumiWatch() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainBangumiWatch value)  $default,){
final _that = this;
switch (_that) {
case _DomainBangumiWatch():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainBangumiWatch value)?  $default,){
final _that = this;
switch (_that) {
case _DomainBangumiWatch() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? type,  String? url,  List<DomainBangumiWatchSubtitle>? subtitles,  Map<String, String>? headers,  DomainBangumiTorrent? torrent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainBangumiWatch() when $default != null:
return $default(_that.type,_that.url,_that.subtitles,_that.headers,_that.torrent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? type,  String? url,  List<DomainBangumiWatchSubtitle>? subtitles,  Map<String, String>? headers,  DomainBangumiTorrent? torrent)  $default,) {final _that = this;
switch (_that) {
case _DomainBangumiWatch():
return $default(_that.type,_that.url,_that.subtitles,_that.headers,_that.torrent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? type,  String? url,  List<DomainBangumiWatchSubtitle>? subtitles,  Map<String, String>? headers,  DomainBangumiTorrent? torrent)?  $default,) {final _that = this;
switch (_that) {
case _DomainBangumiWatch() when $default != null:
return $default(_that.type,_that.url,_that.subtitles,_that.headers,_that.torrent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainBangumiWatch implements DomainBangumiWatch {
  const _DomainBangumiWatch({this.type, this.url,  List<DomainBangumiWatchSubtitle>? subtitles,  Map<String, String>? headers, this.torrent}): _subtitles = subtitles,_headers = headers;
  factory _DomainBangumiWatch.fromJson(Map<String, dynamic> json) => _$DomainBangumiWatchFromJson(json);

@override final  String? type;
@override final  String? url;
 final  List<DomainBangumiWatchSubtitle>? _subtitles;
@override List<DomainBangumiWatchSubtitle>? get subtitles {
  final value = _subtitles;
  if (value == null) return null;
  if (_subtitles is EqualUnmodifiableListView) return _subtitles;
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

@override final  DomainBangumiTorrent? torrent;

/// Create a copy of DomainBangumiWatch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainBangumiWatchCopyWith<_DomainBangumiWatch> get copyWith => __$DomainBangumiWatchCopyWithImpl<_DomainBangumiWatch>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainBangumiWatchToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainBangumiWatch&&(identical(other.type, type) || other.type == type)&&(identical(other.url, url) || other.url == url)&&const DeepCollectionEquality().equals(other._subtitles, _subtitles)&&const DeepCollectionEquality().equals(other._headers, _headers)&&(identical(other.torrent, torrent) || other.torrent == torrent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,url,const DeepCollectionEquality().hash(_subtitles),const DeepCollectionEquality().hash(_headers),torrent);

@override
String toString() {
  return 'DomainBangumiWatch(type: $type, url: $url, subtitles: $subtitles, headers: $headers, torrent: $torrent)';
}


}

/// @nodoc
abstract mixin class _$DomainBangumiWatchCopyWith<$Res> implements $DomainBangumiWatchCopyWith<$Res> {
  factory _$DomainBangumiWatchCopyWith(_DomainBangumiWatch value, $Res Function(_DomainBangumiWatch) _then) = __$DomainBangumiWatchCopyWithImpl;
@override @useResult
$Res call({
 String? type, String? url, List<DomainBangumiWatchSubtitle>? subtitles, Map<String, String>? headers, DomainBangumiTorrent? torrent
});


@override $DomainBangumiTorrentCopyWith<$Res>? get torrent;

}
/// @nodoc
class __$DomainBangumiWatchCopyWithImpl<$Res>
    implements _$DomainBangumiWatchCopyWith<$Res> {
  __$DomainBangumiWatchCopyWithImpl(this._self, this._then);

  final _DomainBangumiWatch _self;
  final $Res Function(_DomainBangumiWatch) _then;

/// Create a copy of DomainBangumiWatch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = freezed,Object? url = freezed,Object? subtitles = freezed,Object? headers = freezed,Object? torrent = freezed,}) {
  return _then(_DomainBangumiWatch(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,subtitles: freezed == subtitles ? _self._subtitles : subtitles // ignore: cast_nullable_to_non_nullable
as List<DomainBangumiWatchSubtitle>?,headers: freezed == headers ? _self._headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,torrent: freezed == torrent ? _self.torrent : torrent // ignore: cast_nullable_to_non_nullable
as DomainBangumiTorrent?,
  ));
}

/// Create a copy of DomainBangumiWatch
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DomainBangumiTorrentCopyWith<$Res>? get torrent {
    if (_self.torrent == null) {
    return null;
  }

  return $DomainBangumiTorrentCopyWith<$Res>(_self.torrent!, (value) {
    return _then(_self.copyWith(torrent: value));
  });
}
}


/// @nodoc
mixin _$DomainBangumiWatchSubtitle {

 String? get language; String? get title; String get url;
/// Create a copy of DomainBangumiWatchSubtitle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainBangumiWatchSubtitleCopyWith<DomainBangumiWatchSubtitle> get copyWith => _$DomainBangumiWatchSubtitleCopyWithImpl<DomainBangumiWatchSubtitle>(this as DomainBangumiWatchSubtitle, _$identity);

  /// Serializes this DomainBangumiWatchSubtitle to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainBangumiWatchSubtitle&&(identical(other.language, language) || other.language == language)&&(identical(other.title, title) || other.title == title)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,language,title,url);

@override
String toString() {
  return 'DomainBangumiWatchSubtitle(language: $language, title: $title, url: $url)';
}


}

/// @nodoc
abstract mixin class $DomainBangumiWatchSubtitleCopyWith<$Res>  {
  factory $DomainBangumiWatchSubtitleCopyWith(DomainBangumiWatchSubtitle value, $Res Function(DomainBangumiWatchSubtitle) _then) = _$DomainBangumiWatchSubtitleCopyWithImpl;
@useResult
$Res call({
 String? language, String? title, String url
});




}
/// @nodoc
class _$DomainBangumiWatchSubtitleCopyWithImpl<$Res>
    implements $DomainBangumiWatchSubtitleCopyWith<$Res> {
  _$DomainBangumiWatchSubtitleCopyWithImpl(this._self, this._then);

  final DomainBangumiWatchSubtitle _self;
  final $Res Function(DomainBangumiWatchSubtitle) _then;

/// Create a copy of DomainBangumiWatchSubtitle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? language = freezed,Object? title = freezed,Object? url = null,}) {
  return _then(DomainBangumiWatchSubtitle(
language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainBangumiWatchSubtitle].
extension DomainBangumiWatchSubtitlePatterns on DomainBangumiWatchSubtitle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainBangumiWatchSubtitle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainBangumiWatchSubtitle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainBangumiWatchSubtitle value)  $default,){
final _that = this;
switch (_that) {
case _DomainBangumiWatchSubtitle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainBangumiWatchSubtitle value)?  $default,){
final _that = this;
switch (_that) {
case _DomainBangumiWatchSubtitle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? language,  String? title,  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainBangumiWatchSubtitle() when $default != null:
return $default(_that.language,_that.title,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? language,  String? title,  String url)  $default,) {final _that = this;
switch (_that) {
case _DomainBangumiWatchSubtitle():
return $default(_that.language,_that.title,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? language,  String? title,  String url)?  $default,) {final _that = this;
switch (_that) {
case _DomainBangumiWatchSubtitle() when $default != null:
return $default(_that.language,_that.title,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainBangumiWatchSubtitle implements DomainBangumiWatchSubtitle {
  const _DomainBangumiWatchSubtitle({this.language, this.title, required this.url});
  factory _DomainBangumiWatchSubtitle.fromJson(Map<String, dynamic> json) => _$DomainBangumiWatchSubtitleFromJson(json);

@override final  String? language;
@override final  String? title;
@override final  String url;

/// Create a copy of DomainBangumiWatchSubtitle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainBangumiWatchSubtitleCopyWith<_DomainBangumiWatchSubtitle> get copyWith => __$DomainBangumiWatchSubtitleCopyWithImpl<_DomainBangumiWatchSubtitle>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainBangumiWatchSubtitleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainBangumiWatchSubtitle&&(identical(other.language, language) || other.language == language)&&(identical(other.title, title) || other.title == title)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,language,title,url);

@override
String toString() {
  return 'DomainBangumiWatchSubtitle(language: $language, title: $title, url: $url)';
}


}

/// @nodoc
abstract mixin class _$DomainBangumiWatchSubtitleCopyWith<$Res> implements $DomainBangumiWatchSubtitleCopyWith<$Res> {
  factory _$DomainBangumiWatchSubtitleCopyWith(_DomainBangumiWatchSubtitle value, $Res Function(_DomainBangumiWatchSubtitle) _then) = __$DomainBangumiWatchSubtitleCopyWithImpl;
@override @useResult
$Res call({
 String? language, String? title, String url
});




}
/// @nodoc
class __$DomainBangumiWatchSubtitleCopyWithImpl<$Res>
    implements _$DomainBangumiWatchSubtitleCopyWith<$Res> {
  __$DomainBangumiWatchSubtitleCopyWithImpl(this._self, this._then);

  final _DomainBangumiWatchSubtitle _self;
  final $Res Function(_DomainBangumiWatchSubtitle) _then;

/// Create a copy of DomainBangumiWatchSubtitle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? language = freezed,Object? title = freezed,Object? url = null,}) {
  return _then(_DomainBangumiWatchSubtitle(
language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$DomainBangumiTorrent {

 String get infoHash; DomainBangumiTorrentDetail get detail; List<String>? get files;
/// Create a copy of DomainBangumiTorrent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainBangumiTorrentCopyWith<DomainBangumiTorrent> get copyWith => _$DomainBangumiTorrentCopyWithImpl<DomainBangumiTorrent>(this as DomainBangumiTorrent, _$identity);

  /// Serializes this DomainBangumiTorrent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainBangumiTorrent&&(identical(other.infoHash, infoHash) || other.infoHash == infoHash)&&(identical(other.detail, detail) || other.detail == detail)&&const DeepCollectionEquality().equals(other.files, files));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,infoHash,detail,const DeepCollectionEquality().hash(files));

@override
String toString() {
  return 'DomainBangumiTorrent(infoHash: $infoHash, detail: $detail, files: $files)';
}


}

/// @nodoc
abstract mixin class $DomainBangumiTorrentCopyWith<$Res>  {
  factory $DomainBangumiTorrentCopyWith(DomainBangumiTorrent value, $Res Function(DomainBangumiTorrent) _then) = _$DomainBangumiTorrentCopyWithImpl;
@useResult
$Res call({
 String infoHash, DomainBangumiTorrentDetail detail, List<String>? files
});


$DomainBangumiTorrentDetailCopyWith<$Res> get detail;

}
/// @nodoc
class _$DomainBangumiTorrentCopyWithImpl<$Res>
    implements $DomainBangumiTorrentCopyWith<$Res> {
  _$DomainBangumiTorrentCopyWithImpl(this._self, this._then);

  final DomainBangumiTorrent _self;
  final $Res Function(DomainBangumiTorrent) _then;

/// Create a copy of DomainBangumiTorrent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? infoHash = null,Object? detail = null,Object? files = freezed,}) {
  return _then(DomainBangumiTorrent(
infoHash: null == infoHash ? _self.infoHash : infoHash // ignore: cast_nullable_to_non_nullable
as String,detail: null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as DomainBangumiTorrentDetail,files: freezed == files ? _self.files : files // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}
/// Create a copy of DomainBangumiTorrent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DomainBangumiTorrentDetailCopyWith<$Res> get detail {
  
  return $DomainBangumiTorrentDetailCopyWith<$Res>(_self.detail, (value) {
    return _then(_self.copyWith(detail: value));
  });
}
}


/// Adds pattern-matching-related methods to [DomainBangumiTorrent].
extension DomainBangumiTorrentPatterns on DomainBangumiTorrent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainBangumiTorrent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainBangumiTorrent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainBangumiTorrent value)  $default,){
final _that = this;
switch (_that) {
case _DomainBangumiTorrent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainBangumiTorrent value)?  $default,){
final _that = this;
switch (_that) {
case _DomainBangumiTorrent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String infoHash,  DomainBangumiTorrentDetail detail,  List<String>? files)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainBangumiTorrent() when $default != null:
return $default(_that.infoHash,_that.detail,_that.files);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String infoHash,  DomainBangumiTorrentDetail detail,  List<String>? files)  $default,) {final _that = this;
switch (_that) {
case _DomainBangumiTorrent():
return $default(_that.infoHash,_that.detail,_that.files);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String infoHash,  DomainBangumiTorrentDetail detail,  List<String>? files)?  $default,) {final _that = this;
switch (_that) {
case _DomainBangumiTorrent() when $default != null:
return $default(_that.infoHash,_that.detail,_that.files);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainBangumiTorrent implements DomainBangumiTorrent {
  const _DomainBangumiTorrent({required this.infoHash, required this.detail,  List<String>? files}): _files = files;
  factory _DomainBangumiTorrent.fromJson(Map<String, dynamic> json) => _$DomainBangumiTorrentFromJson(json);

@override final  String infoHash;
@override final  DomainBangumiTorrentDetail detail;
 final  List<String>? _files;
@override List<String>? get files {
  final value = _files;
  if (value == null) return null;
  if (_files is EqualUnmodifiableListView) return _files;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of DomainBangumiTorrent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainBangumiTorrentCopyWith<_DomainBangumiTorrent> get copyWith => __$DomainBangumiTorrentCopyWithImpl<_DomainBangumiTorrent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainBangumiTorrentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainBangumiTorrent&&(identical(other.infoHash, infoHash) || other.infoHash == infoHash)&&(identical(other.detail, detail) || other.detail == detail)&&const DeepCollectionEquality().equals(other._files, _files));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,infoHash,detail,const DeepCollectionEquality().hash(_files));

@override
String toString() {
  return 'DomainBangumiTorrent(infoHash: $infoHash, detail: $detail, files: $files)';
}


}

/// @nodoc
abstract mixin class _$DomainBangumiTorrentCopyWith<$Res> implements $DomainBangumiTorrentCopyWith<$Res> {
  factory _$DomainBangumiTorrentCopyWith(_DomainBangumiTorrent value, $Res Function(_DomainBangumiTorrent) _then) = __$DomainBangumiTorrentCopyWithImpl;
@override @useResult
$Res call({
 String infoHash, DomainBangumiTorrentDetail detail, List<String>? files
});


@override $DomainBangumiTorrentDetailCopyWith<$Res> get detail;

}
/// @nodoc
class __$DomainBangumiTorrentCopyWithImpl<$Res>
    implements _$DomainBangumiTorrentCopyWith<$Res> {
  __$DomainBangumiTorrentCopyWithImpl(this._self, this._then);

  final _DomainBangumiTorrent _self;
  final $Res Function(_DomainBangumiTorrent) _then;

/// Create a copy of DomainBangumiTorrent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? infoHash = null,Object? detail = null,Object? files = freezed,}) {
  return _then(_DomainBangumiTorrent(
infoHash: null == infoHash ? _self.infoHash : infoHash // ignore: cast_nullable_to_non_nullable
as String,detail: null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as DomainBangumiTorrentDetail,files: freezed == files ? _self._files : files // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

/// Create a copy of DomainBangumiTorrent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DomainBangumiTorrentDetailCopyWith<$Res> get detail {
  
  return $DomainBangumiTorrentDetailCopyWith<$Res>(_self.detail, (value) {
    return _then(_self.copyWith(detail: value));
  });
}
}


/// @nodoc
mixin _$DomainBangumiTorrentDetail {

 int? get pieceLength; String? get pieces; String? get name; String? get nameUtf8; int? get length; String? get source; int? get metaVersion; DomainBangumiTorrentFileTree? get fileTree;
/// Create a copy of DomainBangumiTorrentDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainBangumiTorrentDetailCopyWith<DomainBangumiTorrentDetail> get copyWith => _$DomainBangumiTorrentDetailCopyWithImpl<DomainBangumiTorrentDetail>(this as DomainBangumiTorrentDetail, _$identity);

  /// Serializes this DomainBangumiTorrentDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainBangumiTorrentDetail&&(identical(other.pieceLength, pieceLength) || other.pieceLength == pieceLength)&&(identical(other.pieces, pieces) || other.pieces == pieces)&&(identical(other.name, name) || other.name == name)&&(identical(other.nameUtf8, nameUtf8) || other.nameUtf8 == nameUtf8)&&(identical(other.length, length) || other.length == length)&&(identical(other.source, source) || other.source == source)&&(identical(other.metaVersion, metaVersion) || other.metaVersion == metaVersion)&&(identical(other.fileTree, fileTree) || other.fileTree == fileTree));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pieceLength,pieces,name,nameUtf8,length,source,metaVersion,fileTree);

@override
String toString() {
  return 'DomainBangumiTorrentDetail(pieceLength: $pieceLength, pieces: $pieces, name: $name, nameUtf8: $nameUtf8, length: $length, source: $source, metaVersion: $metaVersion, fileTree: $fileTree)';
}


}

/// @nodoc
abstract mixin class $DomainBangumiTorrentDetailCopyWith<$Res>  {
  factory $DomainBangumiTorrentDetailCopyWith(DomainBangumiTorrentDetail value, $Res Function(DomainBangumiTorrentDetail) _then) = _$DomainBangumiTorrentDetailCopyWithImpl;
@useResult
$Res call({
 int? pieceLength, String? pieces, String? name, String? nameUtf8, int? length, String? source, int? metaVersion, DomainBangumiTorrentFileTree? fileTree
});


$DomainBangumiTorrentFileTreeCopyWith<$Res>? get fileTree;

}
/// @nodoc
class _$DomainBangumiTorrentDetailCopyWithImpl<$Res>
    implements $DomainBangumiTorrentDetailCopyWith<$Res> {
  _$DomainBangumiTorrentDetailCopyWithImpl(this._self, this._then);

  final DomainBangumiTorrentDetail _self;
  final $Res Function(DomainBangumiTorrentDetail) _then;

/// Create a copy of DomainBangumiTorrentDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pieceLength = freezed,Object? pieces = freezed,Object? name = freezed,Object? nameUtf8 = freezed,Object? length = freezed,Object? source = freezed,Object? metaVersion = freezed,Object? fileTree = freezed,}) {
  return _then(DomainBangumiTorrentDetail(
pieceLength: freezed == pieceLength ? _self.pieceLength : pieceLength // ignore: cast_nullable_to_non_nullable
as int?,pieces: freezed == pieces ? _self.pieces : pieces // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,nameUtf8: freezed == nameUtf8 ? _self.nameUtf8 : nameUtf8 // ignore: cast_nullable_to_non_nullable
as String?,length: freezed == length ? _self.length : length // ignore: cast_nullable_to_non_nullable
as int?,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,metaVersion: freezed == metaVersion ? _self.metaVersion : metaVersion // ignore: cast_nullable_to_non_nullable
as int?,fileTree: freezed == fileTree ? _self.fileTree : fileTree // ignore: cast_nullable_to_non_nullable
as DomainBangumiTorrentFileTree?,
  ));
}
/// Create a copy of DomainBangumiTorrentDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DomainBangumiTorrentFileTreeCopyWith<$Res>? get fileTree {
    if (_self.fileTree == null) {
    return null;
  }

  return $DomainBangumiTorrentFileTreeCopyWith<$Res>(_self.fileTree!, (value) {
    return _then(_self.copyWith(fileTree: value));
  });
}
}


/// Adds pattern-matching-related methods to [DomainBangumiTorrentDetail].
extension DomainBangumiTorrentDetailPatterns on DomainBangumiTorrentDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainBangumiTorrentDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainBangumiTorrentDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainBangumiTorrentDetail value)  $default,){
final _that = this;
switch (_that) {
case _DomainBangumiTorrentDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainBangumiTorrentDetail value)?  $default,){
final _that = this;
switch (_that) {
case _DomainBangumiTorrentDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? pieceLength,  String? pieces,  String? name,  String? nameUtf8,  int? length,  String? source,  int? metaVersion,  DomainBangumiTorrentFileTree? fileTree)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainBangumiTorrentDetail() when $default != null:
return $default(_that.pieceLength,_that.pieces,_that.name,_that.nameUtf8,_that.length,_that.source,_that.metaVersion,_that.fileTree);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? pieceLength,  String? pieces,  String? name,  String? nameUtf8,  int? length,  String? source,  int? metaVersion,  DomainBangumiTorrentFileTree? fileTree)  $default,) {final _that = this;
switch (_that) {
case _DomainBangumiTorrentDetail():
return $default(_that.pieceLength,_that.pieces,_that.name,_that.nameUtf8,_that.length,_that.source,_that.metaVersion,_that.fileTree);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? pieceLength,  String? pieces,  String? name,  String? nameUtf8,  int? length,  String? source,  int? metaVersion,  DomainBangumiTorrentFileTree? fileTree)?  $default,) {final _that = this;
switch (_that) {
case _DomainBangumiTorrentDetail() when $default != null:
return $default(_that.pieceLength,_that.pieces,_that.name,_that.nameUtf8,_that.length,_that.source,_that.metaVersion,_that.fileTree);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainBangumiTorrentDetail implements DomainBangumiTorrentDetail {
  const _DomainBangumiTorrentDetail({this.pieceLength, this.pieces, this.name, this.nameUtf8, this.length, this.source, this.metaVersion, this.fileTree});
  factory _DomainBangumiTorrentDetail.fromJson(Map<String, dynamic> json) => _$DomainBangumiTorrentDetailFromJson(json);

@override final  int? pieceLength;
@override final  String? pieces;
@override final  String? name;
@override final  String? nameUtf8;
@override final  int? length;
@override final  String? source;
@override final  int? metaVersion;
@override final  DomainBangumiTorrentFileTree? fileTree;

/// Create a copy of DomainBangumiTorrentDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainBangumiTorrentDetailCopyWith<_DomainBangumiTorrentDetail> get copyWith => __$DomainBangumiTorrentDetailCopyWithImpl<_DomainBangumiTorrentDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainBangumiTorrentDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainBangumiTorrentDetail&&(identical(other.pieceLength, pieceLength) || other.pieceLength == pieceLength)&&(identical(other.pieces, pieces) || other.pieces == pieces)&&(identical(other.name, name) || other.name == name)&&(identical(other.nameUtf8, nameUtf8) || other.nameUtf8 == nameUtf8)&&(identical(other.length, length) || other.length == length)&&(identical(other.source, source) || other.source == source)&&(identical(other.metaVersion, metaVersion) || other.metaVersion == metaVersion)&&(identical(other.fileTree, fileTree) || other.fileTree == fileTree));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pieceLength,pieces,name,nameUtf8,length,source,metaVersion,fileTree);

@override
String toString() {
  return 'DomainBangumiTorrentDetail(pieceLength: $pieceLength, pieces: $pieces, name: $name, nameUtf8: $nameUtf8, length: $length, source: $source, metaVersion: $metaVersion, fileTree: $fileTree)';
}


}

/// @nodoc
abstract mixin class _$DomainBangumiTorrentDetailCopyWith<$Res> implements $DomainBangumiTorrentDetailCopyWith<$Res> {
  factory _$DomainBangumiTorrentDetailCopyWith(_DomainBangumiTorrentDetail value, $Res Function(_DomainBangumiTorrentDetail) _then) = __$DomainBangumiTorrentDetailCopyWithImpl;
@override @useResult
$Res call({
 int? pieceLength, String? pieces, String? name, String? nameUtf8, int? length, String? source, int? metaVersion, DomainBangumiTorrentFileTree? fileTree
});


@override $DomainBangumiTorrentFileTreeCopyWith<$Res>? get fileTree;

}
/// @nodoc
class __$DomainBangumiTorrentDetailCopyWithImpl<$Res>
    implements _$DomainBangumiTorrentDetailCopyWith<$Res> {
  __$DomainBangumiTorrentDetailCopyWithImpl(this._self, this._then);

  final _DomainBangumiTorrentDetail _self;
  final $Res Function(_DomainBangumiTorrentDetail) _then;

/// Create a copy of DomainBangumiTorrentDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pieceLength = freezed,Object? pieces = freezed,Object? name = freezed,Object? nameUtf8 = freezed,Object? length = freezed,Object? source = freezed,Object? metaVersion = freezed,Object? fileTree = freezed,}) {
  return _then(_DomainBangumiTorrentDetail(
pieceLength: freezed == pieceLength ? _self.pieceLength : pieceLength // ignore: cast_nullable_to_non_nullable
as int?,pieces: freezed == pieces ? _self.pieces : pieces // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,nameUtf8: freezed == nameUtf8 ? _self.nameUtf8 : nameUtf8 // ignore: cast_nullable_to_non_nullable
as String?,length: freezed == length ? _self.length : length // ignore: cast_nullable_to_non_nullable
as int?,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,metaVersion: freezed == metaVersion ? _self.metaVersion : metaVersion // ignore: cast_nullable_to_non_nullable
as int?,fileTree: freezed == fileTree ? _self.fileTree : fileTree // ignore: cast_nullable_to_non_nullable
as DomainBangumiTorrentFileTree?,
  ));
}

/// Create a copy of DomainBangumiTorrentDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DomainBangumiTorrentFileTreeCopyWith<$Res>? get fileTree {
    if (_self.fileTree == null) {
    return null;
  }

  return $DomainBangumiTorrentFileTreeCopyWith<$Res>(_self.fileTree!, (value) {
    return _then(_self.copyWith(fileTree: value));
  });
}
}


/// @nodoc
mixin _$DomainBangumiTorrentFileTree {

 DomainBangumiTorrentFileTreeFile? get file; Map<String, DomainBangumiTorrentFileTree>? get dir;
/// Create a copy of DomainBangumiTorrentFileTree
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainBangumiTorrentFileTreeCopyWith<DomainBangumiTorrentFileTree> get copyWith => _$DomainBangumiTorrentFileTreeCopyWithImpl<DomainBangumiTorrentFileTree>(this as DomainBangumiTorrentFileTree, _$identity);

  /// Serializes this DomainBangumiTorrentFileTree to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainBangumiTorrentFileTree&&(identical(other.file, file) || other.file == file)&&const DeepCollectionEquality().equals(other.dir, dir));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,file,const DeepCollectionEquality().hash(dir));

@override
String toString() {
  return 'DomainBangumiTorrentFileTree(file: $file, dir: $dir)';
}


}

/// @nodoc
abstract mixin class $DomainBangumiTorrentFileTreeCopyWith<$Res>  {
  factory $DomainBangumiTorrentFileTreeCopyWith(DomainBangumiTorrentFileTree value, $Res Function(DomainBangumiTorrentFileTree) _then) = _$DomainBangumiTorrentFileTreeCopyWithImpl;
@useResult
$Res call({
 DomainBangumiTorrentFileTreeFile? file, Map<String, DomainBangumiTorrentFileTree>? dir
});


$DomainBangumiTorrentFileTreeFileCopyWith<$Res>? get file;

}
/// @nodoc
class _$DomainBangumiTorrentFileTreeCopyWithImpl<$Res>
    implements $DomainBangumiTorrentFileTreeCopyWith<$Res> {
  _$DomainBangumiTorrentFileTreeCopyWithImpl(this._self, this._then);

  final DomainBangumiTorrentFileTree _self;
  final $Res Function(DomainBangumiTorrentFileTree) _then;

/// Create a copy of DomainBangumiTorrentFileTree
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? file = freezed,Object? dir = freezed,}) {
  return _then(DomainBangumiTorrentFileTree(
file: freezed == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as DomainBangumiTorrentFileTreeFile?,dir: freezed == dir ? _self.dir : dir // ignore: cast_nullable_to_non_nullable
as Map<String, DomainBangumiTorrentFileTree>?,
  ));
}
/// Create a copy of DomainBangumiTorrentFileTree
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DomainBangumiTorrentFileTreeFileCopyWith<$Res>? get file {
    if (_self.file == null) {
    return null;
  }

  return $DomainBangumiTorrentFileTreeFileCopyWith<$Res>(_self.file!, (value) {
    return _then(_self.copyWith(file: value));
  });
}
}


/// Adds pattern-matching-related methods to [DomainBangumiTorrentFileTree].
extension DomainBangumiTorrentFileTreePatterns on DomainBangumiTorrentFileTree {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainBangumiTorrentFileTree value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainBangumiTorrentFileTree() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainBangumiTorrentFileTree value)  $default,){
final _that = this;
switch (_that) {
case _DomainBangumiTorrentFileTree():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainBangumiTorrentFileTree value)?  $default,){
final _that = this;
switch (_that) {
case _DomainBangumiTorrentFileTree() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DomainBangumiTorrentFileTreeFile? file,  Map<String, DomainBangumiTorrentFileTree>? dir)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainBangumiTorrentFileTree() when $default != null:
return $default(_that.file,_that.dir);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DomainBangumiTorrentFileTreeFile? file,  Map<String, DomainBangumiTorrentFileTree>? dir)  $default,) {final _that = this;
switch (_that) {
case _DomainBangumiTorrentFileTree():
return $default(_that.file,_that.dir);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DomainBangumiTorrentFileTreeFile? file,  Map<String, DomainBangumiTorrentFileTree>? dir)?  $default,) {final _that = this;
switch (_that) {
case _DomainBangumiTorrentFileTree() when $default != null:
return $default(_that.file,_that.dir);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainBangumiTorrentFileTree implements DomainBangumiTorrentFileTree {
  const _DomainBangumiTorrentFileTree({this.file,  Map<String, DomainBangumiTorrentFileTree>? dir}): _dir = dir;
  factory _DomainBangumiTorrentFileTree.fromJson(Map<String, dynamic> json) => _$DomainBangumiTorrentFileTreeFromJson(json);

@override final  DomainBangumiTorrentFileTreeFile? file;
 final  Map<String, DomainBangumiTorrentFileTree>? _dir;
@override Map<String, DomainBangumiTorrentFileTree>? get dir {
  final value = _dir;
  if (value == null) return null;
  if (_dir is EqualUnmodifiableMapView) return _dir;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of DomainBangumiTorrentFileTree
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainBangumiTorrentFileTreeCopyWith<_DomainBangumiTorrentFileTree> get copyWith => __$DomainBangumiTorrentFileTreeCopyWithImpl<_DomainBangumiTorrentFileTree>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainBangumiTorrentFileTreeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainBangumiTorrentFileTree&&(identical(other.file, file) || other.file == file)&&const DeepCollectionEquality().equals(other._dir, _dir));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,file,const DeepCollectionEquality().hash(_dir));

@override
String toString() {
  return 'DomainBangumiTorrentFileTree(file: $file, dir: $dir)';
}


}

/// @nodoc
abstract mixin class _$DomainBangumiTorrentFileTreeCopyWith<$Res> implements $DomainBangumiTorrentFileTreeCopyWith<$Res> {
  factory _$DomainBangumiTorrentFileTreeCopyWith(_DomainBangumiTorrentFileTree value, $Res Function(_DomainBangumiTorrentFileTree) _then) = __$DomainBangumiTorrentFileTreeCopyWithImpl;
@override @useResult
$Res call({
 DomainBangumiTorrentFileTreeFile? file, Map<String, DomainBangumiTorrentFileTree>? dir
});


@override $DomainBangumiTorrentFileTreeFileCopyWith<$Res>? get file;

}
/// @nodoc
class __$DomainBangumiTorrentFileTreeCopyWithImpl<$Res>
    implements _$DomainBangumiTorrentFileTreeCopyWith<$Res> {
  __$DomainBangumiTorrentFileTreeCopyWithImpl(this._self, this._then);

  final _DomainBangumiTorrentFileTree _self;
  final $Res Function(_DomainBangumiTorrentFileTree) _then;

/// Create a copy of DomainBangumiTorrentFileTree
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? file = freezed,Object? dir = freezed,}) {
  return _then(_DomainBangumiTorrentFileTree(
file: freezed == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as DomainBangumiTorrentFileTreeFile?,dir: freezed == dir ? _self._dir : dir // ignore: cast_nullable_to_non_nullable
as Map<String, DomainBangumiTorrentFileTree>?,
  ));
}

/// Create a copy of DomainBangumiTorrentFileTree
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DomainBangumiTorrentFileTreeFileCopyWith<$Res>? get file {
    if (_self.file == null) {
    return null;
  }

  return $DomainBangumiTorrentFileTreeFileCopyWith<$Res>(_self.file!, (value) {
    return _then(_self.copyWith(file: value));
  });
}
}


/// @nodoc
mixin _$DomainBangumiTorrentFileTreeFile {

 int get length; String get piecesRoot;
/// Create a copy of DomainBangumiTorrentFileTreeFile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainBangumiTorrentFileTreeFileCopyWith<DomainBangumiTorrentFileTreeFile> get copyWith => _$DomainBangumiTorrentFileTreeFileCopyWithImpl<DomainBangumiTorrentFileTreeFile>(this as DomainBangumiTorrentFileTreeFile, _$identity);

  /// Serializes this DomainBangumiTorrentFileTreeFile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainBangumiTorrentFileTreeFile&&(identical(other.length, length) || other.length == length)&&(identical(other.piecesRoot, piecesRoot) || other.piecesRoot == piecesRoot));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,length,piecesRoot);

@override
String toString() {
  return 'DomainBangumiTorrentFileTreeFile(length: $length, piecesRoot: $piecesRoot)';
}


}

/// @nodoc
abstract mixin class $DomainBangumiTorrentFileTreeFileCopyWith<$Res>  {
  factory $DomainBangumiTorrentFileTreeFileCopyWith(DomainBangumiTorrentFileTreeFile value, $Res Function(DomainBangumiTorrentFileTreeFile) _then) = _$DomainBangumiTorrentFileTreeFileCopyWithImpl;
@useResult
$Res call({
 int length, String piecesRoot
});




}
/// @nodoc
class _$DomainBangumiTorrentFileTreeFileCopyWithImpl<$Res>
    implements $DomainBangumiTorrentFileTreeFileCopyWith<$Res> {
  _$DomainBangumiTorrentFileTreeFileCopyWithImpl(this._self, this._then);

  final DomainBangumiTorrentFileTreeFile _self;
  final $Res Function(DomainBangumiTorrentFileTreeFile) _then;

/// Create a copy of DomainBangumiTorrentFileTreeFile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? length = null,Object? piecesRoot = null,}) {
  return _then(DomainBangumiTorrentFileTreeFile(
length: null == length ? _self.length : length // ignore: cast_nullable_to_non_nullable
as int,piecesRoot: null == piecesRoot ? _self.piecesRoot : piecesRoot // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainBangumiTorrentFileTreeFile].
extension DomainBangumiTorrentFileTreeFilePatterns on DomainBangumiTorrentFileTreeFile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainBangumiTorrentFileTreeFile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainBangumiTorrentFileTreeFile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainBangumiTorrentFileTreeFile value)  $default,){
final _that = this;
switch (_that) {
case _DomainBangumiTorrentFileTreeFile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainBangumiTorrentFileTreeFile value)?  $default,){
final _that = this;
switch (_that) {
case _DomainBangumiTorrentFileTreeFile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int length,  String piecesRoot)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainBangumiTorrentFileTreeFile() when $default != null:
return $default(_that.length,_that.piecesRoot);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int length,  String piecesRoot)  $default,) {final _that = this;
switch (_that) {
case _DomainBangumiTorrentFileTreeFile():
return $default(_that.length,_that.piecesRoot);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int length,  String piecesRoot)?  $default,) {final _that = this;
switch (_that) {
case _DomainBangumiTorrentFileTreeFile() when $default != null:
return $default(_that.length,_that.piecesRoot);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainBangumiTorrentFileTreeFile implements DomainBangumiTorrentFileTreeFile {
  const _DomainBangumiTorrentFileTreeFile({required this.length, required this.piecesRoot});
  factory _DomainBangumiTorrentFileTreeFile.fromJson(Map<String, dynamic> json) => _$DomainBangumiTorrentFileTreeFileFromJson(json);

@override final  int length;
@override final  String piecesRoot;

/// Create a copy of DomainBangumiTorrentFileTreeFile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainBangumiTorrentFileTreeFileCopyWith<_DomainBangumiTorrentFileTreeFile> get copyWith => __$DomainBangumiTorrentFileTreeFileCopyWithImpl<_DomainBangumiTorrentFileTreeFile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainBangumiTorrentFileTreeFileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainBangumiTorrentFileTreeFile&&(identical(other.length, length) || other.length == length)&&(identical(other.piecesRoot, piecesRoot) || other.piecesRoot == piecesRoot));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,length,piecesRoot);

@override
String toString() {
  return 'DomainBangumiTorrentFileTreeFile(length: $length, piecesRoot: $piecesRoot)';
}


}

/// @nodoc
abstract mixin class _$DomainBangumiTorrentFileTreeFileCopyWith<$Res> implements $DomainBangumiTorrentFileTreeFileCopyWith<$Res> {
  factory _$DomainBangumiTorrentFileTreeFileCopyWith(_DomainBangumiTorrentFileTreeFile value, $Res Function(_DomainBangumiTorrentFileTreeFile) _then) = __$DomainBangumiTorrentFileTreeFileCopyWithImpl;
@override @useResult
$Res call({
 int length, String piecesRoot
});




}
/// @nodoc
class __$DomainBangumiTorrentFileTreeFileCopyWithImpl<$Res>
    implements _$DomainBangumiTorrentFileTreeFileCopyWith<$Res> {
  __$DomainBangumiTorrentFileTreeFileCopyWithImpl(this._self, this._then);

  final _DomainBangumiTorrentFileTreeFile _self;
  final $Res Function(_DomainBangumiTorrentFileTreeFile) _then;

/// Create a copy of DomainBangumiTorrentFileTreeFile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? length = null,Object? piecesRoot = null,}) {
  return _then(_DomainBangumiTorrentFileTreeFile(
length: null == length ? _self.length : length // ignore: cast_nullable_to_non_nullable
as int,piecesRoot: null == piecesRoot ? _self.piecesRoot : piecesRoot // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$DomainMangaWatch {

 List<DomainMangaPage> get pages; Map<String, String>? get headers;
/// Create a copy of DomainMangaWatch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainMangaWatchCopyWith<DomainMangaWatch> get copyWith => _$DomainMangaWatchCopyWithImpl<DomainMangaWatch>(this as DomainMangaWatch, _$identity);

  /// Serializes this DomainMangaWatch to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainMangaWatch&&const DeepCollectionEquality().equals(other.pages, pages)&&const DeepCollectionEquality().equals(other.headers, headers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(pages),const DeepCollectionEquality().hash(headers));

@override
String toString() {
  return 'DomainMangaWatch(pages: $pages, headers: $headers)';
}


}

/// @nodoc
abstract mixin class $DomainMangaWatchCopyWith<$Res>  {
  factory $DomainMangaWatchCopyWith(DomainMangaWatch value, $Res Function(DomainMangaWatch) _then) = _$DomainMangaWatchCopyWithImpl;
@useResult
$Res call({
 List<DomainMangaPage> pages, Map<String, String>? headers
});




}
/// @nodoc
class _$DomainMangaWatchCopyWithImpl<$Res>
    implements $DomainMangaWatchCopyWith<$Res> {
  _$DomainMangaWatchCopyWithImpl(this._self, this._then);

  final DomainMangaWatch _self;
  final $Res Function(DomainMangaWatch) _then;

/// Create a copy of DomainMangaWatch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pages = null,Object? headers = freezed,}) {
  return _then(DomainMangaWatch(
pages: null == pages ? _self.pages : pages // ignore: cast_nullable_to_non_nullable
as List<DomainMangaPage>,headers: freezed == headers ? _self.headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainMangaWatch].
extension DomainMangaWatchPatterns on DomainMangaWatch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainMangaWatch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainMangaWatch() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainMangaWatch value)  $default,){
final _that = this;
switch (_that) {
case _DomainMangaWatch():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainMangaWatch value)?  $default,){
final _that = this;
switch (_that) {
case _DomainMangaWatch() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<DomainMangaPage> pages,  Map<String, String>? headers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainMangaWatch() when $default != null:
return $default(_that.pages,_that.headers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<DomainMangaPage> pages,  Map<String, String>? headers)  $default,) {final _that = this;
switch (_that) {
case _DomainMangaWatch():
return $default(_that.pages,_that.headers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<DomainMangaPage> pages,  Map<String, String>? headers)?  $default,) {final _that = this;
switch (_that) {
case _DomainMangaWatch() when $default != null:
return $default(_that.pages,_that.headers);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainMangaWatch implements DomainMangaWatch {
  const _DomainMangaWatch({required  List<DomainMangaPage> pages,  Map<String, String>? headers}): _pages = pages,_headers = headers;
  factory _DomainMangaWatch.fromJson(Map<String, dynamic> json) => _$DomainMangaWatchFromJson(json);

 final  List<DomainMangaPage> _pages;
@override List<DomainMangaPage> get pages {
  if (_pages is EqualUnmodifiableListView) return _pages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pages);
}

 final  Map<String, String>? _headers;
@override Map<String, String>? get headers {
  final value = _headers;
  if (value == null) return null;
  if (_headers is EqualUnmodifiableMapView) return _headers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of DomainMangaWatch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainMangaWatchCopyWith<_DomainMangaWatch> get copyWith => __$DomainMangaWatchCopyWithImpl<_DomainMangaWatch>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainMangaWatchToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainMangaWatch&&const DeepCollectionEquality().equals(other._pages, _pages)&&const DeepCollectionEquality().equals(other._headers, _headers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_pages),const DeepCollectionEquality().hash(_headers));

@override
String toString() {
  return 'DomainMangaWatch(pages: $pages, headers: $headers)';
}


}

/// @nodoc
abstract mixin class _$DomainMangaWatchCopyWith<$Res> implements $DomainMangaWatchCopyWith<$Res> {
  factory _$DomainMangaWatchCopyWith(_DomainMangaWatch value, $Res Function(_DomainMangaWatch) _then) = __$DomainMangaWatchCopyWithImpl;
@override @useResult
$Res call({
 List<DomainMangaPage> pages, Map<String, String>? headers
});




}
/// @nodoc
class __$DomainMangaWatchCopyWithImpl<$Res>
    implements _$DomainMangaWatchCopyWith<$Res> {
  __$DomainMangaWatchCopyWithImpl(this._self, this._then);

  final _DomainMangaWatch _self;
  final $Res Function(_DomainMangaWatch) _then;

/// Create a copy of DomainMangaWatch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pages = null,Object? headers = freezed,}) {
  return _then(_DomainMangaWatch(
pages: null == pages ? _self._pages : pages // ignore: cast_nullable_to_non_nullable
as List<DomainMangaPage>,headers: freezed == headers ? _self._headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,
  ));
}


}


/// @nodoc
mixin _$DomainMangaPage {

 String? get name; String get url;
/// Create a copy of DomainMangaPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainMangaPageCopyWith<DomainMangaPage> get copyWith => _$DomainMangaPageCopyWithImpl<DomainMangaPage>(this as DomainMangaPage, _$identity);

  /// Serializes this DomainMangaPage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainMangaPage&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,url);

@override
String toString() {
  return 'DomainMangaPage(name: $name, url: $url)';
}


}

/// @nodoc
abstract mixin class $DomainMangaPageCopyWith<$Res>  {
  factory $DomainMangaPageCopyWith(DomainMangaPage value, $Res Function(DomainMangaPage) _then) = _$DomainMangaPageCopyWithImpl;
@useResult
$Res call({
 String? name, String url
});




}
/// @nodoc
class _$DomainMangaPageCopyWithImpl<$Res>
    implements $DomainMangaPageCopyWith<$Res> {
  _$DomainMangaPageCopyWithImpl(this._self, this._then);

  final DomainMangaPage _self;
  final $Res Function(DomainMangaPage) _then;

/// Create a copy of DomainMangaPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? url = null,}) {
  return _then(DomainMangaPage(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainMangaPage].
extension DomainMangaPagePatterns on DomainMangaPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainMangaPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainMangaPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainMangaPage value)  $default,){
final _that = this;
switch (_that) {
case _DomainMangaPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainMangaPage value)?  $default,){
final _that = this;
switch (_that) {
case _DomainMangaPage() when $default != null:
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
case _DomainMangaPage() when $default != null:
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
case _DomainMangaPage():
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
case _DomainMangaPage() when $default != null:
return $default(_that.name,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainMangaPage implements DomainMangaPage {
  const _DomainMangaPage({this.name, required this.url});
  factory _DomainMangaPage.fromJson(Map<String, dynamic> json) => _$DomainMangaPageFromJson(json);

@override final  String? name;
@override final  String url;

/// Create a copy of DomainMangaPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainMangaPageCopyWith<_DomainMangaPage> get copyWith => __$DomainMangaPageCopyWithImpl<_DomainMangaPage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainMangaPageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainMangaPage&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,url);

@override
String toString() {
  return 'DomainMangaPage(name: $name, url: $url)';
}


}

/// @nodoc
abstract mixin class _$DomainMangaPageCopyWith<$Res> implements $DomainMangaPageCopyWith<$Res> {
  factory _$DomainMangaPageCopyWith(_DomainMangaPage value, $Res Function(_DomainMangaPage) _then) = __$DomainMangaPageCopyWithImpl;
@override @useResult
$Res call({
 String? name, String url
});




}
/// @nodoc
class __$DomainMangaPageCopyWithImpl<$Res>
    implements _$DomainMangaPageCopyWith<$Res> {
  __$DomainMangaPageCopyWithImpl(this._self, this._then);

  final _DomainMangaPage _self;
  final $Res Function(_DomainMangaPage) _then;

/// Create a copy of DomainMangaPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? url = null,}) {
  return _then(_DomainMangaPage(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$DomainNovelWatch {

 List<DomainNovelChapter> get chapters; Map<String, String>? get headers;
/// Create a copy of DomainNovelWatch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainNovelWatchCopyWith<DomainNovelWatch> get copyWith => _$DomainNovelWatchCopyWithImpl<DomainNovelWatch>(this as DomainNovelWatch, _$identity);

  /// Serializes this DomainNovelWatch to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainNovelWatch&&const DeepCollectionEquality().equals(other.chapters, chapters)&&const DeepCollectionEquality().equals(other.headers, headers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(chapters),const DeepCollectionEquality().hash(headers));

@override
String toString() {
  return 'DomainNovelWatch(chapters: $chapters, headers: $headers)';
}


}

/// @nodoc
abstract mixin class $DomainNovelWatchCopyWith<$Res>  {
  factory $DomainNovelWatchCopyWith(DomainNovelWatch value, $Res Function(DomainNovelWatch) _then) = _$DomainNovelWatchCopyWithImpl;
@useResult
$Res call({
 List<DomainNovelChapter> chapters, Map<String, String>? headers
});




}
/// @nodoc
class _$DomainNovelWatchCopyWithImpl<$Res>
    implements $DomainNovelWatchCopyWith<$Res> {
  _$DomainNovelWatchCopyWithImpl(this._self, this._then);

  final DomainNovelWatch _self;
  final $Res Function(DomainNovelWatch) _then;

/// Create a copy of DomainNovelWatch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? chapters = null,Object? headers = freezed,}) {
  return _then(DomainNovelWatch(
chapters: null == chapters ? _self.chapters : chapters // ignore: cast_nullable_to_non_nullable
as List<DomainNovelChapter>,headers: freezed == headers ? _self.headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainNovelWatch].
extension DomainNovelWatchPatterns on DomainNovelWatch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainNovelWatch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainNovelWatch() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainNovelWatch value)  $default,){
final _that = this;
switch (_that) {
case _DomainNovelWatch():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainNovelWatch value)?  $default,){
final _that = this;
switch (_that) {
case _DomainNovelWatch() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<DomainNovelChapter> chapters,  Map<String, String>? headers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainNovelWatch() when $default != null:
return $default(_that.chapters,_that.headers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<DomainNovelChapter> chapters,  Map<String, String>? headers)  $default,) {final _that = this;
switch (_that) {
case _DomainNovelWatch():
return $default(_that.chapters,_that.headers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<DomainNovelChapter> chapters,  Map<String, String>? headers)?  $default,) {final _that = this;
switch (_that) {
case _DomainNovelWatch() when $default != null:
return $default(_that.chapters,_that.headers);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainNovelWatch implements DomainNovelWatch {
  const _DomainNovelWatch({required  List<DomainNovelChapter> chapters,  Map<String, String>? headers}): _chapters = chapters,_headers = headers;
  factory _DomainNovelWatch.fromJson(Map<String, dynamic> json) => _$DomainNovelWatchFromJson(json);

 final  List<DomainNovelChapter> _chapters;
@override List<DomainNovelChapter> get chapters {
  if (_chapters is EqualUnmodifiableListView) return _chapters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_chapters);
}

 final  Map<String, String>? _headers;
@override Map<String, String>? get headers {
  final value = _headers;
  if (value == null) return null;
  if (_headers is EqualUnmodifiableMapView) return _headers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of DomainNovelWatch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainNovelWatchCopyWith<_DomainNovelWatch> get copyWith => __$DomainNovelWatchCopyWithImpl<_DomainNovelWatch>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainNovelWatchToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainNovelWatch&&const DeepCollectionEquality().equals(other._chapters, _chapters)&&const DeepCollectionEquality().equals(other._headers, _headers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_chapters),const DeepCollectionEquality().hash(_headers));

@override
String toString() {
  return 'DomainNovelWatch(chapters: $chapters, headers: $headers)';
}


}

/// @nodoc
abstract mixin class _$DomainNovelWatchCopyWith<$Res> implements $DomainNovelWatchCopyWith<$Res> {
  factory _$DomainNovelWatchCopyWith(_DomainNovelWatch value, $Res Function(_DomainNovelWatch) _then) = __$DomainNovelWatchCopyWithImpl;
@override @useResult
$Res call({
 List<DomainNovelChapter> chapters, Map<String, String>? headers
});




}
/// @nodoc
class __$DomainNovelWatchCopyWithImpl<$Res>
    implements _$DomainNovelWatchCopyWith<$Res> {
  __$DomainNovelWatchCopyWithImpl(this._self, this._then);

  final _DomainNovelWatch _self;
  final $Res Function(_DomainNovelWatch) _then;

/// Create a copy of DomainNovelWatch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? chapters = null,Object? headers = freezed,}) {
  return _then(_DomainNovelWatch(
chapters: null == chapters ? _self._chapters : chapters // ignore: cast_nullable_to_non_nullable
as List<DomainNovelChapter>,headers: freezed == headers ? _self._headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,
  ));
}


}


/// @nodoc
mixin _$DomainNovelChapter {

 String? get name; String get url;
/// Create a copy of DomainNovelChapter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainNovelChapterCopyWith<DomainNovelChapter> get copyWith => _$DomainNovelChapterCopyWithImpl<DomainNovelChapter>(this as DomainNovelChapter, _$identity);

  /// Serializes this DomainNovelChapter to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainNovelChapter&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,url);

@override
String toString() {
  return 'DomainNovelChapter(name: $name, url: $url)';
}


}

/// @nodoc
abstract mixin class $DomainNovelChapterCopyWith<$Res>  {
  factory $DomainNovelChapterCopyWith(DomainNovelChapter value, $Res Function(DomainNovelChapter) _then) = _$DomainNovelChapterCopyWithImpl;
@useResult
$Res call({
 String? name, String url
});




}
/// @nodoc
class _$DomainNovelChapterCopyWithImpl<$Res>
    implements $DomainNovelChapterCopyWith<$Res> {
  _$DomainNovelChapterCopyWithImpl(this._self, this._then);

  final DomainNovelChapter _self;
  final $Res Function(DomainNovelChapter) _then;

/// Create a copy of DomainNovelChapter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? url = null,}) {
  return _then(DomainNovelChapter(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainNovelChapter].
extension DomainNovelChapterPatterns on DomainNovelChapter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainNovelChapter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainNovelChapter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainNovelChapter value)  $default,){
final _that = this;
switch (_that) {
case _DomainNovelChapter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainNovelChapter value)?  $default,){
final _that = this;
switch (_that) {
case _DomainNovelChapter() when $default != null:
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
case _DomainNovelChapter() when $default != null:
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
case _DomainNovelChapter():
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
case _DomainNovelChapter() when $default != null:
return $default(_that.name,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainNovelChapter implements DomainNovelChapter {
  const _DomainNovelChapter({this.name, required this.url});
  factory _DomainNovelChapter.fromJson(Map<String, dynamic> json) => _$DomainNovelChapterFromJson(json);

@override final  String? name;
@override final  String url;

/// Create a copy of DomainNovelChapter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainNovelChapterCopyWith<_DomainNovelChapter> get copyWith => __$DomainNovelChapterCopyWithImpl<_DomainNovelChapter>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainNovelChapterToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainNovelChapter&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,url);

@override
String toString() {
  return 'DomainNovelChapter(name: $name, url: $url)';
}


}

/// @nodoc
abstract mixin class _$DomainNovelChapterCopyWith<$Res> implements $DomainNovelChapterCopyWith<$Res> {
  factory _$DomainNovelChapterCopyWith(_DomainNovelChapter value, $Res Function(_DomainNovelChapter) _then) = __$DomainNovelChapterCopyWithImpl;
@override @useResult
$Res call({
 String? name, String url
});




}
/// @nodoc
class __$DomainNovelChapterCopyWithImpl<$Res>
    implements _$DomainNovelChapterCopyWith<$Res> {
  __$DomainNovelChapterCopyWithImpl(this._self, this._then);

  final _DomainNovelChapter _self;
  final $Res Function(_DomainNovelChapter) _then;

/// Create a copy of DomainNovelChapter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? url = null,}) {
  return _then(_DomainNovelChapter(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$DomainV2Watch {

 List<DomainV2EpisodeGroup> get groups; String? get defaultGroup; int? get defaultIndex;
/// Create a copy of DomainV2Watch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainV2WatchCopyWith<DomainV2Watch> get copyWith => _$DomainV2WatchCopyWithImpl<DomainV2Watch>(this as DomainV2Watch, _$identity);

  /// Serializes this DomainV2Watch to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainV2Watch&&const DeepCollectionEquality().equals(other.groups, groups)&&(identical(other.defaultGroup, defaultGroup) || other.defaultGroup == defaultGroup)&&(identical(other.defaultIndex, defaultIndex) || other.defaultIndex == defaultIndex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(groups),defaultGroup,defaultIndex);

@override
String toString() {
  return 'DomainV2Watch(groups: $groups, defaultGroup: $defaultGroup, defaultIndex: $defaultIndex)';
}


}

/// @nodoc
abstract mixin class $DomainV2WatchCopyWith<$Res>  {
  factory $DomainV2WatchCopyWith(DomainV2Watch value, $Res Function(DomainV2Watch) _then) = _$DomainV2WatchCopyWithImpl;
@useResult
$Res call({
 List<DomainV2EpisodeGroup> groups, String? defaultGroup, int? defaultIndex
});




}
/// @nodoc
class _$DomainV2WatchCopyWithImpl<$Res>
    implements $DomainV2WatchCopyWith<$Res> {
  _$DomainV2WatchCopyWithImpl(this._self, this._then);

  final DomainV2Watch _self;
  final $Res Function(DomainV2Watch) _then;

/// Create a copy of DomainV2Watch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? groups = null,Object? defaultGroup = freezed,Object? defaultIndex = freezed,}) {
  return _then(DomainV2Watch(
groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as List<DomainV2EpisodeGroup>,defaultGroup: freezed == defaultGroup ? _self.defaultGroup : defaultGroup // ignore: cast_nullable_to_non_nullable
as String?,defaultIndex: freezed == defaultIndex ? _self.defaultIndex : defaultIndex // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainV2Watch].
extension DomainV2WatchPatterns on DomainV2Watch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainV2Watch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainV2Watch() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainV2Watch value)  $default,){
final _that = this;
switch (_that) {
case _DomainV2Watch():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainV2Watch value)?  $default,){
final _that = this;
switch (_that) {
case _DomainV2Watch() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<DomainV2EpisodeGroup> groups,  String? defaultGroup,  int? defaultIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainV2Watch() when $default != null:
return $default(_that.groups,_that.defaultGroup,_that.defaultIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<DomainV2EpisodeGroup> groups,  String? defaultGroup,  int? defaultIndex)  $default,) {final _that = this;
switch (_that) {
case _DomainV2Watch():
return $default(_that.groups,_that.defaultGroup,_that.defaultIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<DomainV2EpisodeGroup> groups,  String? defaultGroup,  int? defaultIndex)?  $default,) {final _that = this;
switch (_that) {
case _DomainV2Watch() when $default != null:
return $default(_that.groups,_that.defaultGroup,_that.defaultIndex);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainV2Watch implements DomainV2Watch {
  const _DomainV2Watch({required  List<DomainV2EpisodeGroup> groups, this.defaultGroup, this.defaultIndex}): _groups = groups;
  factory _DomainV2Watch.fromJson(Map<String, dynamic> json) => _$DomainV2WatchFromJson(json);

 final  List<DomainV2EpisodeGroup> _groups;
@override List<DomainV2EpisodeGroup> get groups {
  if (_groups is EqualUnmodifiableListView) return _groups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groups);
}

@override final  String? defaultGroup;
@override final  int? defaultIndex;

/// Create a copy of DomainV2Watch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainV2WatchCopyWith<_DomainV2Watch> get copyWith => __$DomainV2WatchCopyWithImpl<_DomainV2Watch>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainV2WatchToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainV2Watch&&const DeepCollectionEquality().equals(other._groups, _groups)&&(identical(other.defaultGroup, defaultGroup) || other.defaultGroup == defaultGroup)&&(identical(other.defaultIndex, defaultIndex) || other.defaultIndex == defaultIndex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_groups),defaultGroup,defaultIndex);

@override
String toString() {
  return 'DomainV2Watch(groups: $groups, defaultGroup: $defaultGroup, defaultIndex: $defaultIndex)';
}


}

/// @nodoc
abstract mixin class _$DomainV2WatchCopyWith<$Res> implements $DomainV2WatchCopyWith<$Res> {
  factory _$DomainV2WatchCopyWith(_DomainV2Watch value, $Res Function(_DomainV2Watch) _then) = __$DomainV2WatchCopyWithImpl;
@override @useResult
$Res call({
 List<DomainV2EpisodeGroup> groups, String? defaultGroup, int? defaultIndex
});




}
/// @nodoc
class __$DomainV2WatchCopyWithImpl<$Res>
    implements _$DomainV2WatchCopyWith<$Res> {
  __$DomainV2WatchCopyWithImpl(this._self, this._then);

  final _DomainV2Watch _self;
  final $Res Function(_DomainV2Watch) _then;

/// Create a copy of DomainV2Watch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? groups = null,Object? defaultGroup = freezed,Object? defaultIndex = freezed,}) {
  return _then(_DomainV2Watch(
groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as List<DomainV2EpisodeGroup>,defaultGroup: freezed == defaultGroup ? _self.defaultGroup : defaultGroup // ignore: cast_nullable_to_non_nullable
as String?,defaultIndex: freezed == defaultIndex ? _self.defaultIndex : defaultIndex // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$DomainV2EpisodeGroup {

 String get title; List<DomainV2Episode> get episodes;
/// Create a copy of DomainV2EpisodeGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainV2EpisodeGroupCopyWith<DomainV2EpisodeGroup> get copyWith => _$DomainV2EpisodeGroupCopyWithImpl<DomainV2EpisodeGroup>(this as DomainV2EpisodeGroup, _$identity);

  /// Serializes this DomainV2EpisodeGroup to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainV2EpisodeGroup&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.episodes, episodes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,const DeepCollectionEquality().hash(episodes));

@override
String toString() {
  return 'DomainV2EpisodeGroup(title: $title, episodes: $episodes)';
}


}

/// @nodoc
abstract mixin class $DomainV2EpisodeGroupCopyWith<$Res>  {
  factory $DomainV2EpisodeGroupCopyWith(DomainV2EpisodeGroup value, $Res Function(DomainV2EpisodeGroup) _then) = _$DomainV2EpisodeGroupCopyWithImpl;
@useResult
$Res call({
 String title, List<DomainV2Episode> episodes
});




}
/// @nodoc
class _$DomainV2EpisodeGroupCopyWithImpl<$Res>
    implements $DomainV2EpisodeGroupCopyWith<$Res> {
  _$DomainV2EpisodeGroupCopyWithImpl(this._self, this._then);

  final DomainV2EpisodeGroup _self;
  final $Res Function(DomainV2EpisodeGroup) _then;

/// Create a copy of DomainV2EpisodeGroup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? episodes = null,}) {
  return _then(DomainV2EpisodeGroup(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,episodes: null == episodes ? _self.episodes : episodes // ignore: cast_nullable_to_non_nullable
as List<DomainV2Episode>,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainV2EpisodeGroup].
extension DomainV2EpisodeGroupPatterns on DomainV2EpisodeGroup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainV2EpisodeGroup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainV2EpisodeGroup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainV2EpisodeGroup value)  $default,){
final _that = this;
switch (_that) {
case _DomainV2EpisodeGroup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainV2EpisodeGroup value)?  $default,){
final _that = this;
switch (_that) {
case _DomainV2EpisodeGroup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  List<DomainV2Episode> episodes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainV2EpisodeGroup() when $default != null:
return $default(_that.title,_that.episodes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  List<DomainV2Episode> episodes)  $default,) {final _that = this;
switch (_that) {
case _DomainV2EpisodeGroup():
return $default(_that.title,_that.episodes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  List<DomainV2Episode> episodes)?  $default,) {final _that = this;
switch (_that) {
case _DomainV2EpisodeGroup() when $default != null:
return $default(_that.title,_that.episodes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainV2EpisodeGroup implements DomainV2EpisodeGroup {
  const _DomainV2EpisodeGroup({required this.title, required  List<DomainV2Episode> episodes}): _episodes = episodes;
  factory _DomainV2EpisodeGroup.fromJson(Map<String, dynamic> json) => _$DomainV2EpisodeGroupFromJson(json);

@override final  String title;
 final  List<DomainV2Episode> _episodes;
@override List<DomainV2Episode> get episodes {
  if (_episodes is EqualUnmodifiableListView) return _episodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_episodes);
}


/// Create a copy of DomainV2EpisodeGroup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainV2EpisodeGroupCopyWith<_DomainV2EpisodeGroup> get copyWith => __$DomainV2EpisodeGroupCopyWithImpl<_DomainV2EpisodeGroup>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainV2EpisodeGroupToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainV2EpisodeGroup&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._episodes, _episodes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,const DeepCollectionEquality().hash(_episodes));

@override
String toString() {
  return 'DomainV2EpisodeGroup(title: $title, episodes: $episodes)';
}


}

/// @nodoc
abstract mixin class _$DomainV2EpisodeGroupCopyWith<$Res> implements $DomainV2EpisodeGroupCopyWith<$Res> {
  factory _$DomainV2EpisodeGroupCopyWith(_DomainV2EpisodeGroup value, $Res Function(_DomainV2EpisodeGroup) _then) = __$DomainV2EpisodeGroupCopyWithImpl;
@override @useResult
$Res call({
 String title, List<DomainV2Episode> episodes
});




}
/// @nodoc
class __$DomainV2EpisodeGroupCopyWithImpl<$Res>
    implements _$DomainV2EpisodeGroupCopyWith<$Res> {
  __$DomainV2EpisodeGroupCopyWithImpl(this._self, this._then);

  final _DomainV2EpisodeGroup _self;
  final $Res Function(_DomainV2EpisodeGroup) _then;

/// Create a copy of DomainV2EpisodeGroup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? episodes = null,}) {
  return _then(_DomainV2EpisodeGroup(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,episodes: null == episodes ? _self._episodes : episodes // ignore: cast_nullable_to_non_nullable
as List<DomainV2Episode>,
  ));
}


}


/// @nodoc
mixin _$DomainV2Episode {

 String? get name; String get url;
/// Create a copy of DomainV2Episode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainV2EpisodeCopyWith<DomainV2Episode> get copyWith => _$DomainV2EpisodeCopyWithImpl<DomainV2Episode>(this as DomainV2Episode, _$identity);

  /// Serializes this DomainV2Episode to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainV2Episode&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,url);

@override
String toString() {
  return 'DomainV2Episode(name: $name, url: $url)';
}


}

/// @nodoc
abstract mixin class $DomainV2EpisodeCopyWith<$Res>  {
  factory $DomainV2EpisodeCopyWith(DomainV2Episode value, $Res Function(DomainV2Episode) _then) = _$DomainV2EpisodeCopyWithImpl;
@useResult
$Res call({
 String? name, String url
});




}
/// @nodoc
class _$DomainV2EpisodeCopyWithImpl<$Res>
    implements $DomainV2EpisodeCopyWith<$Res> {
  _$DomainV2EpisodeCopyWithImpl(this._self, this._then);

  final DomainV2Episode _self;
  final $Res Function(DomainV2Episode) _then;

/// Create a copy of DomainV2Episode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? url = null,}) {
  return _then(DomainV2Episode(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainV2Episode].
extension DomainV2EpisodePatterns on DomainV2Episode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainV2Episode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainV2Episode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainV2Episode value)  $default,){
final _that = this;
switch (_that) {
case _DomainV2Episode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainV2Episode value)?  $default,){
final _that = this;
switch (_that) {
case _DomainV2Episode() when $default != null:
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
case _DomainV2Episode() when $default != null:
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
case _DomainV2Episode():
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
case _DomainV2Episode() when $default != null:
return $default(_that.name,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainV2Episode implements DomainV2Episode {
  const _DomainV2Episode({this.name, required this.url});
  factory _DomainV2Episode.fromJson(Map<String, dynamic> json) => _$DomainV2EpisodeFromJson(json);

@override final  String? name;
@override final  String url;

/// Create a copy of DomainV2Episode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainV2EpisodeCopyWith<_DomainV2Episode> get copyWith => __$DomainV2EpisodeCopyWithImpl<_DomainV2Episode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainV2EpisodeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainV2Episode&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,url);

@override
String toString() {
  return 'DomainV2Episode(name: $name, url: $url)';
}


}

/// @nodoc
abstract mixin class _$DomainV2EpisodeCopyWith<$Res> implements $DomainV2EpisodeCopyWith<$Res> {
  factory _$DomainV2EpisodeCopyWith(_DomainV2Episode value, $Res Function(_DomainV2Episode) _then) = __$DomainV2EpisodeCopyWithImpl;
@override @useResult
$Res call({
 String? name, String url
});




}
/// @nodoc
class __$DomainV2EpisodeCopyWithImpl<$Res>
    implements _$DomainV2EpisodeCopyWith<$Res> {
  __$DomainV2EpisodeCopyWithImpl(this._self, this._then);

  final _DomainV2Episode _self;
  final $Res Function(_DomainV2Episode) _then;

/// Create a copy of DomainV2Episode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? url = null,}) {
  return _then(_DomainV2Episode(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
