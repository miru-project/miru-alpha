import 'package:flutter/foundation.dart';

/// Render target the driver writes to — the PathEl port. `d` + paint attrs
/// land here per frame; a CustomPainter listens and repaints.
class MorphSurface extends ChangeNotifier {
  String d = '';
  final Map<String, String> attrs = {};

  void setAttribute(String name, String value) {
    if (name == 'd') {
      d = value;
    } else {
      attrs[name] = value;
    }
    notifyListeners();
  }
}
