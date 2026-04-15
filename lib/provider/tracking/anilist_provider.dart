import 'dart:async';
import 'package:miru_alpha/model/anilist_model.dart';
import 'package:miru_alpha/utils/tracking/anilist_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

part 'anilist_provider.g.dart';

@riverpod
class AnilistAccount extends _$AnilistAccount {
  Timer? _timer;

  @override
  Future<AnilistUser?> build() async {
    ref.onDispose(() => _timer?.cancel());
    try {
      return await AniListProvider.getuserData();
    } catch (e) {
      return null;
    }
  }

  Future<void> login() async {
    final url = Uri.parse("http://127.0.0.1:3000/anilist");
    await launchUrl(url, mode: LaunchMode.externalApplication);

    // Cancel existing timer if any
    _timer?.cancel();

    // Start polling for user data
    int attempts = 0;
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      attempts++;
      if (attempts > 40) {
        // Timeout after 2 minutes
        timer.cancel();
        return;
      }

      try {
        final user = await AniListProvider.getuserData();
        state = AsyncValue.data(user);
        timer.cancel();
      } catch (_) {
        // Keep polling
      }
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => AniListProvider.getuserData());
  }

  Future<void> logout() async {
    await AniListProvider.logout();
    state = const AsyncValue.data(null);
  }
}

@riverpod
class AnilistCollectionNotifier extends _$AnilistCollectionNotifier {
  @override
  FutureOr<List<AnilistList>> build(AnilistType type) async {
    final user = ref.watch(anilistAccountProvider).value;
    if (user == null) return [];
    return await AniListProvider.getCollection(type, user.id);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(anilistAccountProvider).value;
      if (user == null) return [];
      return await AniListProvider.getCollection(type, user.id);
    });
  }
}
