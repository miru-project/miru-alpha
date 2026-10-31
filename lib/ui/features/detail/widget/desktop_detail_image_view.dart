import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/utils/http/request.dart';
import 'package:extended_image/extended_image.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/ui/core/widget/miru_card.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/ui/core/amination/animated_box.dart';
import 'package:miru_alpha/ui/core/core/image_widget.dart';

class DetailImageView extends StatelessWidget {
  final Detail detail;
  final String coverUrl;
  final Widget? child;
  const DetailImageView({
    super.key,
    required this.detail,
    required this.coverUrl,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBox.nopadding(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder<void>(
            opaque: false,
            transitionDuration: const Duration(milliseconds: 350),
            pageBuilder: (context, animation, secondaryAnimation) =>
                _DetailImageViewerPage(coverUrl: coverUrl),
          ),
        );
      },
      child: Hero(
        tag: 'detail-card',
        child: MiruCard(
          style: .delta(
            decoration: .boxDelta(borderRadius: BorderRadius.circular(10)),
          ),
          child:
              child ??
              ImageWidget.defaultErr(title: detail.title, imageUrl: coverUrl),
        ),
      ),
    );
  }
}

/// Full-screen zoomable cover viewer: translucent page behind, the art
/// contained in the middle, pinch/pan/double-tap on the art, and a tap on
/// the transparent area around it pops the route.
class _DetailImageViewerPage extends StatefulWidget {
  const _DetailImageViewerPage({required this.coverUrl});

  final String coverUrl;

  @override
  State<_DetailImageViewerPage> createState() => _DetailImageViewerPageState();
}

class _DetailImageViewerPageState extends State<_DetailImageViewerPage> {
  /// Intrinsic aspect (w/h) of the loaded image, captured from the image
  /// state so the tap layer can tell the painted art from the letterbox.
  double? _imageAspect;

  /// The contain-fit rect the un-zoomed art paints into inside [box].
  Rect? _containRect(Size box) {
    final aspect = _imageAspect;
    if (aspect == null || aspect <= 0) return null;
    final height = box.width / aspect;
    if (height <= box.height) {
      return Rect.fromLTWH(0, (box.height - height) / 2, box.width, height);
    }
    final width = box.height * aspect;
    return Rect.fromLTWH((box.width - width) / 2, 0, width, box.height);
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      childPad: false,
      scaffoldStyle: .delta(
        backgroundColor: context.theme.colors.background.withAlpha(200),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: 'detail-card',
            flightShuttleBuilder:
                (flightContext, animation, direction, fromContext, toContext) {
                  return AnimatedBuilder(
                    animation: animation,
                    builder: (context, child) {
                      return Material(
                        color: Colors.transparent,
                        clipBehavior: Clip.antiAlias,
                        borderRadius: BorderRadius.circular(10),
                        child: child,
                      );
                    },
                    child: (direction == HeroFlightDirection.push)
                        ? toContext.widget
                        : fromContext.widget,
                  );
                },
            // No clip here: the gesture image's zoomed paint must overflow
            // this box instead of being cropped to it — the hero flight
            // shuttle carries the rounded clip.
            child: Material(
              color: Colors.transparent,
              child: ExtendedImage.network(
                MiruRequest.proxyUrl(widget.coverUrl).toString(),
                retries: 1,
                mode: .gesture,
                initGestureConfigHandler: (state) => GestureConfig(
                  minScale: 0.9,
                  animationMinScale: 0.7,
                  maxScale: 3.0,
                  animationMaxScale: 3.5,
                  speed: 1.0,
                  inertialSpeed: 100.0,
                  initialScale: 1.0,
                  inPageView: false,
                  initialAlignment: InitialAlignment.center,
                ),
                fit: BoxFit.contain,
                loadStateChanged: (state) {
                  final image = state.extendedImageInfo?.image;
                  if (image != null) {
                    _imageAspect = image.width / image.height;
                  }
                  return null;
                },
              ),
            ),
          ),
          // Top tap layer: pops only when the tap lands on the transparent
          // area outside the painted art — translucent, so pinch / pan /
          // double-tap still reach the image's own recognizers below.
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapUp: (details) {
              final box = context.size;
              final artRect = box == null ? null : _containRect(box);
              if (artRect == null || !artRect.contains(details.localPosition)) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}
