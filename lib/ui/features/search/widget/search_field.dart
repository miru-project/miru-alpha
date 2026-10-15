import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// The one mobile search-bar look, built on forui's [FTextField]:
/// card surface, `borderRadius.md` corners, `colors.border` outline, a search
/// glyph in the prefix and forui's own clear button. Every mobile surface that
/// searches — the `/search/input` page, the Library bar, the tab's tap target —
/// renders through these two helpers so they cannot drift apart again.
Widget searchField({
  required TextEditingController controller,
  FocusNode? focusNode,
  required ValueChanged<String> onSubmit,
  ValueChanged<String>? onChange,
  bool autofocus = false,
  String? hint,
}) => FTextField(
  autofocus: autofocus,
  focusNode: focusNode,
  maxLines: 1,
  clearable: (value) => value.text.isNotEmpty,
  control: FTextFieldControl.managed(
    controller: controller,
    onChange: onChange == null ? null : (value) => onChange(value.text),
  ),
  textInputAction: .search,
  hint: hint ?? 'extension.search_hint'.i18n,
  onSubmit: onSubmit,
  prefixBuilder: (context, style, states) => Padding(
    padding: const EdgeInsets.only(left: 12, right: 8),
    child: Icon(FLucideIcons.search, size: 17),
  ),
);

/// The same bar as a tap target: identical surface, corners and hint, but
/// tapping it opens `/search/input` instead of accepting text — for the tab
/// that keeps only the source list.
class SearchFieldStub extends StatelessWidget {
  const SearchFieldStub({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return FTappable(
      onPress: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: context.theme.style.borderRadius.md,
          border: Border.all(color: colors.border, width: 1),
        ),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Icon(FLucideIcons.search, size: 17, color: colors.mutedForeground),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'extension.search_hint'.i18n,
                style: context.theme.typography.body.sm.copyWith(
                  color: colors.mutedForeground,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
