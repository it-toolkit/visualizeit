import 'package:flutter/material.dart';

class TagsWidget extends StatefulWidget {
  const TagsWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return _TagsState();
  }
}

class _TagsState extends State<TagsWidget> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 5,
      spacing: 5,
      children: [
        const Text("Tags"),
        IconButton(
          onPressed: () => {},
          icon: const Icon(Icons.add_circle_outline),
          tooltip: "Add",
          iconSize: 20,
        ),
        buildChip("tag-1", () => {}),
        buildChip("tag-2", () => {}),
        buildChip("tag-3", () => {}),
      ],
    );
  }

  Chip buildChip(String label, VoidCallback? onDeleted) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 10)),
      backgroundColor: Colors.orangeAccent,
      side: BorderSide.none,
      onDeleted: onDeleted,
    );
  }
}
