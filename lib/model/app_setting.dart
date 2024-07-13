import 'package:isar/isar.dart';

part 'app_setting.g.dart';

@collection
class AppSetting {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  // 键
  late String key;
  // 值
  late String value;
}
