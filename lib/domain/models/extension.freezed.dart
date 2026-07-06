// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'extension.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DomainExtension {

 String get package; String get author; String get version; String get lang; String get license; ExtensionType get type; String get webSite; String get name; bool get nsfw; String? get icon; String? get url; String? get description;
/// Create a copy of DomainExtension
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainExtensionCopyWith<DomainExtension> get copyWith => _$DomainExtensionCopyWithImpl<DomainExtension>(this as DomainExtension, _$identity);

  /// Serializes this DomainExtension to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainExtension&&(identical(other.package, package) || other.package == package)&&(identical(other.author, author) || other.author == author)&&(identical(other.version, version) || other.version == version)&&(identical(other.lang, lang) || other.lang == lang)&&(identical(other.license, license) || other.license == license)&&(identical(other.type, type) || other.type == type)&&(identical(other.webSite, webSite) || other.webSite == webSite)&&(identical(other.name, name) || other.name == name)&&(identical(other.nsfw, nsfw) || other.nsfw == nsfw)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.url, url) || other.url == url)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,package,author,version,lang,license,type,webSite,name,nsfw,icon,url,description);

@override
String toString() {
  return 'DomainExtension(package: $package, author: $author, version: $version, lang: $lang, license: $license, type: $type, webSite: $webSite, name: $name, nsfw: $nsfw, icon: $icon, url: $url, description: $description)';
}


}

/// @nodoc
abstract mixin class $DomainExtensionCopyWith<$Res>  {
  factory $DomainExtensionCopyWith(DomainExtension value, $Res Function(DomainExtension) _then) = _$DomainExtensionCopyWithImpl;
@useResult
$Res call({
 String package, String author, String version, String lang, String license, ExtensionType type, String webSite, String name, bool nsfw, String? icon, String? url, String? description
});




}
/// @nodoc
class _$DomainExtensionCopyWithImpl<$Res>
    implements $DomainExtensionCopyWith<$Res> {
  _$DomainExtensionCopyWithImpl(this._self, this._then);

  final DomainExtension _self;
  final $Res Function(DomainExtension) _then;

/// Create a copy of DomainExtension
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? package = null,Object? author = null,Object? version = null,Object? lang = null,Object? license = null,Object? type = null,Object? webSite = null,Object? name = null,Object? nsfw = null,Object? icon = freezed,Object? url = freezed,Object? description = freezed,}) {
  return _then(_self.copyWith(
package: null == package ? _self.package : package // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,lang: null == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as String,license: null == license ? _self.license : license // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ExtensionType,webSite: null == webSite ? _self.webSite : webSite // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nsfw: null == nsfw ? _self.nsfw : nsfw // ignore: cast_nullable_to_non_nullable
as bool,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainExtension].
extension DomainExtensionPatterns on DomainExtension {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainExtension value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainExtension() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainExtension value)  $default,){
final _that = this;
switch (_that) {
case _DomainExtension():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainExtension value)?  $default,){
final _that = this;
switch (_that) {
case _DomainExtension() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String package,  String author,  String version,  String lang,  String license,  ExtensionType type,  String webSite,  String name,  bool nsfw,  String? icon,  String? url,  String? description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainExtension() when $default != null:
return $default(_that.package,_that.author,_that.version,_that.lang,_that.license,_that.type,_that.webSite,_that.name,_that.nsfw,_that.icon,_that.url,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String package,  String author,  String version,  String lang,  String license,  ExtensionType type,  String webSite,  String name,  bool nsfw,  String? icon,  String? url,  String? description)  $default,) {final _that = this;
switch (_that) {
case _DomainExtension():
return $default(_that.package,_that.author,_that.version,_that.lang,_that.license,_that.type,_that.webSite,_that.name,_that.nsfw,_that.icon,_that.url,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String package,  String author,  String version,  String lang,  String license,  ExtensionType type,  String webSite,  String name,  bool nsfw,  String? icon,  String? url,  String? description)?  $default,) {final _that = this;
switch (_that) {
case _DomainExtension() when $default != null:
return $default(_that.package,_that.author,_that.version,_that.lang,_that.license,_that.type,_that.webSite,_that.name,_that.nsfw,_that.icon,_that.url,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainExtension implements DomainExtension {
  const _DomainExtension({required this.package, required this.author, required this.version, required this.lang, required this.license, required this.type, required this.webSite, required this.name, this.nsfw = false, this.icon, this.url, this.description});
  factory _DomainExtension.fromJson(Map<String, dynamic> json) => _$DomainExtensionFromJson(json);

@override final  String package;
@override final  String author;
@override final  String version;
@override final  String lang;
@override final  String license;
@override final  ExtensionType type;
@override final  String webSite;
@override final  String name;
@override@JsonKey() final  bool nsfw;
@override final  String? icon;
@override final  String? url;
@override final  String? description;

/// Create a copy of DomainExtension
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainExtensionCopyWith<_DomainExtension> get copyWith => __$DomainExtensionCopyWithImpl<_DomainExtension>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainExtensionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainExtension&&(identical(other.package, package) || other.package == package)&&(identical(other.author, author) || other.author == author)&&(identical(other.version, version) || other.version == version)&&(identical(other.lang, lang) || other.lang == lang)&&(identical(other.license, license) || other.license == license)&&(identical(other.type, type) || other.type == type)&&(identical(other.webSite, webSite) || other.webSite == webSite)&&(identical(other.name, name) || other.name == name)&&(identical(other.nsfw, nsfw) || other.nsfw == nsfw)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.url, url) || other.url == url)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,package,author,version,lang,license,type,webSite,name,nsfw,icon,url,description);

@override
String toString() {
  return 'DomainExtension(package: $package, author: $author, version: $version, lang: $lang, license: $license, type: $type, webSite: $webSite, name: $name, nsfw: $nsfw, icon: $icon, url: $url, description: $description)';
}


}

/// @nodoc
abstract mixin class _$DomainExtensionCopyWith<$Res> implements $DomainExtensionCopyWith<$Res> {
  factory _$DomainExtensionCopyWith(_DomainExtension value, $Res Function(_DomainExtension) _then) = __$DomainExtensionCopyWithImpl;
@override @useResult
$Res call({
 String package, String author, String version, String lang, String license, ExtensionType type, String webSite, String name, bool nsfw, String? icon, String? url, String? description
});




}
/// @nodoc
class __$DomainExtensionCopyWithImpl<$Res>
    implements _$DomainExtensionCopyWith<$Res> {
  __$DomainExtensionCopyWithImpl(this._self, this._then);

  final _DomainExtension _self;
  final $Res Function(_DomainExtension) _then;

/// Create a copy of DomainExtension
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? package = null,Object? author = null,Object? version = null,Object? lang = null,Object? license = null,Object? type = null,Object? webSite = null,Object? name = null,Object? nsfw = null,Object? icon = freezed,Object? url = freezed,Object? description = freezed,}) {
  return _then(_DomainExtension(
package: null == package ? _self.package : package // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,lang: null == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as String,license: null == license ? _self.license : license // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ExtensionType,webSite: null == webSite ? _self.webSite : webSite // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nsfw: null == nsfw ? _self.nsfw : nsfw // ignore: cast_nullable_to_non_nullable
as bool,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$DomainExtensionMeta {

 String get name; String get version; String get author; String get license; String get lang; String? get icon; String get packageName; String get webSite; String? get description; List<dynamic> get tags; String get api; ExtensionType get type; String? get error;
/// Create a copy of DomainExtensionMeta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainExtensionMetaCopyWith<DomainExtensionMeta> get copyWith => _$DomainExtensionMetaCopyWithImpl<DomainExtensionMeta>(this as DomainExtensionMeta, _$identity);

  /// Serializes this DomainExtensionMeta to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainExtensionMeta&&(identical(other.name, name) || other.name == name)&&(identical(other.version, version) || other.version == version)&&(identical(other.author, author) || other.author == author)&&(identical(other.license, license) || other.license == license)&&(identical(other.lang, lang) || other.lang == lang)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.packageName, packageName) || other.packageName == packageName)&&(identical(other.webSite, webSite) || other.webSite == webSite)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.api, api) || other.api == api)&&(identical(other.type, type) || other.type == type)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,version,author,license,lang,icon,packageName,webSite,description,const DeepCollectionEquality().hash(tags),api,type,error);

@override
String toString() {
  return 'DomainExtensionMeta(name: $name, version: $version, author: $author, license: $license, lang: $lang, icon: $icon, packageName: $packageName, webSite: $webSite, description: $description, tags: $tags, api: $api, type: $type, error: $error)';
}


}

/// @nodoc
abstract mixin class $DomainExtensionMetaCopyWith<$Res>  {
  factory $DomainExtensionMetaCopyWith(DomainExtensionMeta value, $Res Function(DomainExtensionMeta) _then) = _$DomainExtensionMetaCopyWithImpl;
@useResult
$Res call({
 String name, String version, String author, String license, String lang, String? icon, String packageName, String webSite, String? description, List<dynamic> tags, String api, ExtensionType type, String? error
});




}
/// @nodoc
class _$DomainExtensionMetaCopyWithImpl<$Res>
    implements $DomainExtensionMetaCopyWith<$Res> {
  _$DomainExtensionMetaCopyWithImpl(this._self, this._then);

  final DomainExtensionMeta _self;
  final $Res Function(DomainExtensionMeta) _then;

/// Create a copy of DomainExtensionMeta
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? version = null,Object? author = null,Object? license = null,Object? lang = null,Object? icon = freezed,Object? packageName = null,Object? webSite = null,Object? description = freezed,Object? tags = null,Object? api = null,Object? type = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,license: null == license ? _self.license : license // ignore: cast_nullable_to_non_nullable
as String,lang: null == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,packageName: null == packageName ? _self.packageName : packageName // ignore: cast_nullable_to_non_nullable
as String,webSite: null == webSite ? _self.webSite : webSite // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<dynamic>,api: null == api ? _self.api : api // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ExtensionType,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainExtensionMeta].
extension DomainExtensionMetaPatterns on DomainExtensionMeta {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainExtensionMeta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainExtensionMeta() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainExtensionMeta value)  $default,){
final _that = this;
switch (_that) {
case _DomainExtensionMeta():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainExtensionMeta value)?  $default,){
final _that = this;
switch (_that) {
case _DomainExtensionMeta() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String version,  String author,  String license,  String lang,  String? icon,  String packageName,  String webSite,  String? description,  List<dynamic> tags,  String api,  ExtensionType type,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainExtensionMeta() when $default != null:
return $default(_that.name,_that.version,_that.author,_that.license,_that.lang,_that.icon,_that.packageName,_that.webSite,_that.description,_that.tags,_that.api,_that.type,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String version,  String author,  String license,  String lang,  String? icon,  String packageName,  String webSite,  String? description,  List<dynamic> tags,  String api,  ExtensionType type,  String? error)  $default,) {final _that = this;
switch (_that) {
case _DomainExtensionMeta():
return $default(_that.name,_that.version,_that.author,_that.license,_that.lang,_that.icon,_that.packageName,_that.webSite,_that.description,_that.tags,_that.api,_that.type,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String version,  String author,  String license,  String lang,  String? icon,  String packageName,  String webSite,  String? description,  List<dynamic> tags,  String api,  ExtensionType type,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _DomainExtensionMeta() when $default != null:
return $default(_that.name,_that.version,_that.author,_that.license,_that.lang,_that.icon,_that.packageName,_that.webSite,_that.description,_that.tags,_that.api,_that.type,_that.error);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainExtensionMeta implements DomainExtensionMeta {
  const _DomainExtensionMeta({this.name = '', this.version = '', this.author = '', this.license = '', this.lang = '', this.icon, this.packageName = '', this.webSite = '', this.description, final  List<dynamic> tags = const [], this.api = '', required this.type, this.error}): _tags = tags;
  factory _DomainExtensionMeta.fromJson(Map<String, dynamic> json) => _$DomainExtensionMetaFromJson(json);

@override@JsonKey() final  String name;
@override@JsonKey() final  String version;
@override@JsonKey() final  String author;
@override@JsonKey() final  String license;
@override@JsonKey() final  String lang;
@override final  String? icon;
@override@JsonKey() final  String packageName;
@override@JsonKey() final  String webSite;
@override final  String? description;
 final  List<dynamic> _tags;
@override@JsonKey() List<dynamic> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override@JsonKey() final  String api;
@override final  ExtensionType type;
@override final  String? error;

/// Create a copy of DomainExtensionMeta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainExtensionMetaCopyWith<_DomainExtensionMeta> get copyWith => __$DomainExtensionMetaCopyWithImpl<_DomainExtensionMeta>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainExtensionMetaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainExtensionMeta&&(identical(other.name, name) || other.name == name)&&(identical(other.version, version) || other.version == version)&&(identical(other.author, author) || other.author == author)&&(identical(other.license, license) || other.license == license)&&(identical(other.lang, lang) || other.lang == lang)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.packageName, packageName) || other.packageName == packageName)&&(identical(other.webSite, webSite) || other.webSite == webSite)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.api, api) || other.api == api)&&(identical(other.type, type) || other.type == type)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,version,author,license,lang,icon,packageName,webSite,description,const DeepCollectionEquality().hash(_tags),api,type,error);

@override
String toString() {
  return 'DomainExtensionMeta(name: $name, version: $version, author: $author, license: $license, lang: $lang, icon: $icon, packageName: $packageName, webSite: $webSite, description: $description, tags: $tags, api: $api, type: $type, error: $error)';
}


}

/// @nodoc
abstract mixin class _$DomainExtensionMetaCopyWith<$Res> implements $DomainExtensionMetaCopyWith<$Res> {
  factory _$DomainExtensionMetaCopyWith(_DomainExtensionMeta value, $Res Function(_DomainExtensionMeta) _then) = __$DomainExtensionMetaCopyWithImpl;
@override @useResult
$Res call({
 String name, String version, String author, String license, String lang, String? icon, String packageName, String webSite, String? description, List<dynamic> tags, String api, ExtensionType type, String? error
});




}
/// @nodoc
class __$DomainExtensionMetaCopyWithImpl<$Res>
    implements _$DomainExtensionMetaCopyWith<$Res> {
  __$DomainExtensionMetaCopyWithImpl(this._self, this._then);

  final _DomainExtensionMeta _self;
  final $Res Function(_DomainExtensionMeta) _then;

/// Create a copy of DomainExtensionMeta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? version = null,Object? author = null,Object? license = null,Object? lang = null,Object? icon = freezed,Object? packageName = null,Object? webSite = null,Object? description = freezed,Object? tags = null,Object? api = null,Object? type = null,Object? error = freezed,}) {
  return _then(_DomainExtensionMeta(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,license: null == license ? _self.license : license // ignore: cast_nullable_to_non_nullable
as String,lang: null == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,packageName: null == packageName ? _self.packageName : packageName // ignore: cast_nullable_to_non_nullable
as String,webSite: null == webSite ? _self.webSite : webSite // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<dynamic>,api: null == api ? _self.api : api // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ExtensionType,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$DomainExtensionRepo {

 String get name; String get url; List<DomainExtensionMeta> get extensions;
/// Create a copy of DomainExtensionRepo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainExtensionRepoCopyWith<DomainExtensionRepo> get copyWith => _$DomainExtensionRepoCopyWithImpl<DomainExtensionRepo>(this as DomainExtensionRepo, _$identity);

  /// Serializes this DomainExtensionRepo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainExtensionRepo&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url)&&const DeepCollectionEquality().equals(other.extensions, extensions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,url,const DeepCollectionEquality().hash(extensions));

@override
String toString() {
  return 'DomainExtensionRepo(name: $name, url: $url, extensions: $extensions)';
}


}

/// @nodoc
abstract mixin class $DomainExtensionRepoCopyWith<$Res>  {
  factory $DomainExtensionRepoCopyWith(DomainExtensionRepo value, $Res Function(DomainExtensionRepo) _then) = _$DomainExtensionRepoCopyWithImpl;
@useResult
$Res call({
 String name, String url, List<DomainExtensionMeta> extensions
});




}
/// @nodoc
class _$DomainExtensionRepoCopyWithImpl<$Res>
    implements $DomainExtensionRepoCopyWith<$Res> {
  _$DomainExtensionRepoCopyWithImpl(this._self, this._then);

  final DomainExtensionRepo _self;
  final $Res Function(DomainExtensionRepo) _then;

/// Create a copy of DomainExtensionRepo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? url = null,Object? extensions = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,extensions: null == extensions ? _self.extensions : extensions // ignore: cast_nullable_to_non_nullable
as List<DomainExtensionMeta>,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainExtensionRepo].
extension DomainExtensionRepoPatterns on DomainExtensionRepo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainExtensionRepo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainExtensionRepo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainExtensionRepo value)  $default,){
final _that = this;
switch (_that) {
case _DomainExtensionRepo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainExtensionRepo value)?  $default,){
final _that = this;
switch (_that) {
case _DomainExtensionRepo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String url,  List<DomainExtensionMeta> extensions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainExtensionRepo() when $default != null:
return $default(_that.name,_that.url,_that.extensions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String url,  List<DomainExtensionMeta> extensions)  $default,) {final _that = this;
switch (_that) {
case _DomainExtensionRepo():
return $default(_that.name,_that.url,_that.extensions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String url,  List<DomainExtensionMeta> extensions)?  $default,) {final _that = this;
switch (_that) {
case _DomainExtensionRepo() when $default != null:
return $default(_that.name,_that.url,_that.extensions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainExtensionRepo implements DomainExtensionRepo {
  const _DomainExtensionRepo({required this.name, required this.url, final  List<DomainExtensionMeta> extensions = const []}): _extensions = extensions;
  factory _DomainExtensionRepo.fromJson(Map<String, dynamic> json) => _$DomainExtensionRepoFromJson(json);

@override final  String name;
@override final  String url;
 final  List<DomainExtensionMeta> _extensions;
@override@JsonKey() List<DomainExtensionMeta> get extensions {
  if (_extensions is EqualUnmodifiableListView) return _extensions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_extensions);
}


/// Create a copy of DomainExtensionRepo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainExtensionRepoCopyWith<_DomainExtensionRepo> get copyWith => __$DomainExtensionRepoCopyWithImpl<_DomainExtensionRepo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainExtensionRepoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainExtensionRepo&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url)&&const DeepCollectionEquality().equals(other._extensions, _extensions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,url,const DeepCollectionEquality().hash(_extensions));

@override
String toString() {
  return 'DomainExtensionRepo(name: $name, url: $url, extensions: $extensions)';
}


}

/// @nodoc
abstract mixin class _$DomainExtensionRepoCopyWith<$Res> implements $DomainExtensionRepoCopyWith<$Res> {
  factory _$DomainExtensionRepoCopyWith(_DomainExtensionRepo value, $Res Function(_DomainExtensionRepo) _then) = __$DomainExtensionRepoCopyWithImpl;
@override @useResult
$Res call({
 String name, String url, List<DomainExtensionMeta> extensions
});




}
/// @nodoc
class __$DomainExtensionRepoCopyWithImpl<$Res>
    implements _$DomainExtensionRepoCopyWith<$Res> {
  __$DomainExtensionRepoCopyWithImpl(this._self, this._then);

  final _DomainExtensionRepo _self;
  final $Res Function(_DomainExtensionRepo) _then;

/// Create a copy of DomainExtensionRepo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? url = null,Object? extensions = null,}) {
  return _then(_DomainExtensionRepo(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,extensions: null == extensions ? _self._extensions : extensions // ignore: cast_nullable_to_non_nullable
as List<DomainExtensionMeta>,
  ));
}


}

// dart format on
