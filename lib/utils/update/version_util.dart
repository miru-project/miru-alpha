/// Compares Miru version strings such as `2.0.3-alpha`, `v2.1`, `2.1+5`.
library;

/// A parsed version: the numeric core (`major.minor.patch`) and an optional
/// pre-release suffix (`alpha`, `beta.1`, `rc.2`).
typedef ParsedVersion = ({List<int> core, String? pre});

/// Splits a raw tag or version into its core and pre-release parts.
///
/// Accepts a leading `v`, a `+build` suffix and any number of core
/// segments — Miru's own tags are `v2.0.3-alpha`, but a shorter `2.1` must
/// still compare sanely against a longer one.
ParsedVersion parseVersion(String raw) {
  var value = raw.trim();
  if (value.startsWith('v') || value.startsWith('V')) {
    value = value.substring(1);
  }
  final plus = value.indexOf('+');
  if (plus >= 0) value = value.substring(0, plus);

  String? pre;
  final dash = value.indexOf('-');
  if (dash >= 0) {
    pre = value.substring(dash + 1);
    value = value.substring(0, dash);
  }

  final core = <int>[];
  for (final part in value.split('.')) {
    if (part.isEmpty) continue;
    core.add(int.tryParse(part) ?? 0);
  }
  return (core: core, pre: pre);
}

/// Compares two version strings.
///
/// Returns a negative number when [a] is older than [b], zero when they are
/// equal, and a positive number when [a] is newer. A release without a
/// pre-release suffix (`2.1`) outranks one with it (`2.1-alpha`), matching
/// semver, so the alpha channel never sees a newer "release" than the build
/// it just installed.
int compareVersions(String a, String b) {
  final left = parseVersion(a);
  final right = parseVersion(b);

  final length = left.core.length > right.core.length
      ? left.core.length
      : right.core.length;
  for (var i = 0; i < length; i++) {
    final l = i < left.core.length ? left.core[i] : 0;
    final r = i < right.core.length ? right.core[i] : 0;
    if (l != r) return l < r ? -1 : 1;
  }

  return _comparePreRelease(left.pre, right.pre);
}

/// A released pre-release is older than the matching final version.
int _comparePreRelease(String? a, String? b) {
  if (a == b) return 0;
  if (a == null) return 1;
  if (b == null) return -1;

  final left = a.split('.');
  final right = b.split('.');
  final length = left.length > right.length ? left.length : right.length;
  for (var i = 0; i < length; i++) {
    if (i >= left.length) return -1;
    if (i >= right.length) return 1;
    final l = left[i];
    final r = right[i];
    if (l == r) continue;

    final ln = int.tryParse(l);
    final rn = int.tryParse(r);
    // Numeric identifiers sort below alphanumeric ones (semver §11.4).
    if (ln != null && rn != null) return ln < rn ? -1 : 1;
    if (ln != null) return -1;
    if (rn != null) return 1;
    return l.compareTo(r) < 0 ? -1 : 1;
  }
  return 0;
}
