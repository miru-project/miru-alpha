import 'package:flutter/material.dart';
import 'package:miru_app_new/views/widgets/button.dart';

class ExtensionListTile extends StatefulWidget {
  const ExtensionListTile({
    super.key,
    required this.name,
    this.icon,
    required this.version,
    required this.author,
    required this.type,
    required this.onUninstall,
  });
  final String name;
  final String? icon;
  final String version;
  final String author;
  final String type;
  final void Function() onUninstall;

  @override
  State<ExtensionListTile> createState() => _ExtensionListTileState();
}

class _ExtensionListTileState extends State<ExtensionListTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                if (widget.icon != null)
                  Image.network(
                    widget.icon!,
                    width: 50,
                    height: 50,
                  ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      widget.author,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: Text(
              widget.version,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              widget.type,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          Button(
            onPressed: widget.onUninstall,
            child: const Text('Uninstall'),
          ),
        ],
      ),
    );
  }
}

class ExtensionGridTile extends StatelessWidget {
  const ExtensionGridTile({
    super.key,
    required this.name,
    this.icon,
    required this.version,
    required this.author,
    required this.type,
    this.description,
    required this.onInstall,
  });
  final String name;
  final String? icon;
  final String version;
  final String author;
  final String type;
  final String? description;
  final void Function() onInstall;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.black12,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (icon != null)
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(icon!),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name),
                          Text(
                            author,
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description ?? 'No description',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  version,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                Button(
                  onPressed: onInstall,
                  child: const Text('Install'),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
