import 'dart:async';
import 'dart:io';

import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:flutter/material.dart';
import 'package:miru_app_new/utils/index.dart';
import 'package:miru_app_new/utils/tracking/anilist_provider.dart';

class AnilistPageNotifier with ChangeNotifier {
  bool _anilistIsLogin = false;
  late AnilistUserData _anilistUserData;
  bool get anilistIsLogin => _anilistIsLogin;
  AnilistUserData get anilistUserData => _anilistUserData;
  bool isLoading = false;
  void _saveAnilistToken(String result) {
    RegExp tokenRegex = RegExp(r'(?<=access_token=).+(?=&token_type)');
    Match? re = tokenRegex.firstMatch(result);
    if (re != null) {
      String token = re.group(0)!;
      updateAniListToken(token);
      anilistDataLoad();
    }
  }

  void updateAniListToken(String accessToken) {
    MiruStorage.setSettingSync(SettingKey.aniListToken, accessToken);
    _anilistIsLogin = true;
    notifyListeners();
    // initAnilistData();
  }

  void logoutAniList() {
    MiruStorage.setSettingSync(SettingKey.aniListToken, "");
    _anilistIsLogin = false;
    notifyListeners();
  }

  Future<AnilistUserData> anilistDataLoad() async {
    isLoading = true;
    notifyListeners();
    final userData = await AniListProvider.getuserData();
    final animeData = await AniListProvider.getCollection(AnilistType.anime);
    final mangaData = await AniListProvider.getCollection(AnilistType.manga);
    final result = AnilistUserData(
        userData: userData, animeData: animeData, mangaData: mangaData);
    _anilistUserData = result;
    isLoading = false;
    notifyListeners();
    return result;
  }

  void loginAniList(BuildContext context) async {
    const loginUrl =
        "https://anilist.co/api/v2/oauth/authorize?client_id=16214&response_type=token";
    if (Platform.isAndroid) {
      // final result = await Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //       builder: (context) => const AnilistWebViewPage(url: loginUrl)),
      // );
      // _saveAnilistToken(result);
      return;
    }
    final webview = await WebviewWindow.create(
        configuration: const CreateConfiguration(title: "Anilist Login"))
      ..launch(loginUrl);

    Timer.periodic(const Duration(seconds: 1), (timer) async {
      final url =
          await webview.evaluateJavaScript('window.location.href') ?? "";
      debugPrint(url);
      if (url.contains("access_token")) {
        _saveAnilistToken(url);
        timer.cancel();
        webview.close();
        debugPrint("Token saved");
      }
    });
  }

  void init() {
    final token = MiruStorage.getSettingSync(SettingKey.aniListToken, String);
    if (token != "") {
      _anilistIsLogin = true;
      notifyListeners();
    }
  }
}

class AnilistUserData {
  final Map<String, dynamic> userData;
  final Map<String, dynamic> animeData;
  final Map<String, dynamic> mangaData;
  final bool isError;
  const AnilistUserData({
    required this.userData,
    required this.animeData,
    required this.mangaData,
    this.isError = false,
  });
}
