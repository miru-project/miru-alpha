import 'package:miru_alpha/miru_core/grpc_client.dart';
import 'package:miru_alpha/miru_core/proto/proto.dart';

class SettingsService {
  Future<Map<String, String>> getAllSettings() async {
    try {
      final response = await MiruGrpcClient.appSettingClient.getAppSetting(
        GetAppSettingRequest(),
      );
      return {
        for (final setting in response.settings) setting.key: setting.value,
      };
    } catch (e) {
      return {};
    }
  }

  Future<String?> getSetting(String key) async {
    try {
      final response = await MiruGrpcClient.appSettingClient.getAppSetting(
        GetAppSettingRequest(),
      );
      final setting = response.settings.firstWhere(
        (s) => s.key == key,
        orElse: () => AppSetting(),
      );
      return setting.hasValue() ? setting.value : null;
    } catch (e) {
      return null;
    }
  }

  Future<void> setSetting(String key, String value) async {
    try {
      await MiruGrpcClient.appSettingClient.setAppSetting(
        SetAppSettingRequest(
          settings: [AppSetting(key: key, value: value)],
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteSetting(String key) async {
    try {
      await MiruGrpcClient.appSettingClient.setAppSetting(
        SetAppSettingRequest(
          settings: [AppSetting(key: key, value: '')],
        ),
      );
    } catch (e) {
      rethrow;
    }
  }
}
