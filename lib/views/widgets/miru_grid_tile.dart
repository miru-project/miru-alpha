import 'package:flutter/material.dart';

class MiruGridTile extends StatefulWidget {
  const MiruGridTile(
      {super.key,
      this.imageUrl,
      required this.title,
      required this.subtitle,
      this.width,
      this.onTap,
      this.height});
  final String? imageUrl;
  final String title;
  final String subtitle;
  final void Function()? onTap;
  final double? height;
  final double? width;
  @override
  State<MiruGridTile> createState() => _MiruGridTileState();
}

class _MiruGridTileState extends State<MiruGridTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _hover = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hover = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: widget.width ?? 200,
          height: widget.height,
          margin: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    boxShadow: _hover
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(widget.imageUrl ?? ''),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(widget.title),
              Text(
                widget.subtitle,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
