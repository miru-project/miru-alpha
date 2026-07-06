// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'favorite.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DomainFavorite {

 String get id; String get package; String get detailUrl; String get title; String? get cover; String get type; String get groupId; DateTime get createdAt; String? get description;
/// Create a copy of DomainFavorite
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainFavoriteCopyWith<DomainFavorite> get copyWith => _$DomainFavoriteCopyWithImpl<DomainFavorite>(this as DomainFavorite, _$identity);

  /// Serializes this DomainFavorite to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainFavorite&&(identical(other.id, id) || other.id == id)&&(identical(other.package, package) || other.package == package)&&(identical(other.detailUrl, detailUrl) || other.detailUrl == detailUrl)&&(identical(other.title, title) || other.title == title)&&(identical(other.cover, cover) || other.cover == cover)&&(identical(other.type, type) || other.type == type)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,package,detailUrl,title,cover,type,groupId,createdAt,description);

@override
String toString() {
  return 'DomainFavorite(id: $id, package: $package, detailUrl: $detailUrl, title: $title, cover: $cover, type: $type, groupId: $groupId, createdAt: $createdAt, description: $description)';
}


}

/// @nodoc
abstract mixin class $DomainFavoriteCopyWith<$Res>  {
  factory $DomainFavoriteCopyWith(DomainFavorite value, $Res Function(DomainFavorite) _then) = _$DomainFavoriteCopyWithImpl;
@useResult
$Res call({
 String id, String package, String detailUrl, String title, String? cover, String type, String groupId, DateTime createdAt, String? description
});




}
/// @nodoc
class _$DomainFavoriteCopyWithImpl<$Res>
    implements $DomainFavoriteCopyWith<$Res> {
  _$DomainFavoriteCopyWithImpl(this._self, this._then);

  final DomainFavorite _self;
  final $Res Function(DomainFavorite) _then;

/// Create a copy of DomainFavorite
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? package = null,Object? detailUrl = null,Object? title = null,Object? cover = freezed,Object? type = null,Object? groupId = null,Object? createdAt = null,Object? description = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,package: null == package ? _self.package : package // ignore: cast_nullable_to_non_nullable
as String,detailUrl: null == detailUrl ? _self.detailUrl : detailUrl // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,cover: freezed == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainFavorite].
extension DomainFavoritePatterns on DomainFavorite {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainFavorite value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainFavorite() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainFavorite value)  $default,){
final _that = this;
switch (_that) {
case _DomainFavorite():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainFavorite value)?  $default,){
final _that = this;
switch (_that) {
case _DomainFavorite() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String package,  String detailUrl,  String title,  String? cover,  String type,  String groupId,  DateTime createdAt,  String? description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainFavorite() when $default != null:
return $default(_that.id,_that.package,_that.detailUrl,_that.title,_that.cover,_that.type,_that.groupId,_that.createdAt,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String package,  String detailUrl,  String title,  String? cover,  String type,  String groupId,  DateTime createdAt,  String? description)  $default,) {final _that = this;
switch (_that) {
case _DomainFavorite():
return $default(_that.id,_that.package,_that.detailUrl,_that.title,_that.cover,_that.type,_that.groupId,_that.createdAt,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String package,  String detailUrl,  String title,  String? cover,  String type,  String groupId,  DateTime createdAt,  String? description)?  $default,) {final _that = this;
switch (_that) {
case _DomainFavorite() when $default != null:
return $default(_that.id,_that.package,_that.detailUrl,_that.title,_that.cover,_that.type,_that.groupId,_that.createdAt,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainFavorite implements DomainFavorite {
  const _DomainFavorite({required this.id, required this.package, required this.detailUrl, required this.title, this.cover, required this.type, required this.groupId, required this.createdAt, this.description});
  factory _DomainFavorite.fromJson(Map<String, dynamic> json) => _$DomainFavoriteFromJson(json);

@override final  String id;
@override final  String package;
@override final  String detailUrl;
@override final  String title;
@override final  String? cover;
@override final  String type;
@override final  String groupId;
@override final  DateTime createdAt;
@override final  String? description;

/// Create a copy of DomainFavorite
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainFavoriteCopyWith<_DomainFavorite> get copyWith => __$DomainFavoriteCopyWithImpl<_DomainFavorite>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainFavoriteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainFavorite&&(identical(other.id, id) || other.id == id)&&(identical(other.package, package) || other.package == package)&&(identical(other.detailUrl, detailUrl) || other.detailUrl == detailUrl)&&(identical(other.title, title) || other.title == title)&&(identical(other.cover, cover) || other.cover == cover)&&(identical(other.type, type) || other.type == type)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,package,detailUrl,title,cover,type,groupId,createdAt,description);

@override
String toString() {
  return 'DomainFavorite(id: $id, package: $package, detailUrl: $detailUrl, title: $title, cover: $cover, type: $type, groupId: $groupId, createdAt: $createdAt, description: $description)';
}


}

/// @nodoc
abstract mixin class _$DomainFavoriteCopyWith<$Res> implements $DomainFavoriteCopyWith<$Res> {
  factory _$DomainFavoriteCopyWith(_DomainFavorite value, $Res Function(_DomainFavorite) _then) = __$DomainFavoriteCopyWithImpl;
@override @useResult
$Res call({
 String id, String package, String detailUrl, String title, String? cover, String type, String groupId, DateTime createdAt, String? description
});




}
/// @nodoc
class __$DomainFavoriteCopyWithImpl<$Res>
    implements _$DomainFavoriteCopyWith<$Res> {
  __$DomainFavoriteCopyWithImpl(this._self, this._then);

  final _DomainFavorite _self;
  final $Res Function(_DomainFavorite) _then;

/// Create a copy of DomainFavorite
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? package = null,Object? detailUrl = null,Object? title = null,Object? cover = freezed,Object? type = null,Object? groupId = null,Object? createdAt = null,Object? description = freezed,}) {
  return _then(_DomainFavorite(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,package: null == package ? _self.package : package // ignore: cast_nullable_to_non_nullable
as String,detailUrl: null == detailUrl ? _self.detailUrl : detailUrl // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,cover: freezed == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$DomainFavoriteGroup {

 String get id; String get name; String get type; int get order; DateTime get createdAt; String? get icon;
/// Create a copy of DomainFavoriteGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainFavoriteGroupCopyWith<DomainFavoriteGroup> get copyWith => _$DomainFavoriteGroupCopyWithImpl<DomainFavoriteGroup>(this as DomainFavoriteGroup, _$identity);

  /// Serializes this DomainFavoriteGroup to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainFavoriteGroup&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.order, order) || other.order == order)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.icon, icon) || other.icon == icon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,order,createdAt,icon);

@override
String toString() {
  return 'DomainFavoriteGroup(id: $id, name: $name, type: $type, order: $order, createdAt: $createdAt, icon: $icon)';
}


}

/// @nodoc
abstract mixin class $DomainFavoriteGroupCopyWith<$Res>  {
  factory $DomainFavoriteGroupCopyWith(DomainFavoriteGroup value, $Res Function(DomainFavoriteGroup) _then) = _$DomainFavoriteGroupCopyWithImpl;
@useResult
$Res call({
 String id, String name, String type, int order, DateTime createdAt, String? icon
});




}
/// @nodoc
class _$DomainFavoriteGroupCopyWithImpl<$Res>
    implements $DomainFavoriteGroupCopyWith<$Res> {
  _$DomainFavoriteGroupCopyWithImpl(this._self, this._then);

  final DomainFavoriteGroup _self;
  final $Res Function(DomainFavoriteGroup) _then;

/// Create a copy of DomainFavoriteGroup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? order = null,Object? createdAt = null,Object? icon = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainFavoriteGroup].
extension DomainFavoriteGroupPatterns on DomainFavoriteGroup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainFavoriteGroup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainFavoriteGroup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainFavoriteGroup value)  $default,){
final _that = this;
switch (_that) {
case _DomainFavoriteGroup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainFavoriteGroup value)?  $default,){
final _that = this;
switch (_that) {
case _DomainFavoriteGroup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String type,  int order,  DateTime createdAt,  String? icon)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainFavoriteGroup() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.order,_that.createdAt,_that.icon);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String type,  int order,  DateTime createdAt,  String? icon)  $default,) {final _that = this;
switch (_that) {
case _DomainFavoriteGroup():
return $default(_that.id,_that.name,_that.type,_that.order,_that.createdAt,_that.icon);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String type,  int order,  DateTime createdAt,  String? icon)?  $default,) {final _that = this;
switch (_that) {
case _DomainFavoriteGroup() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.order,_that.createdAt,_that.icon);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainFavoriteGroup implements DomainFavoriteGroup {
  const _DomainFavoriteGroup({required this.id, required this.name, required this.type, required this.order, required this.createdAt, this.icon});
  factory _DomainFavoriteGroup.fromJson(Map<String, dynamic> json) => _$DomainFavoriteGroupFromJson(json);

@override final  String id;
@override final  String name;
@override final  String type;
@override final  int order;
@override final  DateTime createdAt;
@override final  String? icon;

/// Create a copy of DomainFavoriteGroup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainFavoriteGroupCopyWith<_DomainFavoriteGroup> get copyWith => __$DomainFavoriteGroupCopyWithImpl<_DomainFavoriteGroup>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainFavoriteGroupToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainFavoriteGroup&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.order, order) || other.order == order)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.icon, icon) || other.icon == icon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,order,createdAt,icon);

@override
String toString() {
  return 'DomainFavoriteGroup(id: $id, name: $name, type: $type, order: $order, createdAt: $createdAt, icon: $icon)';
}


}

/// @nodoc
abstract mixin class _$DomainFavoriteGroupCopyWith<$Res> implements $DomainFavoriteGroupCopyWith<$Res> {
  factory _$DomainFavoriteGroupCopyWith(_DomainFavoriteGroup value, $Res Function(_DomainFavoriteGroup) _then) = __$DomainFavoriteGroupCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String type, int order, DateTime createdAt, String? icon
});




}
/// @nodoc
class __$DomainFavoriteGroupCopyWithImpl<$Res>
    implements _$DomainFavoriteGroupCopyWith<$Res> {
  __$DomainFavoriteGroupCopyWithImpl(this._self, this._then);

  final _DomainFavoriteGroup _self;
  final $Res Function(_DomainFavoriteGroup) _then;

/// Create a copy of DomainFavoriteGroup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? order = null,Object? createdAt = null,Object? icon = freezed,}) {
  return _then(_DomainFavoriteGroup(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
