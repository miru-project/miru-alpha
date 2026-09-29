import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/provider/search/search_page_single_provider.dart';

/// Filter labels rendered inline before the rest collapse into a `+N` badge.
const int kMaxFilterSummaryLabels = 2;

/// Share of the screen width the summary may claim.
///
/// The header row also holds the back button and the extension title, and it
/// hands non-flex children an unbounded width. Without a cap the summary takes
/// every pixel it wants, squeezing the title to zero width and tripping a
/// RenderFlex overflow.
const double _summaryMaxWidthFactor = 0.5;

/// Tappable summary of the active filters on the `/search/single` header.
///
/// Shows the first [kMaxFilterSummaryLabels] labels and, when more filters are
/// active, a trailing `+N` badge with the hidden count. A single [Row] keeps
/// the summary on the header's one 50px line; labels ellipsize rather than
/// pushing the title out of the row.
class MobileFilterSummaryChip extends ConsumerWidget {
  const MobileFilterSummaryChip({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterSummary = ref.watch(
      searchPageSingleProviderProvider.select((s) => s.filterSummary),
    );
    if (filterSummary.isEmpty) return const SizedBox.shrink();

    final labels = filterSummary.take(kMaxFilterSummaryLabels).toList();
    final hiddenCount = filterSummary.length - labels.length;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * _summaryMaxWidthFactor,
      ),
      child: FTappable(
        onPress: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final label in labels) ...[
              Flexible(child: _SummaryBadge(label: label)),
              const SizedBox(width: 4),
            ],
            if (hiddenCount > 0) _SummaryBadge(label: '+$hiddenCount'),
          ],
        ),
      ),
    );
  }
}

class _SummaryBadge extends StatelessWidget {
  const _SummaryBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return FBadge(
      child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}
