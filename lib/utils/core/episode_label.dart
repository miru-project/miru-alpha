/// Utilities for normalising extension episode titles for display.
library;

/// Strips a leading "Episode N - " / "Episode N: " / "Ep N: " prefix from
/// [name] so a row that already shows the episode number doesn't repeat
/// the word "Episode"/"Ep" and the number a second time.
String stripEpisodePrefix(String name) =>
    name.replaceFirst(RegExp(r'^[Ee][Pp](?:isode)?\s+\d+\s*[-–—:]\s*'), '');
