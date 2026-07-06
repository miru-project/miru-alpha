// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tracking_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TrackingViewState {

 DomainTrackingAccount? get anilistAccount; List<DomainTrackingProgress> get progress; List<DomainTMDBTrack> get tmdbTracks; bool get isLoading;
/// Create a copy of TrackingViewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrackingViewStateCopyWith<TrackingViewState> get copyWith => _$TrackingViewStateCopyWithImpl<TrackingViewState>(this as TrackingViewState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrackingViewState&&(identical(other.anilistAccount, anilistAccount) || other.anilistAccount == anilistAccount)&&const DeepCollectionEquality().equals(other.progress, progress)&&const DeepCollectionEquality().equals(other.tmdbTracks, tmdbTracks)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,anilistAccount,const DeepCollectionEquality().hash(progress),const DeepCollectionEquality().hash(tmdbTracks),isLoading);

@override
String toString() {
  return 'TrackingViewState(anilistAccount: $anilistAccount, progress: $progress, tmdbTracks: $tmdbTracks, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class $TrackingViewStateCopyWith<$Res>  {
  factory $TrackingViewStateCopyWith(TrackingViewState value, $Res Function(TrackingViewState) _then) = _$TrackingViewStateCopyWithImpl;
@useResult
$Res call({
 DomainTrackingAccount? anilistAccount, List<DomainTrackingProgress> progress, List<DomainTMDBTrack> tmdbTracks, bool isLoading
});


$DomainTrackingAccountCopyWith<$Res>? get anilistAccount;

}
/// @nodoc
class _$TrackingViewStateCopyWithImpl<$Res>
    implements $TrackingViewStateCopyWith<$Res> {
  _$TrackingViewStateCopyWithImpl(this._self, this._then);

  final TrackingViewState _self;
  final $Res Function(TrackingViewState) _then;

/// Create a copy of TrackingViewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? anilistAccount = freezed,Object? progress = null,Object? tmdbTracks = null,Object? isLoading = null,}) {
  return _then(_self.copyWith(
anilistAccount: freezed == anilistAccount ? _self.anilistAccount : anilistAccount // ignore: cast_nullable_to_non_nullable
as DomainTrackingAccount?,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as List<DomainTrackingProgress>,tmdbTracks: null == tmdbTracks ? _self.tmdbTracks : tmdbTracks // ignore: cast_nullable_to_non_nullable
as List<DomainTMDBTrack>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of TrackingViewState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DomainTrackingAccountCopyWith<$Res>? get anilistAccount {
    if (_self.anilistAccount == null) {
    return null;
  }

  return $DomainTrackingAccountCopyWith<$Res>(_self.anilistAccount!, (value) {
    return _then(_self.copyWith(anilistAccount: value));
  });
}
}


/// Adds pattern-matching-related methods to [TrackingViewState].
extension TrackingViewStatePatterns on TrackingViewState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrackingViewState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrackingViewState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrackingViewState value)  $default,){
final _that = this;
switch (_that) {
case _TrackingViewState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrackingViewState value)?  $default,){
final _that = this;
switch (_that) {
case _TrackingViewState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DomainTrackingAccount? anilistAccount,  List<DomainTrackingProgress> progress,  List<DomainTMDBTrack> tmdbTracks,  bool isLoading)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrackingViewState() when $default != null:
return $default(_that.anilistAccount,_that.progress,_that.tmdbTracks,_that.isLoading);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DomainTrackingAccount? anilistAccount,  List<DomainTrackingProgress> progress,  List<DomainTMDBTrack> tmdbTracks,  bool isLoading)  $default,) {final _that = this;
switch (_that) {
case _TrackingViewState():
return $default(_that.anilistAccount,_that.progress,_that.tmdbTracks,_that.isLoading);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DomainTrackingAccount? anilistAccount,  List<DomainTrackingProgress> progress,  List<DomainTMDBTrack> tmdbTracks,  bool isLoading)?  $default,) {final _that = this;
switch (_that) {
case _TrackingViewState() when $default != null:
return $default(_that.anilistAccount,_that.progress,_that.tmdbTracks,_that.isLoading);case _:
  return null;

}
}

}

/// @nodoc


class _TrackingViewState implements TrackingViewState {
  const _TrackingViewState({this.anilistAccount, final  List<DomainTrackingProgress> progress = const [], final  List<DomainTMDBTrack> tmdbTracks = const [], this.isLoading = false}): _progress = progress,_tmdbTracks = tmdbTracks;
  

@override final  DomainTrackingAccount? anilistAccount;
 final  List<DomainTrackingProgress> _progress;
@override@JsonKey() List<DomainTrackingProgress> get progress {
  if (_progress is EqualUnmodifiableListView) return _progress;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_progress);
}

 final  List<DomainTMDBTrack> _tmdbTracks;
@override@JsonKey() List<DomainTMDBTrack> get tmdbTracks {
  if (_tmdbTracks is EqualUnmodifiableListView) return _tmdbTracks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tmdbTracks);
}

@override@JsonKey() final  bool isLoading;

/// Create a copy of TrackingViewState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrackingViewStateCopyWith<_TrackingViewState> get copyWith => __$TrackingViewStateCopyWithImpl<_TrackingViewState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrackingViewState&&(identical(other.anilistAccount, anilistAccount) || other.anilistAccount == anilistAccount)&&const DeepCollectionEquality().equals(other._progress, _progress)&&const DeepCollectionEquality().equals(other._tmdbTracks, _tmdbTracks)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,anilistAccount,const DeepCollectionEquality().hash(_progress),const DeepCollectionEquality().hash(_tmdbTracks),isLoading);

@override
String toString() {
  return 'TrackingViewState(anilistAccount: $anilistAccount, progress: $progress, tmdbTracks: $tmdbTracks, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class _$TrackingViewStateCopyWith<$Res> implements $TrackingViewStateCopyWith<$Res> {
  factory _$TrackingViewStateCopyWith(_TrackingViewState value, $Res Function(_TrackingViewState) _then) = __$TrackingViewStateCopyWithImpl;
@override @useResult
$Res call({
 DomainTrackingAccount? anilistAccount, List<DomainTrackingProgress> progress, List<DomainTMDBTrack> tmdbTracks, bool isLoading
});


@override $DomainTrackingAccountCopyWith<$Res>? get anilistAccount;

}
/// @nodoc
class __$TrackingViewStateCopyWithImpl<$Res>
    implements _$TrackingViewStateCopyWith<$Res> {
  __$TrackingViewStateCopyWithImpl(this._self, this._then);

  final _TrackingViewState _self;
  final $Res Function(_TrackingViewState) _then;

/// Create a copy of TrackingViewState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? anilistAccount = freezed,Object? progress = null,Object? tmdbTracks = null,Object? isLoading = null,}) {
  return _then(_TrackingViewState(
anilistAccount: freezed == anilistAccount ? _self.anilistAccount : anilistAccount // ignore: cast_nullable_to_non_nullable
as DomainTrackingAccount?,progress: null == progress ? _self._progress : progress // ignore: cast_nullable_to_non_nullable
as List<DomainTrackingProgress>,tmdbTracks: null == tmdbTracks ? _self._tmdbTracks : tmdbTracks // ignore: cast_nullable_to_non_nullable
as List<DomainTMDBTrack>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of TrackingViewState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DomainTrackingAccountCopyWith<$Res>? get anilistAccount {
    if (_self.anilistAccount == null) {
    return null;
  }

  return $DomainTrackingAccountCopyWith<$Res>(_self.anilistAccount!, (value) {
    return _then(_self.copyWith(anilistAccount: value));
  });
}
}

// dart format on
