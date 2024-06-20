import 'package:flutter/material.dart';

const _fakeSelectedTags = ["database"];

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
        buildChip(_fakeSelectedTags[0], () => {}),
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
