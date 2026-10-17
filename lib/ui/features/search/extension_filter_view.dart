import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart';

/// A normalized, read-only view over any [ExtensionFilter] variant.
///
/// The gRPC contract carries filters as a typed oneof ([ExtensionFilter] with
/// `select` / `multiSelect` / `range` / `text` cases). The search UI only ever
/// needs a title, the option entries (key -> label), and optional selection
/// bounds, so this collapses the variants into a single shape and lets the
/// widgets stay filter-variant-agnostic.
class ExtensionFilterView {
  ExtensionFilterView({
    required this.kind,
    required this.title,
    required this.options,
    required this.min,
    required this.max,
    this.defaultSelect = '',
    this.defaultMultiSelect = const [],
    this.hint = '',
  });

  final String title;
  final List<ExtensionFilterOptionEntry> options;
  final int min;
  final int max;
  final String defaultSelect;
  final List<String> defaultMultiSelect;

  /// Placeholder text for a [ExtensionFilter_Kind.text] filter; empty for
  /// every other variant.
  final String hint;

  /// True when the variant does not define selection bounds (i.e. a plain
  /// single-select list). UI should treat it as min=max=1.
  bool get isSingleSelect => min == 0 && max == 0;

  /// True for a free-form text filter, which has no options and exactly one
  /// value. Widgets switch on this instead of re-deriving it from [options].
  bool get isText => kind == ExtensionFilter_Kind.text;

  /// The variant this view was built from, so callers that need to branch
  /// (e.g. the selection-count rules) do not have to re-read the raw proto.
  final ExtensionFilter_Kind kind;

  factory ExtensionFilterView.from(ExtensionFilter filter) {
    switch (filter.whichKind()) {
      case ExtensionFilter_Kind.select:
        final s = filter.select;
        return ExtensionFilterView(
          kind: ExtensionFilter_Kind.select,
          title: s.title,
          options: s.options.entries
              .map((e) => ExtensionFilterOptionEntry(e.key, e.value.label))
              .toList(),
          min: 1,
          max: 1,
          defaultSelect: s.default_2,
        );
      case ExtensionFilter_Kind.multiSelect:
        final m = filter.multiSelect;
        return ExtensionFilterView(
          kind: ExtensionFilter_Kind.multiSelect,
          title: m.title,
          options: m.options.entries
              .map((e) => ExtensionFilterOptionEntry(e.key, e.value.label))
              .toList(),
          min: m.min,
          max: m.max,
          defaultMultiSelect: List.from(m.default_4),
        );
      case ExtensionFilter_Kind.range:
        final r = filter.range;
        return ExtensionFilterView(
          kind: ExtensionFilter_Kind.range,
          title: r.title,
          options: const [],
          min: r.min,
          max: r.max,
        );
      case ExtensionFilter_Kind.text:
        final t = filter.text;
        return ExtensionFilterView(
          kind: ExtensionFilter_Kind.text,
          title: t.title,
          options: const [],
          // A text filter is single-valued: one string in, one string out.
          min: 1,
          max: 1,
          defaultSelect: t.default_2,
          hint: t.hint,
        );
      case ExtensionFilter_Kind.notSet:
        return ExtensionFilterView(
          kind: ExtensionFilter_Kind.notSet,
          title: '',
          options: const [],
          min: 0,
          max: 0,
        );
    }
  }
}

class ExtensionFilterOptionEntry {
  const ExtensionFilterOptionEntry(this.key, this.label);
  final String key;
  final String label;
}
