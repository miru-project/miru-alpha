import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:forui/forui.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/widgets/amination/animated_box.dart';
import 'package:miru_app_new/widgets/core/image_widget.dart';

class DesktopDetailImageView extends StatelessWidget {
  final ExtensionDetail detail;
  final String coverUrl;
  const DesktopDetailImageView({
    super.key,
    required this.detail,
    required this.coverUrl,
  });
  @override
  Widget build(BuildContext context) {
    return AnimatedBox(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder<void>(
            opaque: false,
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (context, animation, secondaryAnimation) => FScaffold(
              scaffoldStyle: (style) => style.copyWith(
                backgroundColor: context.theme.colors.background.withAlpha(100),
              ),
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(color: Colors.transparent),
                  ),
                  Center(
                    child: Hero(
                      tag: 'search-card',
                      child: ExtendedImage.network(
                        mode: .gesture,
                        coverUrl,
                        initGestureConfigHandler: (state) {
                          return GestureConfig(
                            minScale: 0.9,
                            animationMinScale: 0.7,
                            maxScale: 3.0,
                            animationMaxScale: 3.5,
                            speed: 1.0,
                            inertialSpeed: 100.0,
                            initialScale: 1.0,
                            inPageView: false,
                            initialAlignment: InitialAlignment.center,
                          );
                        },
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      child: Hero(
        tag: 'search-card',
        child: FCard.raw(
          child: ClipRRect(
            // borderRadius: BorderRadius.circular(),
            child: ImageWidget.defaultErr(
              title: detail.title,
              imageUrl: coverUrl,
            ),
          ),
        ),
      ),
    );
  }
}
