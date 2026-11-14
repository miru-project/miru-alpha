//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <fvp/fvp_plugin_c_api.h>
#include <screen_brightness_windows/screen_brightness_windows_plugin_c_api.h>
#include <url_launcher_windows/url_launcher_windows.h>
#include <share_plus/share_plus_windows_plugin_c_api.h>
#include <volume_controller/volume_controller_plugin_c_api.h>
#include <webview_all_windows/webview_all_windows_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  FvpPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FvpPluginCApi"));
  ScreenBrightnessWindowsPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ScreenBrightnessWindowsPluginCApi"));
  UrlLauncherWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UrlLauncherWindows"));
  SharePlusWindowsPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("SharePlusWindowsPluginCApi"));
  VolumeControllerPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("VolumeControllerPluginCApi"));
  WebviewAllWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WebviewAllWindowsPlugin"));
}
