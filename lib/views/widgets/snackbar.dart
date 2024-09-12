import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';

showSnackBar({required BuildContext context, required String text}) {
  MoonToast.show(context, label: Text(text));
}
