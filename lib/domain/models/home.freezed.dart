// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DomainHomeState {

 HomeTab get selectedTab; List<DomainExtensionMeta> get libraryExtensions; List<DomainHistoryItem> get historyItems; List<DomainFavoriteGroup> get favoriteGroups; List<DomainFavorite> get favorites; List<DomainDownload> get activeDownloads; List<DomainDownload> get finishedDownloads; bool get isLoading; String? get error;
/// Create a copy of DomainHomeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainHomeStateCopyWith<DomainHomeState> get copyWith => _$DomainHomeStateCopyWithImpl<DomainHomeState>(this as DomainHomeState, _$identity);

  /// Serializes this DomainHomeState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainHomeState&&(identical(other.selectedTab, selectedTab) || other.selectedTab == selectedTab)&&const DeepCollectionEquality().equals(other.libraryExtensions, libraryExtensions)&&const DeepCollectionEquality().equals(other.historyItems, historyItems)&&const DeepCollectionEquality().equals(other.favoriteGroups, favoriteGroups)&&const DeepCollectionEquality().equals(other.favorites, favorites)&&const DeepCollectionEquality().equals(other.activeDownloads, activeDownloads)&&const DeepCollectionEquality().equals(other.finishedDownloads, finishedDownloads)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,selectedTab,const DeepCollectionEquality().hash(libraryExtensions),const DeepCollectionEquality().hash(historyItems),const DeepCollectionEquality().hash(favoriteGroups),const DeepCollectionEquality().hash(favorites),const DeepCollectionEquality().hash(activeDownloads),const DeepCollectionEquality().hash(finishedDownloads),isLoading,error);

@override
String toString() {
  return 'DomainHomeState(selectedTab: $selectedTab, libraryExtensions: $libraryExtensions, historyItems: $historyItems, favoriteGroups: $favoriteGroups, favorites: $favorites, activeDownloads: $activeDownloads, finishedDownloads: $finishedDownloads, isLoading: $isLoading, error: $error)';
}


}

/// @nodoc
abstract mixin class $DomainHomeStateCopyWith<$Res>  {
  factory $DomainHomeStateCopyWith(DomainHomeState value, $Res Function(DomainHomeState) _then) = _$DomainHomeStateCopyWithImpl;
@useResult
$Res call({
 HomeTab selectedTab, List<DomainExtensionMeta> libraryExtensions, List<DomainHistoryItem> historyItems, List<DomainFavoriteGroup> favoriteGroups, List<DomainFavorite> favorites, List<DomainDownload> activeDownloads, List<DomainDownload> finishedDownloads, bool isLoading, String? error
});




}
/// @nodoc
class _$DomainHomeStateCopyWithImpl<$Res>
    implements $DomainHomeStateCopyWith<$Res> {
  _$DomainHomeStateCopyWithImpl(this._self, this._then);

  final DomainHomeState _self;
  final $Res Function(DomainHomeState) _then;

/// Create a copy of DomainHomeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedTab = null,Object? libraryExtensions = null,Object? historyItems = null,Object? favoriteGroups = null,Object? favorites = null,Object? activeDownloads = null,Object? finishedDownloads = null,Object? isLoading = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
selectedTab: null == selectedTab ? _self.selectedTab : selectedTab // ignore: cast_nullable_to_non_nullable
as HomeTab,libraryExtensions: null == libraryExtensions ? _self.libraryExtensions : libraryExtensions // ignore: cast_nullable_to_non_nullable
as List<DomainExtensionMeta>,historyItems: null == historyItems ? _self.historyItems : historyItems // ignore: cast_nullable_to_non_nullable
as List<DomainHistoryItem>,favoriteGroups: null == favoriteGroups ? _self.favoriteGroups : favoriteGroups // ignore: cast_nullable_to_non_nullable
as List<DomainFavoriteGroup>,favorites: null == favorites ? _self.favorites : favorites // ignore: cast_nullable_to_non_nullable
as List<DomainFavorite>,activeDownloads: null == activeDownloads ? _self.activeDownloads : activeDownloads // ignore: cast_nullable_to_non_nullable
as List<DomainDownload>,finishedDownloads: null == finishedDownloads ? _self.finishedDownloads : finishedDownloads // ignore: cast_nullable_to_non_nullable
as List<DomainDownload>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainHomeState].
extension DomainHomeStatePatterns on DomainHomeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainHomeState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainHomeState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainHomeState value)  $default,){
final _that = this;
switch (_that) {
case _DomainHomeState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainHomeState value)?  $default,){
final _that = this;
switch (_that) {
case _DomainHomeState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( HomeTab selectedTab,  List<DomainExtensionMeta> libraryExtensions,  List<DomainHistoryItem> historyItems,  List<DomainFavoriteGroup> favoriteGroups,  List<DomainFavorite> favorites,  List<DomainDownload> activeDownloads,  List<DomainDownload> finishedDownloads,  bool isLoading,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainHomeState() when $default != null:
return $default(_that.selectedTab,_that.libraryExtensions,_that.historyItems,_that.favoriteGroups,_that.favorites,_that.activeDownloads,_that.finishedDownloads,_that.isLoading,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( HomeTab selectedTab,  List<DomainExtensionMeta> libraryExtensions,  List<DomainHistoryItem> historyItems,  List<DomainFavoriteGroup> favoriteGroups,  List<DomainFavorite> favorites,  List<DomainDownload> activeDownloads,  List<DomainDownload> finishedDownloads,  bool isLoading,  String? error)  $default,) {final _that = this;
switch (_that) {
case _DomainHomeState():
return $default(_that.selectedTab,_that.libraryExtensions,_that.historyItems,_that.favoriteGroups,_that.favorites,_that.activeDownloads,_that.finishedDownloads,_that.isLoading,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( HomeTab selectedTab,  List<DomainExtensionMeta> libraryExtensions,  List<DomainHistoryItem> historyItems,  List<DomainFavoriteGroup> favoriteGroups,  List<DomainFavorite> favorites,  List<DomainDownload> activeDownloads,  List<DomainDownload> finishedDownloads,  bool isLoading,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _DomainHomeState() when $default != null:
return $default(_that.selectedTab,_that.libraryExtensions,_that.historyItems,_that.favoriteGroups,_that.favorites,_that.activeDownloads,_that.finishedDownloads,_that.isLoading,_that.error);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainHomeState implements DomainHomeState {
  const _DomainHomeState({this.selectedTab = HomeTab.library, required final  List<DomainExtensionMeta> libraryExtensions, required final  List<DomainHistoryItem> historyItems, required final  List<DomainFavoriteGroup> favoriteGroups, required final  List<DomainFavorite> favorites, required final  List<DomainDownload> activeDownloads, required final  List<DomainDownload> finishedDownloads, this.isLoading = false, this.error}): _libraryExtensions = libraryExtensions,_historyItems = historyItems,_favoriteGroups = favoriteGroups,_favorites = favorites,_activeDownloads = activeDownloads,_finishedDownloads = finishedDownloads;
  factory _DomainHomeState.fromJson(Map<String, dynamic> json) => _$DomainHomeStateFromJson(json);

@override@JsonKey() final  HomeTab selectedTab;
 final  List<DomainExtensionMeta> _libraryExtensions;
@override List<DomainExtensionMeta> get libraryExtensions {
  if (_libraryExtensions is EqualUnmodifiableListView) return _libraryExtensions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_libraryExtensions);
}

 final  List<DomainHistoryItem> _historyItems;
@override List<DomainHistoryItem> get historyItems {
  if (_historyItems is EqualUnmodifiableListView) return _historyItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_historyItems);
}

 final  List<DomainFavoriteGroup> _favoriteGroups;
@override List<DomainFavoriteGroup> get favoriteGroups {
  if (_favoriteGroups is EqualUnmodifiableListView) return _favoriteGroups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_favoriteGroups);
}

 final  List<DomainFavorite> _favorites;
@override List<DomainFavorite> get favorites {
  if (_favorites is EqualUnmodifiableListView) return _favorites;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_favorites);
}

 final  List<DomainDownload> _activeDownloads;
@override List<DomainDownload> get activeDownloads {
  if (_activeDownloads is EqualUnmodifiableListView) return _activeDownloads;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_activeDownloads);
}

 final  List<DomainDownload> _finishedDownloads;
@override List<DomainDownload> get finishedDownloads {
  if (_finishedDownloads is EqualUnmodifiableListView) return _finishedDownloads;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_finishedDownloads);
}

@override@JsonKey() final  bool isLoading;
@override final  String? error;

/// Create a copy of DomainHomeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainHomeStateCopyWith<_DomainHomeState> get copyWith => __$DomainHomeStateCopyWithImpl<_DomainHomeState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainHomeStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainHomeState&&(identical(other.selectedTab, selectedTab) || other.selectedTab == selectedTab)&&const DeepCollectionEquality().equals(other._libraryExtensions, _libraryExtensions)&&const DeepCollectionEquality().equals(other._historyItems, _historyItems)&&const DeepCollectionEquality().equals(other._favoriteGroups, _favoriteGroups)&&const DeepCollectionEquality().equals(other._favorites, _favorites)&&const DeepCollectionEquality().equals(other._activeDownloads, _activeDownloads)&&const DeepCollectionEquality().equals(other._finishedDownloads, _finishedDownloads)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,selectedTab,const DeepCollectionEquality().hash(_libraryExtensions),const DeepCollectionEquality().hash(_historyItems),const DeepCollectionEquality().hash(_favoriteGroups),const DeepCollectionEquality().hash(_favorites),const DeepCollectionEquality().hash(_activeDownloads),const DeepCollectionEquality().hash(_finishedDownloads),isLoading,error);

@override
String toString() {
  return 'DomainHomeState(selectedTab: $selectedTab, libraryExtensions: $libraryExtensions, historyItems: $historyItems, favoriteGroups: $favoriteGroups, favorites: $favorites, activeDownloads: $activeDownloads, finishedDownloads: $finishedDownloads, isLoading: $isLoading, error: $error)';
}


}

/// @nodoc
abstract mixin class _$DomainHomeStateCopyWith<$Res> implements $DomainHomeStateCopyWith<$Res> {
  factory _$DomainHomeStateCopyWith(_DomainHomeState value, $Res Function(_DomainHomeState) _then) = __$DomainHomeStateCopyWithImpl;
@override @useResult
$Res call({
 HomeTab selectedTab, List<DomainExtensionMeta> libraryExtensions, List<DomainHistoryItem> historyItems, List<DomainFavoriteGroup> favoriteGroups, List<DomainFavorite> favorites, List<DomainDownload> activeDownloads, List<DomainDownload> finishedDownloads, bool isLoading, String? error
});




}
/// @nodoc
class __$DomainHomeStateCopyWithImpl<$Res>
    implements _$DomainHomeStateCopyWith<$Res> {
  __$DomainHomeStateCopyWithImpl(this._self, this._then);

  final _DomainHomeState _self;
  final $Res Function(_DomainHomeState) _then;

/// Create a copy of DomainHomeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedTab = null,Object? libraryExtensions = null,Object? historyItems = null,Object? favoriteGroups = null,Object? favorites = null,Object? activeDownloads = null,Object? finishedDownloads = null,Object? isLoading = null,Object? error = freezed,}) {
  return _then(_DomainHomeState(
selectedTab: null == selectedTab ? _self.selectedTab : selectedTab // ignore: cast_nullable_to_non_nullable
as HomeTab,libraryExtensions: null == libraryExtensions ? _self._libraryExtensions : libraryExtensions // ignore: cast_nullable_to_non_nullable
as List<DomainExtensionMeta>,historyItems: null == historyItems ? _self._historyItems : historyItems // ignore: cast_nullable_to_non_nullable
as List<DomainHistoryItem>,favoriteGroups: null == favoriteGroups ? _self._favoriteGroups : favoriteGroups // ignore: cast_nullable_to_non_nullable
as List<DomainFavoriteGroup>,favorites: null == favorites ? _self._favorites : favorites // ignore: cast_nullable_to_non_nullable
as List<DomainFavorite>,activeDownloads: null == activeDownloads ? _self._activeDownloads : activeDownloads // ignore: cast_nullable_to_non_nullable
as List<DomainDownload>,finishedDownloads: null == finishedDownloads ? _self._finishedDownloads : finishedDownloads // ignore: cast_nullable_to_non_nullable
as List<DomainDownload>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$DomainLibrarySection {

 List<DomainExtensionMeta> get extensions; List<String> get pinnedPackages; String? get query;
/// Create a copy of DomainLibrarySection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainLibrarySectionCopyWith<DomainLibrarySection> get copyWith => _$DomainLibrarySectionCopyWithImpl<DomainLibrarySection>(this as DomainLibrarySection, _$identity);

  /// Serializes this DomainLibrarySection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainLibrarySection&&const DeepCollectionEquality().equals(other.extensions, extensions)&&const DeepCollectionEquality().equals(other.pinnedPackages, pinnedPackages)&&(identical(other.query, query) || other.query == query));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(extensions),const DeepCollectionEquality().hash(pinnedPackages),query);

@override
String toString() {
  return 'DomainLibrarySection(extensions: $extensions, pinnedPackages: $pinnedPackages, query: $query)';
}


}

/// @nodoc
abstract mixin class $DomainLibrarySectionCopyWith<$Res>  {
  factory $DomainLibrarySectionCopyWith(DomainLibrarySection value, $Res Function(DomainLibrarySection) _then) = _$DomainLibrarySectionCopyWithImpl;
@useResult
$Res call({
 List<DomainExtensionMeta> extensions, List<String> pinnedPackages, String? query
});




}
/// @nodoc
class _$DomainLibrarySectionCopyWithImpl<$Res>
    implements $DomainLibrarySectionCopyWith<$Res> {
  _$DomainLibrarySectionCopyWithImpl(this._self, this._then);

  final DomainLibrarySection _self;
  final $Res Function(DomainLibrarySection) _then;

/// Create a copy of DomainLibrarySection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? extensions = null,Object? pinnedPackages = null,Object? query = freezed,}) {
  return _then(_self.copyWith(
extensions: null == extensions ? _self.extensions : extensions // ignore: cast_nullable_to_non_nullable
as List<DomainExtensionMeta>,pinnedPackages: null == pinnedPackages ? _self.pinnedPackages : pinnedPackages // ignore: cast_nullable_to_non_nullable
as List<String>,query: freezed == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainLibrarySection].
extension DomainLibrarySectionPatterns on DomainLibrarySection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainLibrarySection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainLibrarySection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainLibrarySection value)  $default,){
final _that = this;
switch (_that) {
case _DomainLibrarySection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainLibrarySection value)?  $default,){
final _that = this;
switch (_that) {
case _DomainLibrarySection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<DomainExtensionMeta> extensions,  List<String> pinnedPackages,  String? query)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainLibrarySection() when $default != null:
return $default(_that.extensions,_that.pinnedPackages,_that.query);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<DomainExtensionMeta> extensions,  List<String> pinnedPackages,  String? query)  $default,) {final _that = this;
switch (_that) {
case _DomainLibrarySection():
return $default(_that.extensions,_that.pinnedPackages,_that.query);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<DomainExtensionMeta> extensions,  List<String> pinnedPackages,  String? query)?  $default,) {final _that = this;
switch (_that) {
case _DomainLibrarySection() when $default != null:
return $default(_that.extensions,_that.pinnedPackages,_that.query);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainLibrarySection implements DomainLibrarySection {
  const _DomainLibrarySection({required final  List<DomainExtensionMeta> extensions, required final  List<String> pinnedPackages, this.query}): _extensions = extensions,_pinnedPackages = pinnedPackages;
  factory _DomainLibrarySection.fromJson(Map<String, dynamic> json) => _$DomainLibrarySectionFromJson(json);

 final  List<DomainExtensionMeta> _extensions;
@override List<DomainExtensionMeta> get extensions {
  if (_extensions is EqualUnmodifiableListView) return _extensions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_extensions);
}

 final  List<String> _pinnedPackages;
@override List<String> get pinnedPackages {
  if (_pinnedPackages is EqualUnmodifiableListView) return _pinnedPackages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pinnedPackages);
}

@override final  String? query;

/// Create a copy of DomainLibrarySection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainLibrarySectionCopyWith<_DomainLibrarySection> get copyWith => __$DomainLibrarySectionCopyWithImpl<_DomainLibrarySection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainLibrarySectionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainLibrarySection&&const DeepCollectionEquality().equals(other._extensions, _extensions)&&const DeepCollectionEquality().equals(other._pinnedPackages, _pinnedPackages)&&(identical(other.query, query) || other.query == query));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_extensions),const DeepCollectionEquality().hash(_pinnedPackages),query);

@override
String toString() {
  return 'DomainLibrarySection(extensions: $extensions, pinnedPackages: $pinnedPackages, query: $query)';
}


}

/// @nodoc
abstract mixin class _$DomainLibrarySectionCopyWith<$Res> implements $DomainLibrarySectionCopyWith<$Res> {
  factory _$DomainLibrarySectionCopyWith(_DomainLibrarySection value, $Res Function(_DomainLibrarySection) _then) = __$DomainLibrarySectionCopyWithImpl;
@override @useResult
$Res call({
 List<DomainExtensionMeta> extensions, List<String> pinnedPackages, String? query
});




}
/// @nodoc
class __$DomainLibrarySectionCopyWithImpl<$Res>
    implements _$DomainLibrarySectionCopyWith<$Res> {
  __$DomainLibrarySectionCopyWithImpl(this._self, this._then);

  final _DomainLibrarySection _self;
  final $Res Function(_DomainLibrarySection) _then;

/// Create a copy of DomainLibrarySection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? extensions = null,Object? pinnedPackages = null,Object? query = freezed,}) {
  return _then(_DomainLibrarySection(
extensions: null == extensions ? _self._extensions : extensions // ignore: cast_nullable_to_non_nullable
as List<DomainExtensionMeta>,pinnedPackages: null == pinnedPackages ? _self._pinnedPackages : pinnedPackages // ignore: cast_nullable_to_non_nullable
as List<String>,query: freezed == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
