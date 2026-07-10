// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'extension_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DomainExtensionViewState {

 List<DomainExtensionRepo> get repos; List<DomainExtensionRepo> get extensions; List<String> get installedPackages; List<DomainExtensionMeta> get metadata; String get selectedRepoName; String get query; ExtensionType get typeFilter; ExtensionInstallStatus get installFilter; bool get isLoading;
/// Create a copy of DomainExtensionViewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainExtensionViewStateCopyWith<DomainExtensionViewState> get copyWith => _$DomainExtensionViewStateCopyWithImpl<DomainExtensionViewState>(this as DomainExtensionViewState, _$identity);

  /// Serializes this DomainExtensionViewState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainExtensionViewState&&const DeepCollectionEquality().equals(other.repos, repos)&&const DeepCollectionEquality().equals(other.extensions, extensions)&&const DeepCollectionEquality().equals(other.installedPackages, installedPackages)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.selectedRepoName, selectedRepoName) || other.selectedRepoName == selectedRepoName)&&(identical(other.query, query) || other.query == query)&&(identical(other.typeFilter, typeFilter) || other.typeFilter == typeFilter)&&(identical(other.installFilter, installFilter) || other.installFilter == installFilter)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(repos),const DeepCollectionEquality().hash(extensions),const DeepCollectionEquality().hash(installedPackages),const DeepCollectionEquality().hash(metadata),selectedRepoName,query,typeFilter,installFilter,isLoading);

@override
String toString() {
  return 'DomainExtensionViewState(repos: $repos, extensions: $extensions, installedPackages: $installedPackages, metadata: $metadata, selectedRepoName: $selectedRepoName, query: $query, typeFilter: $typeFilter, installFilter: $installFilter, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class $DomainExtensionViewStateCopyWith<$Res>  {
  factory $DomainExtensionViewStateCopyWith(DomainExtensionViewState value, $Res Function(DomainExtensionViewState) _then) = _$DomainExtensionViewStateCopyWithImpl;
@useResult
$Res call({
 List<DomainExtensionRepo> repos, List<DomainExtensionRepo> extensions, List<String> installedPackages, List<DomainExtensionMeta> metadata, String selectedRepoName, String query, ExtensionType typeFilter, ExtensionInstallStatus installFilter, bool isLoading
});




}
/// @nodoc
class _$DomainExtensionViewStateCopyWithImpl<$Res>
    implements $DomainExtensionViewStateCopyWith<$Res> {
  _$DomainExtensionViewStateCopyWithImpl(this._self, this._then);

  final DomainExtensionViewState _self;
  final $Res Function(DomainExtensionViewState) _then;

/// Create a copy of DomainExtensionViewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? repos = null,Object? extensions = null,Object? installedPackages = null,Object? metadata = null,Object? selectedRepoName = null,Object? query = null,Object? typeFilter = null,Object? installFilter = null,Object? isLoading = null,}) {
  return _then(_self.copyWith(
repos: null == repos ? _self.repos : repos // ignore: cast_nullable_to_non_nullable
as List<DomainExtensionRepo>,extensions: null == extensions ? _self.extensions : extensions // ignore: cast_nullable_to_non_nullable
as List<DomainExtensionRepo>,installedPackages: null == installedPackages ? _self.installedPackages : installedPackages // ignore: cast_nullable_to_non_nullable
as List<String>,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as List<DomainExtensionMeta>,selectedRepoName: null == selectedRepoName ? _self.selectedRepoName : selectedRepoName // ignore: cast_nullable_to_non_nullable
as String,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,typeFilter: null == typeFilter ? _self.typeFilter : typeFilter // ignore: cast_nullable_to_non_nullable
as ExtensionType,installFilter: null == installFilter ? _self.installFilter : installFilter // ignore: cast_nullable_to_non_nullable
as ExtensionInstallStatus,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainExtensionViewState].
extension DomainExtensionViewStatePatterns on DomainExtensionViewState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainExtensionViewState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainExtensionViewState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainExtensionViewState value)  $default,){
final _that = this;
switch (_that) {
case _DomainExtensionViewState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainExtensionViewState value)?  $default,){
final _that = this;
switch (_that) {
case _DomainExtensionViewState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<DomainExtensionRepo> repos,  List<DomainExtensionRepo> extensions,  List<String> installedPackages,  List<DomainExtensionMeta> metadata,  String selectedRepoName,  String query,  ExtensionType typeFilter,  ExtensionInstallStatus installFilter,  bool isLoading)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainExtensionViewState() when $default != null:
return $default(_that.repos,_that.extensions,_that.installedPackages,_that.metadata,_that.selectedRepoName,_that.query,_that.typeFilter,_that.installFilter,_that.isLoading);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<DomainExtensionRepo> repos,  List<DomainExtensionRepo> extensions,  List<String> installedPackages,  List<DomainExtensionMeta> metadata,  String selectedRepoName,  String query,  ExtensionType typeFilter,  ExtensionInstallStatus installFilter,  bool isLoading)  $default,) {final _that = this;
switch (_that) {
case _DomainExtensionViewState():
return $default(_that.repos,_that.extensions,_that.installedPackages,_that.metadata,_that.selectedRepoName,_that.query,_that.typeFilter,_that.installFilter,_that.isLoading);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<DomainExtensionRepo> repos,  List<DomainExtensionRepo> extensions,  List<String> installedPackages,  List<DomainExtensionMeta> metadata,  String selectedRepoName,  String query,  ExtensionType typeFilter,  ExtensionInstallStatus installFilter,  bool isLoading)?  $default,) {final _that = this;
switch (_that) {
case _DomainExtensionViewState() when $default != null:
return $default(_that.repos,_that.extensions,_that.installedPackages,_that.metadata,_that.selectedRepoName,_that.query,_that.typeFilter,_that.installFilter,_that.isLoading);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainExtensionViewState implements DomainExtensionViewState {
  const _DomainExtensionViewState({final  List<DomainExtensionRepo> repos = const [], final  List<DomainExtensionRepo> extensions = const [], final  List<String> installedPackages = const [], final  List<DomainExtensionMeta> metadata = const [], this.selectedRepoName = '', this.query = '', this.typeFilter = ExtensionType.all, this.installFilter = ExtensionInstallStatus.all, this.isLoading = false}): _repos = repos,_extensions = extensions,_installedPackages = installedPackages,_metadata = metadata;
  factory _DomainExtensionViewState.fromJson(Map<String, dynamic> json) => _$DomainExtensionViewStateFromJson(json);

 final  List<DomainExtensionRepo> _repos;
@override@JsonKey() List<DomainExtensionRepo> get repos {
  if (_repos is EqualUnmodifiableListView) return _repos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_repos);
}

 final  List<DomainExtensionRepo> _extensions;
@override@JsonKey() List<DomainExtensionRepo> get extensions {
  if (_extensions is EqualUnmodifiableListView) return _extensions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_extensions);
}

 final  List<String> _installedPackages;
@override@JsonKey() List<String> get installedPackages {
  if (_installedPackages is EqualUnmodifiableListView) return _installedPackages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_installedPackages);
}

 final  List<DomainExtensionMeta> _metadata;
@override@JsonKey() List<DomainExtensionMeta> get metadata {
  if (_metadata is EqualUnmodifiableListView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_metadata);
}

@override@JsonKey() final  String selectedRepoName;
@override@JsonKey() final  String query;
@override@JsonKey() final  ExtensionType typeFilter;
@override@JsonKey() final  ExtensionInstallStatus installFilter;
@override@JsonKey() final  bool isLoading;

/// Create a copy of DomainExtensionViewState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainExtensionViewStateCopyWith<_DomainExtensionViewState> get copyWith => __$DomainExtensionViewStateCopyWithImpl<_DomainExtensionViewState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainExtensionViewStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainExtensionViewState&&const DeepCollectionEquality().equals(other._repos, _repos)&&const DeepCollectionEquality().equals(other._extensions, _extensions)&&const DeepCollectionEquality().equals(other._installedPackages, _installedPackages)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.selectedRepoName, selectedRepoName) || other.selectedRepoName == selectedRepoName)&&(identical(other.query, query) || other.query == query)&&(identical(other.typeFilter, typeFilter) || other.typeFilter == typeFilter)&&(identical(other.installFilter, installFilter) || other.installFilter == installFilter)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_repos),const DeepCollectionEquality().hash(_extensions),const DeepCollectionEquality().hash(_installedPackages),const DeepCollectionEquality().hash(_metadata),selectedRepoName,query,typeFilter,installFilter,isLoading);

@override
String toString() {
  return 'DomainExtensionViewState(repos: $repos, extensions: $extensions, installedPackages: $installedPackages, metadata: $metadata, selectedRepoName: $selectedRepoName, query: $query, typeFilter: $typeFilter, installFilter: $installFilter, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class _$DomainExtensionViewStateCopyWith<$Res> implements $DomainExtensionViewStateCopyWith<$Res> {
  factory _$DomainExtensionViewStateCopyWith(_DomainExtensionViewState value, $Res Function(_DomainExtensionViewState) _then) = __$DomainExtensionViewStateCopyWithImpl;
@override @useResult
$Res call({
 List<DomainExtensionRepo> repos, List<DomainExtensionRepo> extensions, List<String> installedPackages, List<DomainExtensionMeta> metadata, String selectedRepoName, String query, ExtensionType typeFilter, ExtensionInstallStatus installFilter, bool isLoading
});




}
/// @nodoc
class __$DomainExtensionViewStateCopyWithImpl<$Res>
    implements _$DomainExtensionViewStateCopyWith<$Res> {
  __$DomainExtensionViewStateCopyWithImpl(this._self, this._then);

  final _DomainExtensionViewState _self;
  final $Res Function(_DomainExtensionViewState) _then;

/// Create a copy of DomainExtensionViewState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? repos = null,Object? extensions = null,Object? installedPackages = null,Object? metadata = null,Object? selectedRepoName = null,Object? query = null,Object? typeFilter = null,Object? installFilter = null,Object? isLoading = null,}) {
  return _then(_DomainExtensionViewState(
repos: null == repos ? _self._repos : repos // ignore: cast_nullable_to_non_nullable
as List<DomainExtensionRepo>,extensions: null == extensions ? _self._extensions : extensions // ignore: cast_nullable_to_non_nullable
as List<DomainExtensionRepo>,installedPackages: null == installedPackages ? _self._installedPackages : installedPackages // ignore: cast_nullable_to_non_nullable
as List<String>,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as List<DomainExtensionMeta>,selectedRepoName: null == selectedRepoName ? _self.selectedRepoName : selectedRepoName // ignore: cast_nullable_to_non_nullable
as String,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,typeFilter: null == typeFilter ? _self.typeFilter : typeFilter // ignore: cast_nullable_to_non_nullable
as ExtensionType,installFilter: null == installFilter ? _self.installFilter : installFilter // ignore: cast_nullable_to_non_nullable
as ExtensionInstallStatus,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
