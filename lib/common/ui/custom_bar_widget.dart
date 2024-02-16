import 'package:flutter/material.dart';
import 'package:visualizeit/common/utils/extensions.dart';

PreferredSizeWidget? customBarWithModeSwitch(String title, ValueChanged<bool> onModeChanged, String Function(bool) getModeName,
    {IconData titleActionIcon = Icons.edit, VoidCallback? onTitleActionIconPressed}) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(70.0),
    child: CustomBarWidget(
      title: title,
      onModeChanged: onModeChanged,
      getModeName: getModeName,
      titleActionIcon: titleActionIcon,
      onTitleActionIconPressed: onTitleActionIconPressed,
    ),
  );
}

class CustomBarWidget extends StatefulWidget {
  const CustomBarWidget(
      {super.key,
      required this.title,
      this.titleActionIcon = Icons.edit,
      this.onTitleActionIconPressed,
      required this.onModeChanged,
      required this.getModeName});

  final String title;
  final IconData titleActionIcon;
  final VoidCallback? onTitleActionIconPressed;
  final ValueChanged<bool> onModeChanged;
  final String Function(bool) getModeName;

  @override
  State<StatefulWidget> createState() {
    return _CustomBarContent();
  }
}

class _CustomBarContent extends State<CustomBarWidget> {
  bool switchValue = true;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(15),
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: <Color>[Colors.lightBlue, Colors.lightGreenAccent]),
            borderRadius: BorderRadius.all(Radius.circular(5))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: <Widget?>[
                  LimitedBox(
                      maxWidth: MediaQuery.sizeOf(context).width - (widget.onTitleActionIconPressed == null ? 120 : 160),
                      child: Text(widget.title, softWrap: true, maxLines: 3)),
                  widget.onTitleActionIconPressed?.let((action) => IconButton(
                      onPressed: action,
                      icon: const Icon(
                        Icons.edit,
                        size: 16,
                      ))),
                  const Spacer(),
                  Text("${widget.getModeName(switchValue)}\nmode", style: const TextStyle(fontSize: 12), textAlign: TextAlign.left),
                  const SizedBox(width: 5),
                  SizedBox(
                      width: 40,
                      child: Transform.scale(
                          scale: 0.7, // Adjust the scale factor as needed
                          child: Switch(
                              value: switchValue,
                              onChanged: (bool value) => {setState(() => switchValue = value), widget.onModeChanged(value)}))),
                ].nonNulls.toList(),
              ),
            ),
          ],
        ));
  }
}
