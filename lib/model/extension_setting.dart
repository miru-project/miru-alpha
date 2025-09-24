// import 'package:objectbox/objectbox.dart';

// enum ExtensionSettingType {
//   // 输入框
//   input,
//   // 单选
//   radio,
//   // 开关
//   toggle,
// }

// @Entity()
// class ExtensionSetting {
//   @Id()
//   int id;

//   String package;

//   // 标题
//   String title;

//   // 键
//   String key;

//   // 值
//   String? value;

//   // 默认值
//   String defaultValue;

//   // 类型
//   String dbType;

//   @Transient()
//   ExtensionSettingType? type;

//   // 描述
//   String? description;

//   String? options;

//   ExtensionSetting({
//     this.id = 0,
//     required this.package,
//     required this.title,
//     required this.key,
//     this.value,
//     required this.defaultValue,
//     this.dbType = "input",
//     this.description,
//     this.options,
//   }) {
//     type = stringToType(dbType);
//   }

//   // int? get dbExtensionSetting {
//   //   _ensureStableEnumValues();
//   //   return dbType.index;
//   // }

//   // void _ensureStableEnumValues() {
//   //   assert(ExtensionSettingType.input.index == 0);
//   //   assert(ExtensionSettingType.radio.index == 1);
//   //   assert(ExtensionSettingType.toggle.index == 2);
//   // }

//   // set dbExtensionSetting(int? value) {
//   //   _ensureStableEnumValues();
//   //   dbType = ExtensionSettingType.values[value ?? 0];
//   // }

//   static ExtensionSettingType stringToType(String type) {
//     switch (type) {
//       case 'input':
//         return ExtensionSettingType.input;
//       case 'radio':
//         return ExtensionSettingType.radio;
//       case 'toggle':
//         return ExtensionSettingType.toggle;
//       default:
//         return ExtensionSettingType.input;
//     }
//   }

//   static String typeToString(ExtensionSettingType type) {
//     switch (type) {
//       case ExtensionSettingType.input:
//         return 'input';
//       case ExtensionSettingType.radio:
//         return 'radio';
//       case ExtensionSettingType.toggle:
//         return 'toggle';
//     }
//   }
// }
