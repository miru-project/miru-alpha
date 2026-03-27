import 'package:miru_alpha/miru_core/grpc_client.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension.pbgrpc.dart'
    as $grpc;
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart'
    as $model;

enum ExtensionSettingType { input, radio, toggle }

class ExtensionSetting {
  int id;
  String package;
  String title;
  String key;
  String? value;
  String defaultValue;
  ExtensionSettingType type;
  String? description;
  String? options;

  ExtensionSetting({
    this.id = 0,
    required this.package,
    required this.title,
    required this.key,
    this.value,
    required this.defaultValue,
    this.type = ExtensionSettingType.input,
    this.description,
    this.options,
  });

  factory ExtensionSetting.fromProto($model.ExtensionSetting proto) {
    return ExtensionSetting(
      id: proto.id,
      package: proto.package,
      title: proto.title,
      key: proto.key,
      value: proto.hasValue() ? proto.value : null,
      defaultValue: proto.defaultValue,
      type: _typeFromProto(proto.type),
      description: proto.hasDescription() ? proto.description : null,
      options: proto.hasOptions() ? proto.options : null,
    );
  }

  $model.ExtensionSetting toProto() {
    final proto = $model.ExtensionSetting()
      ..id = id
      ..package = package
      ..title = title
      ..key = key
      ..defaultValue = defaultValue
      ..type = _typeToProto(type);

    if (value != null) proto.value = value!;
    if (description != null) proto.description = description!;
    if (options != null) proto.options = options!;

    return proto;
  }

  static ExtensionSettingType _typeFromProto(
    $model.ExtensionSettingType protoType,
  ) {
    switch (protoType) {
      case $model.ExtensionSettingType.radio:
        return ExtensionSettingType.radio;
      case $model.ExtensionSettingType.toggle:
        return ExtensionSettingType.toggle;
      case $model.ExtensionSettingType.input:
      default:
        return ExtensionSettingType.input;
    }
  }

  static $model.ExtensionSettingType _typeToProto(ExtensionSettingType type) {
    switch (type) {
      case ExtensionSettingType.input:
        return $model.ExtensionSettingType.input;
      case ExtensionSettingType.radio:
        return $model.ExtensionSettingType.radio;
      case ExtensionSettingType.toggle:
        return $model.ExtensionSettingType.toggle;
    }
  }

  static Future<List<ExtensionSetting>> getSettings(String package) async {
    final response = await MiruGrpcClient.extensionClient.getExtensionSettings(
      $grpc.GetExtensionSettingsRequest(pkg: package),
    );
    return response.settings.map((e) => ExtensionSetting.fromProto(e)).toList();
  }

  static Future<void> saveSettings(
    String package,
    List<ExtensionSetting> settings,
  ) async {
    await MiruGrpcClient.extensionClient.saveExtensionSettings(
      $grpc.SaveExtensionSettingsRequest(
        pkg: package,
        settings: settings.map((e) => e.toProto()).toList(),
      ),
    );
  }
}
