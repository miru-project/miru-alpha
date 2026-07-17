// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DomainAppSettings {

 String get theme; String get baseColor; int get accentColor; String get language; bool get isMobileTitleOnTop; String get tmdbApiKey; String get proxy; String get proxyPort; bool get enableProxy; bool get hardwareAcceleration; double get subtitleFontSize; String get subtitleColor; double get playbackSpeed; bool get autoPlayNext; MangaReadMode get mangaReadMode; NovelReadMode get novelReadMode; double get novelFontSize; String get novelTheme; bool get enableTTS; bool get devMode; bool get enableDevLog; bool get enableDevNetwork; String get anilistToken; bool get autoSyncTracking; int get downloadConcurrent; String get downloadPath; bool get autoDownload; bool get showContinueWatching; bool get showHistory; bool get showFavorites;
/// Create a copy of DomainAppSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainAppSettingsCopyWith<DomainAppSettings> get copyWith => _$DomainAppSettingsCopyWithImpl<DomainAppSettings>(this as DomainAppSettings, _$identity);

  /// Serializes this DomainAppSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainAppSettings&&(identical(other.theme, theme) || other.theme == theme)&&(identical(other.baseColor, baseColor) || other.baseColor == baseColor)&&(identical(other.accentColor, accentColor) || other.accentColor == accentColor)&&(identical(other.language, language) || other.language == language)&&(identical(other.isMobileTitleOnTop, isMobileTitleOnTop) || other.isMobileTitleOnTop == isMobileTitleOnTop)&&(identical(other.tmdbApiKey, tmdbApiKey) || other.tmdbApiKey == tmdbApiKey)&&(identical(other.proxy, proxy) || other.proxy == proxy)&&(identical(other.proxyPort, proxyPort) || other.proxyPort == proxyPort)&&(identical(other.enableProxy, enableProxy) || other.enableProxy == enableProxy)&&(identical(other.hardwareAcceleration, hardwareAcceleration) || other.hardwareAcceleration == hardwareAcceleration)&&(identical(other.subtitleFontSize, subtitleFontSize) || other.subtitleFontSize == subtitleFontSize)&&(identical(other.subtitleColor, subtitleColor) || other.subtitleColor == subtitleColor)&&(identical(other.playbackSpeed, playbackSpeed) || other.playbackSpeed == playbackSpeed)&&(identical(other.autoPlayNext, autoPlayNext) || other.autoPlayNext == autoPlayNext)&&(identical(other.mangaReadMode, mangaReadMode) || other.mangaReadMode == mangaReadMode)&&(identical(other.novelReadMode, novelReadMode) || other.novelReadMode == novelReadMode)&&(identical(other.novelFontSize, novelFontSize) || other.novelFontSize == novelFontSize)&&(identical(other.novelTheme, novelTheme) || other.novelTheme == novelTheme)&&(identical(other.enableTTS, enableTTS) || other.enableTTS == enableTTS)&&(identical(other.devMode, devMode) || other.devMode == devMode)&&(identical(other.enableDevLog, enableDevLog) || other.enableDevLog == enableDevLog)&&(identical(other.enableDevNetwork, enableDevNetwork) || other.enableDevNetwork == enableDevNetwork)&&(identical(other.anilistToken, anilistToken) || other.anilistToken == anilistToken)&&(identical(other.autoSyncTracking, autoSyncTracking) || other.autoSyncTracking == autoSyncTracking)&&(identical(other.downloadConcurrent, downloadConcurrent) || other.downloadConcurrent == downloadConcurrent)&&(identical(other.downloadPath, downloadPath) || other.downloadPath == downloadPath)&&(identical(other.autoDownload, autoDownload) || other.autoDownload == autoDownload)&&(identical(other.showContinueWatching, showContinueWatching) || other.showContinueWatching == showContinueWatching)&&(identical(other.showHistory, showHistory) || other.showHistory == showHistory)&&(identical(other.showFavorites, showFavorites) || other.showFavorites == showFavorites));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,theme,baseColor,accentColor,language,isMobileTitleOnTop,tmdbApiKey,proxy,proxyPort,enableProxy,hardwareAcceleration,subtitleFontSize,subtitleColor,playbackSpeed,autoPlayNext,mangaReadMode,novelReadMode,novelFontSize,novelTheme,enableTTS,devMode,enableDevLog,enableDevNetwork,anilistToken,autoSyncTracking,downloadConcurrent,downloadPath,autoDownload,showContinueWatching,showHistory,showFavorites]);

@override
String toString() {
  return 'DomainAppSettings(theme: $theme, baseColor: $baseColor, accentColor: $accentColor, language: $language, isMobileTitleOnTop: $isMobileTitleOnTop, tmdbApiKey: $tmdbApiKey, proxy: $proxy, proxyPort: $proxyPort, enableProxy: $enableProxy, hardwareAcceleration: $hardwareAcceleration, subtitleFontSize: $subtitleFontSize, subtitleColor: $subtitleColor, playbackSpeed: $playbackSpeed, autoPlayNext: $autoPlayNext, mangaReadMode: $mangaReadMode, novelReadMode: $novelReadMode, novelFontSize: $novelFontSize, novelTheme: $novelTheme, enableTTS: $enableTTS, devMode: $devMode, enableDevLog: $enableDevLog, enableDevNetwork: $enableDevNetwork, anilistToken: $anilistToken, autoSyncTracking: $autoSyncTracking, downloadConcurrent: $downloadConcurrent, downloadPath: $downloadPath, autoDownload: $autoDownload, showContinueWatching: $showContinueWatching, showHistory: $showHistory, showFavorites: $showFavorites)';
}


}

/// @nodoc
abstract mixin class $DomainAppSettingsCopyWith<$Res>  {
  factory $DomainAppSettingsCopyWith(DomainAppSettings value, $Res Function(DomainAppSettings) _then) = _$DomainAppSettingsCopyWithImpl;
@useResult
$Res call({
 String theme, String baseColor, int accentColor, String language, bool isMobileTitleOnTop, String tmdbApiKey, String proxy, String proxyPort, bool enableProxy, bool hardwareAcceleration, double subtitleFontSize, String subtitleColor, double playbackSpeed, bool autoPlayNext, MangaReadMode mangaReadMode, NovelReadMode novelReadMode, double novelFontSize, String novelTheme, bool enableTTS, bool devMode, bool enableDevLog, bool enableDevNetwork, String anilistToken, bool autoSyncTracking, int downloadConcurrent, String downloadPath, bool autoDownload, bool showContinueWatching, bool showHistory, bool showFavorites
});




}
/// @nodoc
class _$DomainAppSettingsCopyWithImpl<$Res>
    implements $DomainAppSettingsCopyWith<$Res> {
  _$DomainAppSettingsCopyWithImpl(this._self, this._then);

  final DomainAppSettings _self;
  final $Res Function(DomainAppSettings) _then;

/// Create a copy of DomainAppSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? theme = null,Object? baseColor = null,Object? accentColor = null,Object? language = null,Object? isMobileTitleOnTop = null,Object? tmdbApiKey = null,Object? proxy = null,Object? proxyPort = null,Object? enableProxy = null,Object? hardwareAcceleration = null,Object? subtitleFontSize = null,Object? subtitleColor = null,Object? playbackSpeed = null,Object? autoPlayNext = null,Object? mangaReadMode = null,Object? novelReadMode = null,Object? novelFontSize = null,Object? novelTheme = null,Object? enableTTS = null,Object? devMode = null,Object? enableDevLog = null,Object? enableDevNetwork = null,Object? anilistToken = null,Object? autoSyncTracking = null,Object? downloadConcurrent = null,Object? downloadPath = null,Object? autoDownload = null,Object? showContinueWatching = null,Object? showHistory = null,Object? showFavorites = null,}) {
  return _then(_self.copyWith(
theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as String,baseColor: null == baseColor ? _self.baseColor : baseColor // ignore: cast_nullable_to_non_nullable
as String,accentColor: null == accentColor ? _self.accentColor : accentColor // ignore: cast_nullable_to_non_nullable
as int,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,isMobileTitleOnTop: null == isMobileTitleOnTop ? _self.isMobileTitleOnTop : isMobileTitleOnTop // ignore: cast_nullable_to_non_nullable
as bool,tmdbApiKey: null == tmdbApiKey ? _self.tmdbApiKey : tmdbApiKey // ignore: cast_nullable_to_non_nullable
as String,proxy: null == proxy ? _self.proxy : proxy // ignore: cast_nullable_to_non_nullable
as String,proxyPort: null == proxyPort ? _self.proxyPort : proxyPort // ignore: cast_nullable_to_non_nullable
as String,enableProxy: null == enableProxy ? _self.enableProxy : enableProxy // ignore: cast_nullable_to_non_nullable
as bool,hardwareAcceleration: null == hardwareAcceleration ? _self.hardwareAcceleration : hardwareAcceleration // ignore: cast_nullable_to_non_nullable
as bool,subtitleFontSize: null == subtitleFontSize ? _self.subtitleFontSize : subtitleFontSize // ignore: cast_nullable_to_non_nullable
as double,subtitleColor: null == subtitleColor ? _self.subtitleColor : subtitleColor // ignore: cast_nullable_to_non_nullable
as String,playbackSpeed: null == playbackSpeed ? _self.playbackSpeed : playbackSpeed // ignore: cast_nullable_to_non_nullable
as double,autoPlayNext: null == autoPlayNext ? _self.autoPlayNext : autoPlayNext // ignore: cast_nullable_to_non_nullable
as bool,mangaReadMode: null == mangaReadMode ? _self.mangaReadMode : mangaReadMode // ignore: cast_nullable_to_non_nullable
as MangaReadMode,novelReadMode: null == novelReadMode ? _self.novelReadMode : novelReadMode // ignore: cast_nullable_to_non_nullable
as NovelReadMode,novelFontSize: null == novelFontSize ? _self.novelFontSize : novelFontSize // ignore: cast_nullable_to_non_nullable
as double,novelTheme: null == novelTheme ? _self.novelTheme : novelTheme // ignore: cast_nullable_to_non_nullable
as String,enableTTS: null == enableTTS ? _self.enableTTS : enableTTS // ignore: cast_nullable_to_non_nullable
as bool,devMode: null == devMode ? _self.devMode : devMode // ignore: cast_nullable_to_non_nullable
as bool,enableDevLog: null == enableDevLog ? _self.enableDevLog : enableDevLog // ignore: cast_nullable_to_non_nullable
as bool,enableDevNetwork: null == enableDevNetwork ? _self.enableDevNetwork : enableDevNetwork // ignore: cast_nullable_to_non_nullable
as bool,anilistToken: null == anilistToken ? _self.anilistToken : anilistToken // ignore: cast_nullable_to_non_nullable
as String,autoSyncTracking: null == autoSyncTracking ? _self.autoSyncTracking : autoSyncTracking // ignore: cast_nullable_to_non_nullable
as bool,downloadConcurrent: null == downloadConcurrent ? _self.downloadConcurrent : downloadConcurrent // ignore: cast_nullable_to_non_nullable
as int,downloadPath: null == downloadPath ? _self.downloadPath : downloadPath // ignore: cast_nullable_to_non_nullable
as String,autoDownload: null == autoDownload ? _self.autoDownload : autoDownload // ignore: cast_nullable_to_non_nullable
as bool,showContinueWatching: null == showContinueWatching ? _self.showContinueWatching : showContinueWatching // ignore: cast_nullable_to_non_nullable
as bool,showHistory: null == showHistory ? _self.showHistory : showHistory // ignore: cast_nullable_to_non_nullable
as bool,showFavorites: null == showFavorites ? _self.showFavorites : showFavorites // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainAppSettings].
extension DomainAppSettingsPatterns on DomainAppSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainAppSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainAppSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainAppSettings value)  $default,){
final _that = this;
switch (_that) {
case _DomainAppSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainAppSettings value)?  $default,){
final _that = this;
switch (_that) {
case _DomainAppSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String theme,  String baseColor,  int accentColor,  String language,  bool isMobileTitleOnTop,  String tmdbApiKey,  String proxy,  String proxyPort,  bool enableProxy,  bool hardwareAcceleration,  double subtitleFontSize,  String subtitleColor,  double playbackSpeed,  bool autoPlayNext,  MangaReadMode mangaReadMode,  NovelReadMode novelReadMode,  double novelFontSize,  String novelTheme,  bool enableTTS,  bool devMode,  bool enableDevLog,  bool enableDevNetwork,  String anilistToken,  bool autoSyncTracking,  int downloadConcurrent,  String downloadPath,  bool autoDownload,  bool showContinueWatching,  bool showHistory,  bool showFavorites)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainAppSettings() when $default != null:
return $default(_that.theme,_that.baseColor,_that.accentColor,_that.language,_that.isMobileTitleOnTop,_that.tmdbApiKey,_that.proxy,_that.proxyPort,_that.enableProxy,_that.hardwareAcceleration,_that.subtitleFontSize,_that.subtitleColor,_that.playbackSpeed,_that.autoPlayNext,_that.mangaReadMode,_that.novelReadMode,_that.novelFontSize,_that.novelTheme,_that.enableTTS,_that.devMode,_that.enableDevLog,_that.enableDevNetwork,_that.anilistToken,_that.autoSyncTracking,_that.downloadConcurrent,_that.downloadPath,_that.autoDownload,_that.showContinueWatching,_that.showHistory,_that.showFavorites);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String theme,  String baseColor,  int accentColor,  String language,  bool isMobileTitleOnTop,  String tmdbApiKey,  String proxy,  String proxyPort,  bool enableProxy,  bool hardwareAcceleration,  double subtitleFontSize,  String subtitleColor,  double playbackSpeed,  bool autoPlayNext,  MangaReadMode mangaReadMode,  NovelReadMode novelReadMode,  double novelFontSize,  String novelTheme,  bool enableTTS,  bool devMode,  bool enableDevLog,  bool enableDevNetwork,  String anilistToken,  bool autoSyncTracking,  int downloadConcurrent,  String downloadPath,  bool autoDownload,  bool showContinueWatching,  bool showHistory,  bool showFavorites)  $default,) {final _that = this;
switch (_that) {
case _DomainAppSettings():
return $default(_that.theme,_that.baseColor,_that.accentColor,_that.language,_that.isMobileTitleOnTop,_that.tmdbApiKey,_that.proxy,_that.proxyPort,_that.enableProxy,_that.hardwareAcceleration,_that.subtitleFontSize,_that.subtitleColor,_that.playbackSpeed,_that.autoPlayNext,_that.mangaReadMode,_that.novelReadMode,_that.novelFontSize,_that.novelTheme,_that.enableTTS,_that.devMode,_that.enableDevLog,_that.enableDevNetwork,_that.anilistToken,_that.autoSyncTracking,_that.downloadConcurrent,_that.downloadPath,_that.autoDownload,_that.showContinueWatching,_that.showHistory,_that.showFavorites);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String theme,  String baseColor,  int accentColor,  String language,  bool isMobileTitleOnTop,  String tmdbApiKey,  String proxy,  String proxyPort,  bool enableProxy,  bool hardwareAcceleration,  double subtitleFontSize,  String subtitleColor,  double playbackSpeed,  bool autoPlayNext,  MangaReadMode mangaReadMode,  NovelReadMode novelReadMode,  double novelFontSize,  String novelTheme,  bool enableTTS,  bool devMode,  bool enableDevLog,  bool enableDevNetwork,  String anilistToken,  bool autoSyncTracking,  int downloadConcurrent,  String downloadPath,  bool autoDownload,  bool showContinueWatching,  bool showHistory,  bool showFavorites)?  $default,) {final _that = this;
switch (_that) {
case _DomainAppSettings() when $default != null:
return $default(_that.theme,_that.baseColor,_that.accentColor,_that.language,_that.isMobileTitleOnTop,_that.tmdbApiKey,_that.proxy,_that.proxyPort,_that.enableProxy,_that.hardwareAcceleration,_that.subtitleFontSize,_that.subtitleColor,_that.playbackSpeed,_that.autoPlayNext,_that.mangaReadMode,_that.novelReadMode,_that.novelFontSize,_that.novelTheme,_that.enableTTS,_that.devMode,_that.enableDevLog,_that.enableDevNetwork,_that.anilistToken,_that.autoSyncTracking,_that.downloadConcurrent,_that.downloadPath,_that.autoDownload,_that.showContinueWatching,_that.showHistory,_that.showFavorites);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainAppSettings implements DomainAppSettings {
  const _DomainAppSettings({this.theme = 'system', this.baseColor = 'zinc', this.accentColor = 0xFF2196F3, this.language = 'en', this.isMobileTitleOnTop = false, this.tmdbApiKey = '', this.proxy = '', this.proxyPort = '', this.enableProxy = false, this.hardwareAcceleration = true, this.subtitleFontSize = 16, this.subtitleColor = '', this.playbackSpeed = 1.0, this.autoPlayNext = true, this.mangaReadMode = MangaReadMode.standard, this.novelReadMode = NovelReadMode.standard, this.novelFontSize = 16, this.novelTheme = '', this.enableTTS = true, this.devMode = false, this.enableDevLog = false, this.enableDevNetwork = false, this.anilistToken = '', this.autoSyncTracking = true, this.downloadConcurrent = 3, this.downloadPath = '', this.autoDownload = true, this.showContinueWatching = true, this.showHistory = true, this.showFavorites = true});
  factory _DomainAppSettings.fromJson(Map<String, dynamic> json) => _$DomainAppSettingsFromJson(json);

@override@JsonKey() final  String theme;
@override@JsonKey() final  String baseColor;
@override@JsonKey() final  int accentColor;
@override@JsonKey() final  String language;
@override@JsonKey() final  bool isMobileTitleOnTop;
@override@JsonKey() final  String tmdbApiKey;
@override@JsonKey() final  String proxy;
@override@JsonKey() final  String proxyPort;
@override@JsonKey() final  bool enableProxy;
@override@JsonKey() final  bool hardwareAcceleration;
@override@JsonKey() final  double subtitleFontSize;
@override@JsonKey() final  String subtitleColor;
@override@JsonKey() final  double playbackSpeed;
@override@JsonKey() final  bool autoPlayNext;
@override@JsonKey() final  MangaReadMode mangaReadMode;
@override@JsonKey() final  NovelReadMode novelReadMode;
@override@JsonKey() final  double novelFontSize;
@override@JsonKey() final  String novelTheme;
@override@JsonKey() final  bool enableTTS;
@override@JsonKey() final  bool devMode;
@override@JsonKey() final  bool enableDevLog;
@override@JsonKey() final  bool enableDevNetwork;
@override@JsonKey() final  String anilistToken;
@override@JsonKey() final  bool autoSyncTracking;
@override@JsonKey() final  int downloadConcurrent;
@override@JsonKey() final  String downloadPath;
@override@JsonKey() final  bool autoDownload;
@override@JsonKey() final  bool showContinueWatching;
@override@JsonKey() final  bool showHistory;
@override@JsonKey() final  bool showFavorites;

/// Create a copy of DomainAppSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainAppSettingsCopyWith<_DomainAppSettings> get copyWith => __$DomainAppSettingsCopyWithImpl<_DomainAppSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainAppSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainAppSettings&&(identical(other.theme, theme) || other.theme == theme)&&(identical(other.baseColor, baseColor) || other.baseColor == baseColor)&&(identical(other.accentColor, accentColor) || other.accentColor == accentColor)&&(identical(other.language, language) || other.language == language)&&(identical(other.isMobileTitleOnTop, isMobileTitleOnTop) || other.isMobileTitleOnTop == isMobileTitleOnTop)&&(identical(other.tmdbApiKey, tmdbApiKey) || other.tmdbApiKey == tmdbApiKey)&&(identical(other.proxy, proxy) || other.proxy == proxy)&&(identical(other.proxyPort, proxyPort) || other.proxyPort == proxyPort)&&(identical(other.enableProxy, enableProxy) || other.enableProxy == enableProxy)&&(identical(other.hardwareAcceleration, hardwareAcceleration) || other.hardwareAcceleration == hardwareAcceleration)&&(identical(other.subtitleFontSize, subtitleFontSize) || other.subtitleFontSize == subtitleFontSize)&&(identical(other.subtitleColor, subtitleColor) || other.subtitleColor == subtitleColor)&&(identical(other.playbackSpeed, playbackSpeed) || other.playbackSpeed == playbackSpeed)&&(identical(other.autoPlayNext, autoPlayNext) || other.autoPlayNext == autoPlayNext)&&(identical(other.mangaReadMode, mangaReadMode) || other.mangaReadMode == mangaReadMode)&&(identical(other.novelReadMode, novelReadMode) || other.novelReadMode == novelReadMode)&&(identical(other.novelFontSize, novelFontSize) || other.novelFontSize == novelFontSize)&&(identical(other.novelTheme, novelTheme) || other.novelTheme == novelTheme)&&(identical(other.enableTTS, enableTTS) || other.enableTTS == enableTTS)&&(identical(other.devMode, devMode) || other.devMode == devMode)&&(identical(other.enableDevLog, enableDevLog) || other.enableDevLog == enableDevLog)&&(identical(other.enableDevNetwork, enableDevNetwork) || other.enableDevNetwork == enableDevNetwork)&&(identical(other.anilistToken, anilistToken) || other.anilistToken == anilistToken)&&(identical(other.autoSyncTracking, autoSyncTracking) || other.autoSyncTracking == autoSyncTracking)&&(identical(other.downloadConcurrent, downloadConcurrent) || other.downloadConcurrent == downloadConcurrent)&&(identical(other.downloadPath, downloadPath) || other.downloadPath == downloadPath)&&(identical(other.autoDownload, autoDownload) || other.autoDownload == autoDownload)&&(identical(other.showContinueWatching, showContinueWatching) || other.showContinueWatching == showContinueWatching)&&(identical(other.showHistory, showHistory) || other.showHistory == showHistory)&&(identical(other.showFavorites, showFavorites) || other.showFavorites == showFavorites));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,theme,baseColor,accentColor,language,isMobileTitleOnTop,tmdbApiKey,proxy,proxyPort,enableProxy,hardwareAcceleration,subtitleFontSize,subtitleColor,playbackSpeed,autoPlayNext,mangaReadMode,novelReadMode,novelFontSize,novelTheme,enableTTS,devMode,enableDevLog,enableDevNetwork,anilistToken,autoSyncTracking,downloadConcurrent,downloadPath,autoDownload,showContinueWatching,showHistory,showFavorites]);

@override
String toString() {
  return 'DomainAppSettings(theme: $theme, baseColor: $baseColor, accentColor: $accentColor, language: $language, isMobileTitleOnTop: $isMobileTitleOnTop, tmdbApiKey: $tmdbApiKey, proxy: $proxy, proxyPort: $proxyPort, enableProxy: $enableProxy, hardwareAcceleration: $hardwareAcceleration, subtitleFontSize: $subtitleFontSize, subtitleColor: $subtitleColor, playbackSpeed: $playbackSpeed, autoPlayNext: $autoPlayNext, mangaReadMode: $mangaReadMode, novelReadMode: $novelReadMode, novelFontSize: $novelFontSize, novelTheme: $novelTheme, enableTTS: $enableTTS, devMode: $devMode, enableDevLog: $enableDevLog, enableDevNetwork: $enableDevNetwork, anilistToken: $anilistToken, autoSyncTracking: $autoSyncTracking, downloadConcurrent: $downloadConcurrent, downloadPath: $downloadPath, autoDownload: $autoDownload, showContinueWatching: $showContinueWatching, showHistory: $showHistory, showFavorites: $showFavorites)';
}


}

/// @nodoc
abstract mixin class _$DomainAppSettingsCopyWith<$Res> implements $DomainAppSettingsCopyWith<$Res> {
  factory _$DomainAppSettingsCopyWith(_DomainAppSettings value, $Res Function(_DomainAppSettings) _then) = __$DomainAppSettingsCopyWithImpl;
@override @useResult
$Res call({
 String theme, String baseColor, int accentColor, String language, bool isMobileTitleOnTop, String tmdbApiKey, String proxy, String proxyPort, bool enableProxy, bool hardwareAcceleration, double subtitleFontSize, String subtitleColor, double playbackSpeed, bool autoPlayNext, MangaReadMode mangaReadMode, NovelReadMode novelReadMode, double novelFontSize, String novelTheme, bool enableTTS, bool devMode, bool enableDevLog, bool enableDevNetwork, String anilistToken, bool autoSyncTracking, int downloadConcurrent, String downloadPath, bool autoDownload, bool showContinueWatching, bool showHistory, bool showFavorites
});




}
/// @nodoc
class __$DomainAppSettingsCopyWithImpl<$Res>
    implements _$DomainAppSettingsCopyWith<$Res> {
  __$DomainAppSettingsCopyWithImpl(this._self, this._then);

  final _DomainAppSettings _self;
  final $Res Function(_DomainAppSettings) _then;

/// Create a copy of DomainAppSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? theme = null,Object? baseColor = null,Object? accentColor = null,Object? language = null,Object? isMobileTitleOnTop = null,Object? tmdbApiKey = null,Object? proxy = null,Object? proxyPort = null,Object? enableProxy = null,Object? hardwareAcceleration = null,Object? subtitleFontSize = null,Object? subtitleColor = null,Object? playbackSpeed = null,Object? autoPlayNext = null,Object? mangaReadMode = null,Object? novelReadMode = null,Object? novelFontSize = null,Object? novelTheme = null,Object? enableTTS = null,Object? devMode = null,Object? enableDevLog = null,Object? enableDevNetwork = null,Object? anilistToken = null,Object? autoSyncTracking = null,Object? downloadConcurrent = null,Object? downloadPath = null,Object? autoDownload = null,Object? showContinueWatching = null,Object? showHistory = null,Object? showFavorites = null,}) {
  return _then(_DomainAppSettings(
theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as String,baseColor: null == baseColor ? _self.baseColor : baseColor // ignore: cast_nullable_to_non_nullable
as String,accentColor: null == accentColor ? _self.accentColor : accentColor // ignore: cast_nullable_to_non_nullable
as int,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,isMobileTitleOnTop: null == isMobileTitleOnTop ? _self.isMobileTitleOnTop : isMobileTitleOnTop // ignore: cast_nullable_to_non_nullable
as bool,tmdbApiKey: null == tmdbApiKey ? _self.tmdbApiKey : tmdbApiKey // ignore: cast_nullable_to_non_nullable
as String,proxy: null == proxy ? _self.proxy : proxy // ignore: cast_nullable_to_non_nullable
as String,proxyPort: null == proxyPort ? _self.proxyPort : proxyPort // ignore: cast_nullable_to_non_nullable
as String,enableProxy: null == enableProxy ? _self.enableProxy : enableProxy // ignore: cast_nullable_to_non_nullable
as bool,hardwareAcceleration: null == hardwareAcceleration ? _self.hardwareAcceleration : hardwareAcceleration // ignore: cast_nullable_to_non_nullable
as bool,subtitleFontSize: null == subtitleFontSize ? _self.subtitleFontSize : subtitleFontSize // ignore: cast_nullable_to_non_nullable
as double,subtitleColor: null == subtitleColor ? _self.subtitleColor : subtitleColor // ignore: cast_nullable_to_non_nullable
as String,playbackSpeed: null == playbackSpeed ? _self.playbackSpeed : playbackSpeed // ignore: cast_nullable_to_non_nullable
as double,autoPlayNext: null == autoPlayNext ? _self.autoPlayNext : autoPlayNext // ignore: cast_nullable_to_non_nullable
as bool,mangaReadMode: null == mangaReadMode ? _self.mangaReadMode : mangaReadMode // ignore: cast_nullable_to_non_nullable
as MangaReadMode,novelReadMode: null == novelReadMode ? _self.novelReadMode : novelReadMode // ignore: cast_nullable_to_non_nullable
as NovelReadMode,novelFontSize: null == novelFontSize ? _self.novelFontSize : novelFontSize // ignore: cast_nullable_to_non_nullable
as double,novelTheme: null == novelTheme ? _self.novelTheme : novelTheme // ignore: cast_nullable_to_non_nullable
as String,enableTTS: null == enableTTS ? _self.enableTTS : enableTTS // ignore: cast_nullable_to_non_nullable
as bool,devMode: null == devMode ? _self.devMode : devMode // ignore: cast_nullable_to_non_nullable
as bool,enableDevLog: null == enableDevLog ? _self.enableDevLog : enableDevLog // ignore: cast_nullable_to_non_nullable
as bool,enableDevNetwork: null == enableDevNetwork ? _self.enableDevNetwork : enableDevNetwork // ignore: cast_nullable_to_non_nullable
as bool,anilistToken: null == anilistToken ? _self.anilistToken : anilistToken // ignore: cast_nullable_to_non_nullable
as String,autoSyncTracking: null == autoSyncTracking ? _self.autoSyncTracking : autoSyncTracking // ignore: cast_nullable_to_non_nullable
as bool,downloadConcurrent: null == downloadConcurrent ? _self.downloadConcurrent : downloadConcurrent // ignore: cast_nullable_to_non_nullable
as int,downloadPath: null == downloadPath ? _self.downloadPath : downloadPath // ignore: cast_nullable_to_non_nullable
as String,autoDownload: null == autoDownload ? _self.autoDownload : autoDownload // ignore: cast_nullable_to_non_nullable
as bool,showContinueWatching: null == showContinueWatching ? _self.showContinueWatching : showContinueWatching // ignore: cast_nullable_to_non_nullable
as bool,showHistory: null == showHistory ? _self.showHistory : showHistory // ignore: cast_nullable_to_non_nullable
as bool,showFavorites: null == showFavorites ? _self.showFavorites : showFavorites // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$DomainSettingItem {

 String get key; String get value; String get type; String? get description;
/// Create a copy of DomainSettingItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainSettingItemCopyWith<DomainSettingItem> get copyWith => _$DomainSettingItemCopyWithImpl<DomainSettingItem>(this as DomainSettingItem, _$identity);

  /// Serializes this DomainSettingItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainSettingItem&&(identical(other.key, key) || other.key == key)&&(identical(other.value, value) || other.value == value)&&(identical(other.type, type) || other.type == type)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,value,type,description);

@override
String toString() {
  return 'DomainSettingItem(key: $key, value: $value, type: $type, description: $description)';
}


}

/// @nodoc
abstract mixin class $DomainSettingItemCopyWith<$Res>  {
  factory $DomainSettingItemCopyWith(DomainSettingItem value, $Res Function(DomainSettingItem) _then) = _$DomainSettingItemCopyWithImpl;
@useResult
$Res call({
 String key, String value, String type, String? description
});




}
/// @nodoc
class _$DomainSettingItemCopyWithImpl<$Res>
    implements $DomainSettingItemCopyWith<$Res> {
  _$DomainSettingItemCopyWithImpl(this._self, this._then);

  final DomainSettingItem _self;
  final $Res Function(DomainSettingItem) _then;

/// Create a copy of DomainSettingItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? value = null,Object? type = null,Object? description = freezed,}) {
  return _then(_self.copyWith(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainSettingItem].
extension DomainSettingItemPatterns on DomainSettingItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainSettingItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainSettingItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainSettingItem value)  $default,){
final _that = this;
switch (_that) {
case _DomainSettingItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainSettingItem value)?  $default,){
final _that = this;
switch (_that) {
case _DomainSettingItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String value,  String type,  String? description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainSettingItem() when $default != null:
return $default(_that.key,_that.value,_that.type,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String value,  String type,  String? description)  $default,) {final _that = this;
switch (_that) {
case _DomainSettingItem():
return $default(_that.key,_that.value,_that.type,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String value,  String type,  String? description)?  $default,) {final _that = this;
switch (_that) {
case _DomainSettingItem() when $default != null:
return $default(_that.key,_that.value,_that.type,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainSettingItem implements DomainSettingItem {
  const _DomainSettingItem({required this.key, required this.value, required this.type, this.description});
  factory _DomainSettingItem.fromJson(Map<String, dynamic> json) => _$DomainSettingItemFromJson(json);

@override final  String key;
@override final  String value;
@override final  String type;
@override final  String? description;

/// Create a copy of DomainSettingItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainSettingItemCopyWith<_DomainSettingItem> get copyWith => __$DomainSettingItemCopyWithImpl<_DomainSettingItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainSettingItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainSettingItem&&(identical(other.key, key) || other.key == key)&&(identical(other.value, value) || other.value == value)&&(identical(other.type, type) || other.type == type)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,value,type,description);

@override
String toString() {
  return 'DomainSettingItem(key: $key, value: $value, type: $type, description: $description)';
}


}

/// @nodoc
abstract mixin class _$DomainSettingItemCopyWith<$Res> implements $DomainSettingItemCopyWith<$Res> {
  factory _$DomainSettingItemCopyWith(_DomainSettingItem value, $Res Function(_DomainSettingItem) _then) = __$DomainSettingItemCopyWithImpl;
@override @useResult
$Res call({
 String key, String value, String type, String? description
});




}
/// @nodoc
class __$DomainSettingItemCopyWithImpl<$Res>
    implements _$DomainSettingItemCopyWith<$Res> {
  __$DomainSettingItemCopyWithImpl(this._self, this._then);

  final _DomainSettingItem _self;
  final $Res Function(_DomainSettingItem) _then;

/// Create a copy of DomainSettingItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? value = null,Object? type = null,Object? description = freezed,}) {
  return _then(_DomainSettingItem(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
