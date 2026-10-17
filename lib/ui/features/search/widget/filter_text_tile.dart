import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart';
import 'package:miru_alpha/ui/features/search/widget/filter_select_controls.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// A [TextFilter] rendered as an inline [FTextField].
///
/// Inline, not a popup. The filter list is already rendered inside the filter
/// dialog / overlay, and `rules.md` #23 forbids stacking a modal inside a
/// modal — a nested dialog also made the whole surface invisible to the
/// marionette element walk (0 elements reported while it was open), which
/// breaks live verification. `_RangeFilterField` is the in-repo precedent: it
/// edits its range with inline `FTextField`s in the same body.
///
/// Forui native first: the field, its focus ring, clear button and text
/// handling all come from `FTextField`; this adds only the filter title as the
/// field's label and the commit policy.
class FilterTextField extends StatefulWidget {
  const FilterTextField({
    super.key,
    required this.filter,
    required this.value,
    required this.onChanged,
    this.showLabel = true,
  });

  /// Whether the field renders its own title as the Forui label. Set false
  /// where an outer section header already shows it (the dialog panel), so
  /// the name appears exactly once (rules.md #23).
  final bool showLabel;

  final TextFilter filter;

  /// The currently applied value; empty means the filter is unset.
  final String value;

  /// Called with the committed value, or an empty string when cleared.
  final ValueChanged<String> onChanged;

  @override
  State<FilterTextField> createState() => _FilterTextFieldState();
}

class _FilterTextFieldState extends State<FilterTextField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.value,
  );
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Commit on focus loss as well as on submit, so a user who types and then
    // taps elsewhere does not silently lose the edit.
    _focus.addListener(() {
      if (!_focus.hasFocus) _commit();
    });
  }

  @override
  void didUpdateWidget(covariant FilterTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // An external change (Clear, reset-to-default) must reach the field, but a
    // rebuild caused by our own commit must not clobber what is being typed.
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _commit() {
    final next = _controller.text.trim();
    if (next != widget.value) widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) => FTextField(
    // The hint doubles as the example, so an unset filter reads as
    // "Author / e.g. Fujimoto".
    label: widget.showLabel ? Text(widget.filter.title) : null,
    hint: widget.filter.hint.isNotEmpty
        ? widget.filter.hint
        : 'common.type_a_value'.i18n,
    focusNode: _focus,
    // Same control fill as the dropdown and the switch row (see
    // `filterControlFill`) — forui's default is `card`, which made this field
    // read as raised while its neighbours read as inset.
    style: filterFieldStyle(context.theme.colors),
    control: FTextFieldControl.managed(controller: _controller),
    onSubmit: (_) => _commit(),
  );
}
