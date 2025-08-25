// import 'dart:convert';
// import 'dart:io';
// import 'package:dio/dio.dart' as dio;
// import 'package:path/path.dart' as path;
import '../../miru_core/extension/extension_service.dart';

class ExtensionUtils {
  static Map<String, ExtensionApi> runtimes = {};
  static Map<String, String> extensionErrorMap = {};

  // 初始化扩展
  static Future<void> ensureInitialized() async {}
}
