// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_player.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DomainVideoPlayerState {

 bool get showSettings; bool get showControls; bool get isPlaying; Duration get position; Duration get duration; double get speed; String get currentSubtitle; Map<String, String> get qualityMap; double get ratio;
/// Create a copy of DomainVideoPlayerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainVideoPlayerStateCopyWith<DomainVideoPlayerState> get copyWith => _$DomainVideoPlayerStateCopyWithImpl<DomainVideoPlayerState>(this as DomainVideoPlayerState, _$identity);

  /// Serializes this DomainVideoPlayerState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainVideoPlayerState&&(identical(other.showSettings, showSettings) || other.showSettings == showSettings)&&(identical(other.showControls, showControls) || other.showControls == showControls)&&(identical(other.isPlaying, isPlaying) || other.isPlaying == isPlaying)&&(identical(other.position, position) || other.position == position)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.currentSubtitle, currentSubtitle) || other.currentSubtitle == currentSubtitle)&&const DeepCollectionEquality().equals(other.qualityMap, qualityMap)&&(identical(other.ratio, ratio) || other.ratio == ratio));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,showSettings,showControls,isPlaying,position,duration,speed,currentSubtitle,const DeepCollectionEquality().hash(qualityMap),ratio);

@override
String toString() {
  return 'DomainVideoPlayerState(showSettings: $showSettings, showControls: $showControls, isPlaying: $isPlaying, position: $position, duration: $duration, speed: $speed, currentSubtitle: $currentSubtitle, qualityMap: $qualityMap, ratio: $ratio)';
}


}

/// @nodoc
abstract mixin class $DomainVideoPlayerStateCopyWith<$Res>  {
  factory $DomainVideoPlayerStateCopyWith(DomainVideoPlayerState value, $Res Function(DomainVideoPlayerState) _then) = _$DomainVideoPlayerStateCopyWithImpl;
@useResult
$Res call({
 bool showSettings, bool showControls, bool isPlaying, Duration position, Duration duration, double speed, String currentSubtitle, Map<String, String> qualityMap, double ratio
});




}
/// @nodoc
class _$DomainVideoPlayerStateCopyWithImpl<$Res>
    implements $DomainVideoPlayerStateCopyWith<$Res> {
  _$DomainVideoPlayerStateCopyWithImpl(this._self, this._then);

  final DomainVideoPlayerState _self;
  final $Res Function(DomainVideoPlayerState) _then;

/// Create a copy of DomainVideoPlayerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? showSettings = null,Object? showControls = null,Object? isPlaying = null,Object? position = null,Object? duration = null,Object? speed = null,Object? currentSubtitle = null,Object? qualityMap = null,Object? ratio = null,}) {
  return _then(_self.copyWith(
showSettings: null == showSettings ? _self.showSettings : showSettings // ignore: cast_nullable_to_non_nullable
as bool,showControls: null == showControls ? _self.showControls : showControls // ignore: cast_nullable_to_non_nullable
as bool,isPlaying: null == isPlaying ? _self.isPlaying : isPlaying // ignore: cast_nullable_to_non_nullable
as bool,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Duration,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double,currentSubtitle: null == currentSubtitle ? _self.currentSubtitle : currentSubtitle // ignore: cast_nullable_to_non_nullable
as String,qualityMap: null == qualityMap ? _self.qualityMap : qualityMap // ignore: cast_nullable_to_non_nullable
as Map<String, String>,ratio: null == ratio ? _self.ratio : ratio // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainVideoPlayerState].
extension DomainVideoPlayerStatePatterns on DomainVideoPlayerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainVideoPlayerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainVideoPlayerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainVideoPlayerState value)  $default,){
final _that = this;
switch (_that) {
case _DomainVideoPlayerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainVideoPlayerState value)?  $default,){
final _that = this;
switch (_that) {
case _DomainVideoPlayerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool showSettings,  bool showControls,  bool isPlaying,  Duration position,  Duration duration,  double speed,  String currentSubtitle,  Map<String, String> qualityMap,  double ratio)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainVideoPlayerState() when $default != null:
return $default(_that.showSettings,_that.showControls,_that.isPlaying,_that.position,_that.duration,_that.speed,_that.currentSubtitle,_that.qualityMap,_that.ratio);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool showSettings,  bool showControls,  bool isPlaying,  Duration position,  Duration duration,  double speed,  String currentSubtitle,  Map<String, String> qualityMap,  double ratio)  $default,) {final _that = this;
switch (_that) {
case _DomainVideoPlayerState():
return $default(_that.showSettings,_that.showControls,_that.isPlaying,_that.position,_that.duration,_that.speed,_that.currentSubtitle,_that.qualityMap,_that.ratio);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool showSettings,  bool showControls,  bool isPlaying,  Duration position,  Duration duration,  double speed,  String currentSubtitle,  Map<String, String> qualityMap,  double ratio)?  $default,) {final _that = this;
switch (_that) {
case _DomainVideoPlayerState() when $default != null:
return $default(_that.showSettings,_that.showControls,_that.isPlaying,_that.position,_that.duration,_that.speed,_that.currentSubtitle,_that.qualityMap,_that.ratio);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainVideoPlayerState implements DomainVideoPlayerState {
  const _DomainVideoPlayerState({this.showSettings = false, this.showControls = false, this.isPlaying = false, this.position = Duration.zero, this.duration = Duration.zero, this.speed = 1.0, this.currentSubtitle = '', final  Map<String, String> qualityMap = const {}, this.ratio = 0.0}): _qualityMap = qualityMap;
  factory _DomainVideoPlayerState.fromJson(Map<String, dynamic> json) => _$DomainVideoPlayerStateFromJson(json);

@override@JsonKey() final  bool showSettings;
@override@JsonKey() final  bool showControls;
@override@JsonKey() final  bool isPlaying;
@override@JsonKey() final  Duration position;
@override@JsonKey() final  Duration duration;
@override@JsonKey() final  double speed;
@override@JsonKey() final  String currentSubtitle;
 final  Map<String, String> _qualityMap;
@override@JsonKey() Map<String, String> get qualityMap {
  if (_qualityMap is EqualUnmodifiableMapView) return _qualityMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_qualityMap);
}

@override@JsonKey() final  double ratio;

/// Create a copy of DomainVideoPlayerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainVideoPlayerStateCopyWith<_DomainVideoPlayerState> get copyWith => __$DomainVideoPlayerStateCopyWithImpl<_DomainVideoPlayerState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainVideoPlayerStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainVideoPlayerState&&(identical(other.showSettings, showSettings) || other.showSettings == showSettings)&&(identical(other.showControls, showControls) || other.showControls == showControls)&&(identical(other.isPlaying, isPlaying) || other.isPlaying == isPlaying)&&(identical(other.position, position) || other.position == position)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.currentSubtitle, currentSubtitle) || other.currentSubtitle == currentSubtitle)&&const DeepCollectionEquality().equals(other._qualityMap, _qualityMap)&&(identical(other.ratio, ratio) || other.ratio == ratio));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,showSettings,showControls,isPlaying,position,duration,speed,currentSubtitle,const DeepCollectionEquality().hash(_qualityMap),ratio);

@override
String toString() {
  return 'DomainVideoPlayerState(showSettings: $showSettings, showControls: $showControls, isPlaying: $isPlaying, position: $position, duration: $duration, speed: $speed, currentSubtitle: $currentSubtitle, qualityMap: $qualityMap, ratio: $ratio)';
}


}

/// @nodoc
abstract mixin class _$DomainVideoPlayerStateCopyWith<$Res> implements $DomainVideoPlayerStateCopyWith<$Res> {
  factory _$DomainVideoPlayerStateCopyWith(_DomainVideoPlayerState value, $Res Function(_DomainVideoPlayerState) _then) = __$DomainVideoPlayerStateCopyWithImpl;
@override @useResult
$Res call({
 bool showSettings, bool showControls, bool isPlaying, Duration position, Duration duration, double speed, String currentSubtitle, Map<String, String> qualityMap, double ratio
});




}
/// @nodoc
class __$DomainVideoPlayerStateCopyWithImpl<$Res>
    implements _$DomainVideoPlayerStateCopyWith<$Res> {
  __$DomainVideoPlayerStateCopyWithImpl(this._self, this._then);

  final _DomainVideoPlayerState _self;
  final $Res Function(_DomainVideoPlayerState) _then;

/// Create a copy of DomainVideoPlayerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? showSettings = null,Object? showControls = null,Object? isPlaying = null,Object? position = null,Object? duration = null,Object? speed = null,Object? currentSubtitle = null,Object? qualityMap = null,Object? ratio = null,}) {
  return _then(_DomainVideoPlayerState(
showSettings: null == showSettings ? _self.showSettings : showSettings // ignore: cast_nullable_to_non_nullable
as bool,showControls: null == showControls ? _self.showControls : showControls // ignore: cast_nullable_to_non_nullable
as bool,isPlaying: null == isPlaying ? _self.isPlaying : isPlaying // ignore: cast_nullable_to_non_nullable
as bool,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Duration,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double,currentSubtitle: null == currentSubtitle ? _self.currentSubtitle : currentSubtitle // ignore: cast_nullable_to_non_nullable
as String,qualityMap: null == qualityMap ? _self._qualityMap : qualityMap // ignore: cast_nullable_to_non_nullable
as Map<String, String>,ratio: null == ratio ? _self.ratio : ratio // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$DomainVideoQuality {

 String get label; String get url;
/// Create a copy of DomainVideoQuality
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainVideoQualityCopyWith<DomainVideoQuality> get copyWith => _$DomainVideoQualityCopyWithImpl<DomainVideoQuality>(this as DomainVideoQuality, _$identity);

  /// Serializes this DomainVideoQuality to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainVideoQuality&&(identical(other.label, label) || other.label == label)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,url);

@override
String toString() {
  return 'DomainVideoQuality(label: $label, url: $url)';
}


}

/// @nodoc
abstract mixin class $DomainVideoQualityCopyWith<$Res>  {
  factory $DomainVideoQualityCopyWith(DomainVideoQuality value, $Res Function(DomainVideoQuality) _then) = _$DomainVideoQualityCopyWithImpl;
@useResult
$Res call({
 String label, String url
});




}
/// @nodoc
class _$DomainVideoQualityCopyWithImpl<$Res>
    implements $DomainVideoQualityCopyWith<$Res> {
  _$DomainVideoQualityCopyWithImpl(this._self, this._then);

  final DomainVideoQuality _self;
  final $Res Function(DomainVideoQuality) _then;

/// Create a copy of DomainVideoQuality
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? url = null,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainVideoQuality].
extension DomainVideoQualityPatterns on DomainVideoQuality {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainVideoQuality value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainVideoQuality() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainVideoQuality value)  $default,){
final _that = this;
switch (_that) {
case _DomainVideoQuality():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainVideoQuality value)?  $default,){
final _that = this;
switch (_that) {
case _DomainVideoQuality() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainVideoQuality() when $default != null:
return $default(_that.label,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  String url)  $default,) {final _that = this;
switch (_that) {
case _DomainVideoQuality():
return $default(_that.label,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  String url)?  $default,) {final _that = this;
switch (_that) {
case _DomainVideoQuality() when $default != null:
return $default(_that.label,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainVideoQuality implements DomainVideoQuality {
  const _DomainVideoQuality({required this.label, required this.url});
  factory _DomainVideoQuality.fromJson(Map<String, dynamic> json) => _$DomainVideoQualityFromJson(json);

@override final  String label;
@override final  String url;

/// Create a copy of DomainVideoQuality
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainVideoQualityCopyWith<_DomainVideoQuality> get copyWith => __$DomainVideoQualityCopyWithImpl<_DomainVideoQuality>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainVideoQualityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainVideoQuality&&(identical(other.label, label) || other.label == label)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,url);

@override
String toString() {
  return 'DomainVideoQuality(label: $label, url: $url)';
}


}

/// @nodoc
abstract mixin class _$DomainVideoQualityCopyWith<$Res> implements $DomainVideoQualityCopyWith<$Res> {
  factory _$DomainVideoQualityCopyWith(_DomainVideoQuality value, $Res Function(_DomainVideoQuality) _then) = __$DomainVideoQualityCopyWithImpl;
@override @useResult
$Res call({
 String label, String url
});




}
/// @nodoc
class __$DomainVideoQualityCopyWithImpl<$Res>
    implements _$DomainVideoQualityCopyWith<$Res> {
  __$DomainVideoQualityCopyWithImpl(this._self, this._then);

  final _DomainVideoQuality _self;
  final $Res Function(_DomainVideoQuality) _then;

/// Create a copy of DomainVideoQuality
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? url = null,}) {
  return _then(_DomainVideoQuality(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$DomainSubtitle {

 String? get name; String get url; String? get lang;
/// Create a copy of DomainSubtitle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainSubtitleCopyWith<DomainSubtitle> get copyWith => _$DomainSubtitleCopyWithImpl<DomainSubtitle>(this as DomainSubtitle, _$identity);

  /// Serializes this DomainSubtitle to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainSubtitle&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url)&&(identical(other.lang, lang) || other.lang == lang));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,url,lang);

@override
String toString() {
  return 'DomainSubtitle(name: $name, url: $url, lang: $lang)';
}


}

/// @nodoc
abstract mixin class $DomainSubtitleCopyWith<$Res>  {
  factory $DomainSubtitleCopyWith(DomainSubtitle value, $Res Function(DomainSubtitle) _then) = _$DomainSubtitleCopyWithImpl;
@useResult
$Res call({
 String? name, String url, String? lang
});




}
/// @nodoc
class _$DomainSubtitleCopyWithImpl<$Res>
    implements $DomainSubtitleCopyWith<$Res> {
  _$DomainSubtitleCopyWithImpl(this._self, this._then);

  final DomainSubtitle _self;
  final $Res Function(DomainSubtitle) _then;

/// Create a copy of DomainSubtitle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? url = null,Object? lang = freezed,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,lang: freezed == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainSubtitle].
extension DomainSubtitlePatterns on DomainSubtitle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainSubtitle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainSubtitle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainSubtitle value)  $default,){
final _that = this;
switch (_that) {
case _DomainSubtitle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainSubtitle value)?  $default,){
final _that = this;
switch (_that) {
case _DomainSubtitle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  String url,  String? lang)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainSubtitle() when $default != null:
return $default(_that.name,_that.url,_that.lang);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  String url,  String? lang)  $default,) {final _that = this;
switch (_that) {
case _DomainSubtitle():
return $default(_that.name,_that.url,_that.lang);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  String url,  String? lang)?  $default,) {final _that = this;
switch (_that) {
case _DomainSubtitle() when $default != null:
return $default(_that.name,_that.url,_that.lang);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainSubtitle implements DomainSubtitle {
  const _DomainSubtitle({this.name, required this.url, this.lang});
  factory _DomainSubtitle.fromJson(Map<String, dynamic> json) => _$DomainSubtitleFromJson(json);

@override final  String? name;
@override final  String url;
@override final  String? lang;

/// Create a copy of DomainSubtitle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainSubtitleCopyWith<_DomainSubtitle> get copyWith => __$DomainSubtitleCopyWithImpl<_DomainSubtitle>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainSubtitleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainSubtitle&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url)&&(identical(other.lang, lang) || other.lang == lang));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,url,lang);

@override
String toString() {
  return 'DomainSubtitle(name: $name, url: $url, lang: $lang)';
}


}

/// @nodoc
abstract mixin class _$DomainSubtitleCopyWith<$Res> implements $DomainSubtitleCopyWith<$Res> {
  factory _$DomainSubtitleCopyWith(_DomainSubtitle value, $Res Function(_DomainSubtitle) _then) = __$DomainSubtitleCopyWithImpl;
@override @useResult
$Res call({
 String? name, String url, String? lang
});




}
/// @nodoc
class __$DomainSubtitleCopyWithImpl<$Res>
    implements _$DomainSubtitleCopyWith<$Res> {
  __$DomainSubtitleCopyWithImpl(this._self, this._then);

  final _DomainSubtitle _self;
  final $Res Function(_DomainSubtitle) _then;

/// Create a copy of DomainSubtitle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? url = null,Object? lang = freezed,}) {
  return _then(_DomainSubtitle(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,lang: freezed == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
