import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Inlined SVG sources shared by call sites that must not depend on runtime
/// asset loading.
///
/// The flutter tool rewrites `data/flutter_assets` (open with O_TRUNC) while
/// the engine boots. An asset read racing that window comes back empty and
/// the engine reports "Unable to load asset" — which in at least one run
/// persisted for the process's whole lifetime, leaving the AniList mark on
/// the detail page blank. Parsing the source in memory sidesteps the asset
/// channel completely.

/// The AniList logo mark (same geometry as `assets/svg/anilist.svg`).
const String kAniListSvg =
    '<svg fill="#000000" viewBox="0 0 24 24" '
    'role="img" xmlns="http://www.w3.org/2000/svg">'
    '<path d="M6.361 2.943 0 21.056h4.942l1.077-3.133H11.4l1.052 3.133H22.9'
    'c.71 0 1.1-.392 1.1-1.101V17.53c0-.71-.39-1.101-1.1-1.101h-6.483V4.045'
    'c0-.71-.392-1.102-1.101-1.102h-2.422c-.71 0-1.101.392-1.101 1.102v1.064'
    'l-.758-2.166zm2.324 5.948 1.688 5.018H7.144z"></path></svg>';

/// The AniList mark rendered from [kAniListSvg] — no asset-bundle I/O.
Widget anilistLogo({required double size, required Color color}) =>
    SvgPicture.string(
      kAniListSvg,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
