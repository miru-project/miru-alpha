// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'favorite_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FavoriteViewState {

 List<DomainFavoriteGroup> get groups; List<DomainFavorite> get favorites; String? get selectedGroupId;
/// Create a copy of FavoriteViewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FavoriteViewStateCopyWith<FavoriteViewState> get copyWith => _$FavoriteViewStateCopyWithImpl<FavoriteViewState>(this as FavoriteViewState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FavoriteViewState&&const DeepCollectionEquality().equals(other.groups, groups)&&const DeepCollectionEquality().equals(other.favorites, favorites)&&(identical(other.selectedGroupId, selectedGroupId) || other.selectedGroupId == selectedGroupId));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(groups),const DeepCollectionEquality().hash(favorites),selectedGroupId);

@override
String toString() {
  return 'FavoriteViewState(groups: $groups, favorites: $favorites, selectedGroupId: $selectedGroupId)';
}


}

/// @nodoc
abstract mixin class $FavoriteViewStateCopyWith<$Res>  {
  factory $FavoriteViewStateCopyWith(FavoriteViewState value, $Res Function(FavoriteViewState) _then) = _$FavoriteViewStateCopyWithImpl;
@useResult
$Res call({
 List<DomainFavoriteGroup> groups, List<DomainFavorite> favorites, String? selectedGroupId
});




}
/// @nodoc
class _$FavoriteViewStateCopyWithImpl<$Res>
    implements $FavoriteViewStateCopyWith<$Res> {
  _$FavoriteViewStateCopyWithImpl(this._self, this._then);

  final FavoriteViewState _self;
  final $Res Function(FavoriteViewState) _then;

/// Create a copy of FavoriteViewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? groups = null,Object? favorites = null,Object? selectedGroupId = freezed,}) {
  return _then(FavoriteViewState(
groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as List<DomainFavoriteGroup>,favorites: null == favorites ? _self.favorites : favorites // ignore: cast_nullable_to_non_nullable
as List<DomainFavorite>,selectedGroupId: freezed == selectedGroupId ? _self.selectedGroupId : selectedGroupId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FavoriteViewState].
extension FavoriteViewStatePatterns on FavoriteViewState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FavoriteViewState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FavoriteViewState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FavoriteViewState value)  $default,){
final _that = this;
switch (_that) {
case _FavoriteViewState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FavoriteViewState value)?  $default,){
final _that = this;
switch (_that) {
case _FavoriteViewState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<DomainFavoriteGroup> groups,  List<DomainFavorite> favorites,  String? selectedGroupId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FavoriteViewState() when $default != null:
return $default(_that.groups,_that.favorites,_that.selectedGroupId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<DomainFavoriteGroup> groups,  List<DomainFavorite> favorites,  String? selectedGroupId)  $default,) {final _that = this;
switch (_that) {
case _FavoriteViewState():
return $default(_that.groups,_that.favorites,_that.selectedGroupId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<DomainFavoriteGroup> groups,  List<DomainFavorite> favorites,  String? selectedGroupId)?  $default,) {final _that = this;
switch (_that) {
case _FavoriteViewState() when $default != null:
return $default(_that.groups,_that.favorites,_that.selectedGroupId);case _:
  return null;

}
}

}

/// @nodoc


class _FavoriteViewState implements FavoriteViewState {
  const _FavoriteViewState({required  List<DomainFavoriteGroup> groups, required  List<DomainFavorite> favorites, this.selectedGroupId}): _groups = groups,_favorites = favorites;
  

 final  List<DomainFavoriteGroup> _groups;
@override List<DomainFavoriteGroup> get groups {
  if (_groups is EqualUnmodifiableListView) return _groups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groups);
}

 final  List<DomainFavorite> _favorites;
@override List<DomainFavorite> get favorites {
  if (_favorites is EqualUnmodifiableListView) return _favorites;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_favorites);
}

@override final  String? selectedGroupId;

/// Create a copy of FavoriteViewState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FavoriteViewStateCopyWith<_FavoriteViewState> get copyWith => __$FavoriteViewStateCopyWithImpl<_FavoriteViewState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FavoriteViewState&&const DeepCollectionEquality().equals(other._groups, _groups)&&const DeepCollectionEquality().equals(other._favorites, _favorites)&&(identical(other.selectedGroupId, selectedGroupId) || other.selectedGroupId == selectedGroupId));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_groups),const DeepCollectionEquality().hash(_favorites),selectedGroupId);

@override
String toString() {
  return 'FavoriteViewState(groups: $groups, favorites: $favorites, selectedGroupId: $selectedGroupId)';
}


}

/// @nodoc
abstract mixin class _$FavoriteViewStateCopyWith<$Res> implements $FavoriteViewStateCopyWith<$Res> {
  factory _$FavoriteViewStateCopyWith(_FavoriteViewState value, $Res Function(_FavoriteViewState) _then) = __$FavoriteViewStateCopyWithImpl;
@override @useResult
$Res call({
 List<DomainFavoriteGroup> groups, List<DomainFavorite> favorites, String? selectedGroupId
});




}
/// @nodoc
class __$FavoriteViewStateCopyWithImpl<$Res>
    implements _$FavoriteViewStateCopyWith<$Res> {
  __$FavoriteViewStateCopyWithImpl(this._self, this._then);

  final _FavoriteViewState _self;
  final $Res Function(_FavoriteViewState) _then;

/// Create a copy of FavoriteViewState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? groups = null,Object? favorites = null,Object? selectedGroupId = freezed,}) {
  return _then(_FavoriteViewState(
groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as List<DomainFavoriteGroup>,favorites: null == favorites ? _self._favorites : favorites // ignore: cast_nullable_to_non_nullable
as List<DomainFavorite>,selectedGroupId: freezed == selectedGroupId ? _self.selectedGroupId : selectedGroupId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
