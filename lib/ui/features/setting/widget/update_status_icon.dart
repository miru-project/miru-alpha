import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/provider/app_update_provider.dart';

/// The one glyph per update state.
///
/// Both update surfaces draw this — the settings banner and the launch prompt —
/// and they used to disagree: the banner showed a tray arrow for "available" and
/// a down arrow for "downloading", the dialog the other way round. The same
/// state carrying two different icons is the kind of thing a user notices
/// without being able to say why.
IconData updateStatusIcon(UpdateStatus status) => switch (status) {
  UpdateStatus.checking => FLucideIcons.loaderCircle,
  UpdateStatus.upToDate => FLucideIcons.circleCheck,
  UpdateStatus.available => FLucideIcons.arrowDownToLine,
  UpdateStatus.downloading => FLucideIcons.download,
  UpdateStatus.downloaded => FLucideIcons.circleCheck,
  UpdateStatus.failed => FLucideIcons.triangleAlert,
  UpdateStatus.idle => FLucideIcons.circleAlert,
};

/// The version as the user should read it: the numeric core, without the
/// pre-release suffix. "2.0.3-alpha" reads as "2.0.3" — the release channel
/// is the app's business, not something the update surfaces must spell out.
String shortVersion(String version) => version.split('-').first;
