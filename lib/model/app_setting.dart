import 'package:objectbox/objectbox.dart';

@Entity()
class AppSetting {
  // @Id(assignable: true)
  int id;

  @Unique(onConflict: ConflictStrategy.replace)
  // 键
  String key;
  // 值
  String value;

  AppSetting({this.id = 0, required this.key, required this.value});
}
