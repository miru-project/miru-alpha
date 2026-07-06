// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DomainSearchFilter {

 String? get lang; String? get type; bool get installedOnly; bool get notInstalledOnly;
/// Create a copy of DomainSearchFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainSearchFilterCopyWith<DomainSearchFilter> get copyWith => _$DomainSearchFilterCopyWithImpl<DomainSearchFilter>(this as DomainSearchFilter, _$identity);

  /// Serializes this DomainSearchFilter to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainSearchFilter&&(identical(other.lang, lang) || other.lang == lang)&&(identical(other.type, type) || other.type == type)&&(identical(other.installedOnly, installedOnly) || other.installedOnly == installedOnly)&&(identical(other.notInstalledOnly, notInstalledOnly) || other.notInstalledOnly == notInstalledOnly));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,lang,type,installedOnly,notInstalledOnly);

@override
String toString() {
  return 'DomainSearchFilter(lang: $lang, type: $type, installedOnly: $installedOnly, notInstalledOnly: $notInstalledOnly)';
}


}

/// @nodoc
abstract mixin class $DomainSearchFilterCopyWith<$Res>  {
  factory $DomainSearchFilterCopyWith(DomainSearchFilter value, $Res Function(DomainSearchFilter) _then) = _$DomainSearchFilterCopyWithImpl;
@useResult
$Res call({
 String? lang, String? type, bool installedOnly, bool notInstalledOnly
});




}
/// @nodoc
class _$DomainSearchFilterCopyWithImpl<$Res>
    implements $DomainSearchFilterCopyWith<$Res> {
  _$DomainSearchFilterCopyWithImpl(this._self, this._then);

  final DomainSearchFilter _self;
  final $Res Function(DomainSearchFilter) _then;

/// Create a copy of DomainSearchFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lang = freezed,Object? type = freezed,Object? installedOnly = null,Object? notInstalledOnly = null,}) {
  return _then(_self.copyWith(
lang: freezed == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,installedOnly: null == installedOnly ? _self.installedOnly : installedOnly // ignore: cast_nullable_to_non_nullable
as bool,notInstalledOnly: null == notInstalledOnly ? _self.notInstalledOnly : notInstalledOnly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainSearchFilter].
extension DomainSearchFilterPatterns on DomainSearchFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainSearchFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainSearchFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainSearchFilter value)  $default,){
final _that = this;
switch (_that) {
case _DomainSearchFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainSearchFilter value)?  $default,){
final _that = this;
switch (_that) {
case _DomainSearchFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? lang,  String? type,  bool installedOnly,  bool notInstalledOnly)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainSearchFilter() when $default != null:
return $default(_that.lang,_that.type,_that.installedOnly,_that.notInstalledOnly);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? lang,  String? type,  bool installedOnly,  bool notInstalledOnly)  $default,) {final _that = this;
switch (_that) {
case _DomainSearchFilter():
return $default(_that.lang,_that.type,_that.installedOnly,_that.notInstalledOnly);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? lang,  String? type,  bool installedOnly,  bool notInstalledOnly)?  $default,) {final _that = this;
switch (_that) {
case _DomainSearchFilter() when $default != null:
return $default(_that.lang,_that.type,_that.installedOnly,_that.notInstalledOnly);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainSearchFilter implements DomainSearchFilter {
  const _DomainSearchFilter({this.lang, this.type, this.installedOnly = false, this.notInstalledOnly = false});
  factory _DomainSearchFilter.fromJson(Map<String, dynamic> json) => _$DomainSearchFilterFromJson(json);

@override final  String? lang;
@override final  String? type;
@override@JsonKey() final  bool installedOnly;
@override@JsonKey() final  bool notInstalledOnly;

/// Create a copy of DomainSearchFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainSearchFilterCopyWith<_DomainSearchFilter> get copyWith => __$DomainSearchFilterCopyWithImpl<_DomainSearchFilter>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainSearchFilterToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainSearchFilter&&(identical(other.lang, lang) || other.lang == lang)&&(identical(other.type, type) || other.type == type)&&(identical(other.installedOnly, installedOnly) || other.installedOnly == installedOnly)&&(identical(other.notInstalledOnly, notInstalledOnly) || other.notInstalledOnly == notInstalledOnly));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,lang,type,installedOnly,notInstalledOnly);

@override
String toString() {
  return 'DomainSearchFilter(lang: $lang, type: $type, installedOnly: $installedOnly, notInstalledOnly: $notInstalledOnly)';
}


}

/// @nodoc
abstract mixin class _$DomainSearchFilterCopyWith<$Res> implements $DomainSearchFilterCopyWith<$Res> {
  factory _$DomainSearchFilterCopyWith(_DomainSearchFilter value, $Res Function(_DomainSearchFilter) _then) = __$DomainSearchFilterCopyWithImpl;
@override @useResult
$Res call({
 String? lang, String? type, bool installedOnly, bool notInstalledOnly
});




}
/// @nodoc
class __$DomainSearchFilterCopyWithImpl<$Res>
    implements _$DomainSearchFilterCopyWith<$Res> {
  __$DomainSearchFilterCopyWithImpl(this._self, this._then);

  final _DomainSearchFilter _self;
  final $Res Function(_DomainSearchFilter) _then;

/// Create a copy of DomainSearchFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lang = freezed,Object? type = freezed,Object? installedOnly = null,Object? notInstalledOnly = null,}) {
  return _then(_DomainSearchFilter(
lang: freezed == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,installedOnly: null == installedOnly ? _self.installedOnly : installedOnly // ignore: cast_nullable_to_non_nullable
as bool,notInstalledOnly: null == notInstalledOnly ? _self.notInstalledOnly : notInstalledOnly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$DomainSearchState {

 List<dynamic> get extensions; String get query; String? get selectedLang; String? get selectedType; bool get isLoading; String? get error;
/// Create a copy of DomainSearchState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainSearchStateCopyWith<DomainSearchState> get copyWith => _$DomainSearchStateCopyWithImpl<DomainSearchState>(this as DomainSearchState, _$identity);

  /// Serializes this DomainSearchState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainSearchState&&const DeepCollectionEquality().equals(other.extensions, extensions)&&(identical(other.query, query) || other.query == query)&&(identical(other.selectedLang, selectedLang) || other.selectedLang == selectedLang)&&(identical(other.selectedType, selectedType) || other.selectedType == selectedType)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(extensions),query,selectedLang,selectedType,isLoading,error);

@override
String toString() {
  return 'DomainSearchState(extensions: $extensions, query: $query, selectedLang: $selectedLang, selectedType: $selectedType, isLoading: $isLoading, error: $error)';
}


}

/// @nodoc
abstract mixin class $DomainSearchStateCopyWith<$Res>  {
  factory $DomainSearchStateCopyWith(DomainSearchState value, $Res Function(DomainSearchState) _then) = _$DomainSearchStateCopyWithImpl;
@useResult
$Res call({
 List<dynamic> extensions, String query, String? selectedLang, String? selectedType, bool isLoading, String? error
});




}
/// @nodoc
class _$DomainSearchStateCopyWithImpl<$Res>
    implements $DomainSearchStateCopyWith<$Res> {
  _$DomainSearchStateCopyWithImpl(this._self, this._then);

  final DomainSearchState _self;
  final $Res Function(DomainSearchState) _then;

/// Create a copy of DomainSearchState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? extensions = null,Object? query = null,Object? selectedLang = freezed,Object? selectedType = freezed,Object? isLoading = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
extensions: null == extensions ? _self.extensions : extensions // ignore: cast_nullable_to_non_nullable
as List<dynamic>,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,selectedLang: freezed == selectedLang ? _self.selectedLang : selectedLang // ignore: cast_nullable_to_non_nullable
as String?,selectedType: freezed == selectedType ? _self.selectedType : selectedType // ignore: cast_nullable_to_non_nullable
as String?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainSearchState].
extension DomainSearchStatePatterns on DomainSearchState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainSearchState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainSearchState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainSearchState value)  $default,){
final _that = this;
switch (_that) {
case _DomainSearchState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainSearchState value)?  $default,){
final _that = this;
switch (_that) {
case _DomainSearchState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<dynamic> extensions,  String query,  String? selectedLang,  String? selectedType,  bool isLoading,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainSearchState() when $default != null:
return $default(_that.extensions,_that.query,_that.selectedLang,_that.selectedType,_that.isLoading,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<dynamic> extensions,  String query,  String? selectedLang,  String? selectedType,  bool isLoading,  String? error)  $default,) {final _that = this;
switch (_that) {
case _DomainSearchState():
return $default(_that.extensions,_that.query,_that.selectedLang,_that.selectedType,_that.isLoading,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<dynamic> extensions,  String query,  String? selectedLang,  String? selectedType,  bool isLoading,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _DomainSearchState() when $default != null:
return $default(_that.extensions,_that.query,_that.selectedLang,_that.selectedType,_that.isLoading,_that.error);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainSearchState implements DomainSearchState {
  const _DomainSearchState({required final  List<dynamic> extensions, required this.query, this.selectedLang, this.selectedType, this.isLoading = false, this.error}): _extensions = extensions;
  factory _DomainSearchState.fromJson(Map<String, dynamic> json) => _$DomainSearchStateFromJson(json);

 final  List<dynamic> _extensions;
@override List<dynamic> get extensions {
  if (_extensions is EqualUnmodifiableListView) return _extensions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_extensions);
}

@override final  String query;
@override final  String? selectedLang;
@override final  String? selectedType;
@override@JsonKey() final  bool isLoading;
@override final  String? error;

/// Create a copy of DomainSearchState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainSearchStateCopyWith<_DomainSearchState> get copyWith => __$DomainSearchStateCopyWithImpl<_DomainSearchState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainSearchStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainSearchState&&const DeepCollectionEquality().equals(other._extensions, _extensions)&&(identical(other.query, query) || other.query == query)&&(identical(other.selectedLang, selectedLang) || other.selectedLang == selectedLang)&&(identical(other.selectedType, selectedType) || other.selectedType == selectedType)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_extensions),query,selectedLang,selectedType,isLoading,error);

@override
String toString() {
  return 'DomainSearchState(extensions: $extensions, query: $query, selectedLang: $selectedLang, selectedType: $selectedType, isLoading: $isLoading, error: $error)';
}


}

/// @nodoc
abstract mixin class _$DomainSearchStateCopyWith<$Res> implements $DomainSearchStateCopyWith<$Res> {
  factory _$DomainSearchStateCopyWith(_DomainSearchState value, $Res Function(_DomainSearchState) _then) = __$DomainSearchStateCopyWithImpl;
@override @useResult
$Res call({
 List<dynamic> extensions, String query, String? selectedLang, String? selectedType, bool isLoading, String? error
});




}
/// @nodoc
class __$DomainSearchStateCopyWithImpl<$Res>
    implements _$DomainSearchStateCopyWith<$Res> {
  __$DomainSearchStateCopyWithImpl(this._self, this._then);

  final _DomainSearchState _self;
  final $Res Function(_DomainSearchState) _then;

/// Create a copy of DomainSearchState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? extensions = null,Object? query = null,Object? selectedLang = freezed,Object? selectedType = freezed,Object? isLoading = null,Object? error = freezed,}) {
  return _then(_DomainSearchState(
extensions: null == extensions ? _self._extensions : extensions // ignore: cast_nullable_to_non_nullable
as List<dynamic>,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,selectedLang: freezed == selectedLang ? _self.selectedLang : selectedLang // ignore: cast_nullable_to_non_nullable
as String?,selectedType: freezed == selectedType ? _self.selectedType : selectedType // ignore: cast_nullable_to_non_nullable
as String?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
