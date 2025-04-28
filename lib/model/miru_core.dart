import 'dart:convert';

class MiruCoreResponse {
  final bool success;
  final String message;
  final Map<String, dynamic> data;
  final int code;

  MiruCoreResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.code,
  });

  factory MiruCoreResponse.fromJson(Map<String, dynamic> json) {
    return MiruCoreResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] as Map<String, dynamic>,
      code: json['code'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data, 'code': code};
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
