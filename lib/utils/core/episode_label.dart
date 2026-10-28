/// Utilities for normalising extension episode titles for display.
library;

/// Strips a leading "Episode N - " / "Episode N: " / "Ep N: " prefix from
/// [name] so a row that already shows the episode number doesn't repeat
/// the word "Episode"/"Ep" and the number a second time.
String stripEpisodePrefix(String name) =>
    name.replaceFirst(RegExp(r'^[Ee][Pp](?:isode)?\s+\d+\s*[-–—:]\s*'), '');

/// True when what remains after [stripEpisodePrefix] is empty or a bare
/// backend number ("0", "12") — such names read as raw data keys next to
/// the row's ordinal and must render as a human "Episode N" label instead.
bool isBareEpisodeName(String name) {
  final stripped = stripEpisodePrefix(name).trim();
  return stripped.isEmpty || int.tryParse(stripped) != null;
}
