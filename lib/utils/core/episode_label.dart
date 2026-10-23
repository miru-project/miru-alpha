/// Utilities for normalising extension episode titles for display.
library;

/// Strips a leading "Episode N - " / "Episode N: " prefix from [name] so a
/// row that already shows the episode number doesn't repeat the word
/// "Episode" and the number a second time.
String stripEpisodePrefix(String name) =>
    name.replaceFirst(RegExp(r'^Episode\s+\d+\s*[-–—:]\s*'), '');
