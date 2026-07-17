// GENERATED FILE - canonical Forui CLI base + primary color tokens.
//
// Values copied verbatim from forui_cli (package:forui_cli/forui_cli.dart ->
// codec.dart), which defines `BaseColor` (7 bases) and `PrimaryColor`
// (17 colors + None). The runtime theme composition in `theme.dart`
// (`ThemeUtils.composeColors`) applies forui_cli's exact rule:
//
//     primary           = primary?.primary           ?? base.primary
//     primaryForeground  = primary?.primaryForeground  ?? base.primaryForeground
//     // all other 12 fields are taken from the base scale
//
// This mirrors `forui_cli theme create --preset <base><primary>...`.

/// A full neutral greyscale scale (background, foreground, secondary, muted,
/// border, card, destructive/error, and the base's own primary pair).
typedef BaseScale = ({
  int barrier,
  int background,
  int foreground,
  int primary,
  int primaryForeground,
  int secondary,
  int secondaryForeground,
  int muted,
  int mutedForeground,
  int destructive,
  int destructiveForeground,
  int error,
  int errorForeground,
  int card,
  int border,
});

/// Just the `primary` / `primaryForeground` pair layered on top of a base.
typedef PrimaryPair = ({int primary, int primaryForeground});

/// Base greyscale scales, keyed by Forui CLI base color name.
const Map<String, ({BaseScale light, BaseScale dark})> baseColorsData = {
  'neutral': (
    light: (barrier: 0x33000000, background: 0xFFFFFFFF, foreground: 0xFF0A0A0A, primary: 0xFF171717, primaryForeground: 0xFFFAFAFA, secondary: 0xFFF5F5F5, secondaryForeground: 0xFF171717, muted: 0xFFF5F5F5, mutedForeground: 0xFF737373, destructive: 0xFFE7000B, destructiveForeground: 0xFFFAFAFA, error: 0xFFE7000B, errorForeground: 0xFFFAFAFA, card: 0xFFFFFFFF, border: 0xFFE5E5E5),
    dark: (barrier: 0x7A000000, background: 0xFF0A0A0A, foreground: 0xFFFAFAFA, primary: 0xFFE5E5E5, primaryForeground: 0xFF171717, secondary: 0xFF262626, secondaryForeground: 0xFFFAFAFA, muted: 0xFF262626, mutedForeground: 0xFFA1A1A1, destructive: 0xFFFF6467, destructiveForeground: 0xFFFAFAFA, error: 0xFFFF6467, errorForeground: 0xFFFAFAFA, card: 0xFF171717, border: 0x1AFFFFFF),
  ),
  'stone': (
    light: (barrier: 0x33000000, background: 0xFFFFFFFF, foreground: 0xFF0C0A09, primary: 0xFF1C1917, primaryForeground: 0xFFFAFAF9, secondary: 0xFFF5F5F4, secondaryForeground: 0xFF1C1917, muted: 0xFFF5F5F4, mutedForeground: 0xFF79716B, destructive: 0xFFE7000B, destructiveForeground: 0xFFFAFAFA, error: 0xFFE7000B, errorForeground: 0xFFFAFAFA, card: 0xFFFFFFFF, border: 0xFFE7E5E4),
    dark: (barrier: 0x7A000000, background: 0xFF0C0A09, foreground: 0xFFFAFAF9, primary: 0xFFE7E5E4, primaryForeground: 0xFF1C1917, secondary: 0xFF292524, secondaryForeground: 0xFFFAFAF9, muted: 0xFF292524, mutedForeground: 0xFFA6A09B, destructive: 0xFFFF6467, destructiveForeground: 0xFFFAFAFA, error: 0xFFFF6467, errorForeground: 0xFFFAFAFA, card: 0xFF1C1917, border: 0x1AFFFFFF),
  ),
  'zinc': (
    light: (barrier: 0x33000000, background: 0xFFFFFFFF, foreground: 0xFF09090B, primary: 0xFF18181B, primaryForeground: 0xFFFAFAFA, secondary: 0xFFF4F4F5, secondaryForeground: 0xFF18181B, muted: 0xFFF4F4F5, mutedForeground: 0xFF71717B, destructive: 0xFFE7000B, destructiveForeground: 0xFFFAFAFA, error: 0xFFE7000B, errorForeground: 0xFFFAFAFA, card: 0xFFFFFFFF, border: 0xFFE4E4E7),
    dark: (barrier: 0x7A000000, background: 0xFF09090B, foreground: 0xFFFAFAFA, primary: 0xFFE4E4E7, primaryForeground: 0xFF18181B, secondary: 0xFF27272A, secondaryForeground: 0xFFFAFAFA, muted: 0xFF27272A, mutedForeground: 0xFF9F9FA9, destructive: 0xFFFF6467, destructiveForeground: 0xFFFAFAFA, error: 0xFFFF6467, errorForeground: 0xFFFAFAFA, card: 0xFF18181B, border: 0x1AFFFFFF),
  ),
  'mauve': (
    light: (barrier: 0x33000000, background: 0xFFFFFFFF, foreground: 0xFF0C090C, primary: 0xFF1D161E, primaryForeground: 0xFFFAFAFA, secondary: 0xFFF3F1F3, secondaryForeground: 0xFF1D161E, muted: 0xFFF3F1F3, mutedForeground: 0xFF79697B, destructive: 0xFFE7000B, destructiveForeground: 0xFFFAFAFA, error: 0xFFE7000B, errorForeground: 0xFFFAFAFA, card: 0xFFFFFFFF, border: 0xFFE7E4E7),
    dark: (barrier: 0x7A000000, background: 0xFF0C090C, foreground: 0xFFFAFAFA, primary: 0xFFE7E4E7, primaryForeground: 0xFF1D161E, secondary: 0xFF2A212C, secondaryForeground: 0xFFFAFAFA, muted: 0xFF2A212C, mutedForeground: 0xFFA89EA9, destructive: 0xFFFF6467, destructiveForeground: 0xFFFAFAFA, error: 0xFFFF6467, errorForeground: 0xFFFAFAFA, card: 0xFF1D161E, border: 0x1AFFFFFF),
  ),
  'olive': (
    light: (barrier: 0x33000000, background: 0xFFFFFFFF, foreground: 0xFF0C0C09, primary: 0xFF1D1D16, primaryForeground: 0xFFFBFBF9, secondary: 0xFFF4F4F0, secondaryForeground: 0xFF1D1D16, muted: 0xFFF4F4F0, mutedForeground: 0xFF7C7C67, destructive: 0xFFE7000B, destructiveForeground: 0xFFFAFAFA, error: 0xFFE7000B, errorForeground: 0xFFFAFAFA, card: 0xFFFFFFFF, border: 0xFFE8E8E3),
    dark: (barrier: 0x7A000000, background: 0xFF0C0C09, foreground: 0xFFFBFBF9, primary: 0xFFE8E8E3, primaryForeground: 0xFF1D1D16, secondary: 0xFF2B2B22, secondaryForeground: 0xFFFBFBF9, muted: 0xFF2B2B22, mutedForeground: 0xFFABAB9C, destructive: 0xFFFF6467, destructiveForeground: 0xFFFAFAFA, error: 0xFFFF6467, errorForeground: 0xFFFAFAFA, card: 0xFF1D1D16, border: 0x1AFFFFFF),
  ),
  'mist': (
    light: (barrier: 0x33000000, background: 0xFFFFFFFF, foreground: 0xFF090B0C, primary: 0xFF161B1D, primaryForeground: 0xFFF9FBFB, secondary: 0xFFF1F3F3, secondaryForeground: 0xFF161B1D, muted: 0xFFF1F3F3, mutedForeground: 0xFF67787C, destructive: 0xFFE7000B, destructiveForeground: 0xFFFAFAFA, error: 0xFFE7000B, errorForeground: 0xFFFAFAFA, card: 0xFFFFFFFF, border: 0xFFE3E7E8),
    dark: (barrier: 0x7A000000, background: 0xFF090B0C, foreground: 0xFFF9FBFB, primary: 0xFFE3E7E8, primaryForeground: 0xFF161B1D, secondary: 0xFF22292B, secondaryForeground: 0xFFF9FBFB, muted: 0xFF22292B, mutedForeground: 0xFF9CA8AB, destructive: 0xFFFF6467, destructiveForeground: 0xFFFAFAFA, error: 0xFFFF6467, errorForeground: 0xFFFAFAFA, card: 0xFF161B1D, border: 0x1AFFFFFF),
  ),
  'taupe': (
    light: (barrier: 0x33000000, background: 0xFFFFFFFF, foreground: 0xFF0C0A09, primary: 0xFF1D1816, primaryForeground: 0xFFFBFAF9, secondary: 0xFFF3F1F1, secondaryForeground: 0xFF1D1816, muted: 0xFFF3F1F1, mutedForeground: 0xFF7C6D67, destructive: 0xFFE7000B, destructiveForeground: 0xFFFAFAFA, error: 0xFFE7000B, errorForeground: 0xFFFAFAFA, card: 0xFFFFFFFF, border: 0xFFE8E4E3),
    dark: (barrier: 0x7A000000, background: 0xFF0C0A09, foreground: 0xFFFBFAF9, primary: 0xFFE8E4E3, primaryForeground: 0xFF1D1816, secondary: 0xFF2B2422, secondaryForeground: 0xFFFBFAF9, muted: 0xFF2B2422, mutedForeground: 0xFFABA09C, destructive: 0xFFFF6467, destructiveForeground: 0xFFFAFAFA, error: 0xFFFF6467, errorForeground: 0xFFFAFAFA, card: 0xFF1D1816, border: 0x1AFFFFFF),
  ),
};

/// Primary accent pairs, keyed by Forui CLI primary color name.
/// `null` is encoded by Forui CLI as 'a' (None) and means "inherit the base color".
const Map<String, ({PrimaryPair light, PrimaryPair dark})> primaryColorsData = {
  'amber': (
    light: (primary: 0xFFBB4D00, primaryForeground: 0xFFFFFBEB),
    dark: (primary: 0xFF973C00, primaryForeground: 0xFFFFFBEB),
  ),
  'blue': (
    light: (primary: 0xFF1447E6, primaryForeground: 0xFFEFF6FF),
    dark: (primary: 0xFF193CB8, primaryForeground: 0xFFEFF6FF),
  ),
  'cyan': (
    light: (primary: 0xFF007595, primaryForeground: 0xFFECFEFF),
    dark: (primary: 0xFF005F78, primaryForeground: 0xFFECFEFF),
  ),
  'emerald': (
    light: (primary: 0xFF007A55, primaryForeground: 0xFFECFDF5),
    dark: (primary: 0xFF006045, primaryForeground: 0xFFECFDF5),
  ),
  'fuchsia': (
    light: (primary: 0xFFA800B7, primaryForeground: 0xFFFDF4FF),
    dark: (primary: 0xFF8A0194, primaryForeground: 0xFFFDF4FF),
  ),
  'green': (
    light: (primary: 0xFF008236, primaryForeground: 0xFFF0FDF4),
    dark: (primary: 0xFF016630, primaryForeground: 0xFFF0FDF4),
  ),
  'indigo': (
    light: (primary: 0xFF432DD7, primaryForeground: 0xFFEEF2FF),
    dark: (primary: 0xFF372AAC, primaryForeground: 0xFFEEF2FF),
  ),
  'lime': (
    light: (primary: 0xFF9AE600, primaryForeground: 0xFF35530E),
    dark: (primary: 0xFF7CCF00, primaryForeground: 0xFF35530E),
  ),
  'orange': (
    light: (primary: 0xFFCA3500, primaryForeground: 0xFFFFF7ED),
    dark: (primary: 0xFF9F2D00, primaryForeground: 0xFFFFF7ED),
  ),
  'pink': (
    light: (primary: 0xFFC6005C, primaryForeground: 0xFFFDF2F8),
    dark: (primary: 0xFFA3004C, primaryForeground: 0xFFFDF2F8),
  ),
  'purple': (
    light: (primary: 0xFF8200DB, primaryForeground: 0xFFFAF5FF),
    dark: (primary: 0xFF6E11B0, primaryForeground: 0xFFFAF5FF),
  ),
  'red': (
    light: (primary: 0xFFC10007, primaryForeground: 0xFFFEF2F2),
    dark: (primary: 0xFF9F0712, primaryForeground: 0xFFFEF2F2),
  ),
  'rose': (
    light: (primary: 0xFFC70036, primaryForeground: 0xFFFFF1F2),
    dark: (primary: 0xFFA50036, primaryForeground: 0xFFFFF1F2),
  ),
  'sky': (
    light: (primary: 0xFF0069A8, primaryForeground: 0xFFF0F9FF),
    dark: (primary: 0xFF00598A, primaryForeground: 0xFFF0F9FF),
  ),
  'teal': (
    light: (primary: 0xFF00786F, primaryForeground: 0xFFF0FDFA),
    dark: (primary: 0xFF005F5A, primaryForeground: 0xFFF0FDFA),
  ),
  'violet': (
    light: (primary: 0xFF7008E7, primaryForeground: 0xFFF5F3FF),
    dark: (primary: 0xFF5D0EC0, primaryForeground: 0xFFF5F3FF),
  ),
  'yellow': (
    light: (primary: 0xFFFDC700, primaryForeground: 0xFF733E0A),
    dark: (primary: 0xFFF0B100, primaryForeground: 0xFF733E0A),
  ),
};

