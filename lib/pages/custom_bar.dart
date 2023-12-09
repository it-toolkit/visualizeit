import 'package:flutter/material.dart';

PreferredSizeWidget? customBarWithModeSwitch(String title, ValueChanged<bool> onModeChanged, String Function(bool) getModeName) {
  return PreferredSize(
      preferredSize: const Size.fromHeight(70.0),
      child: CustomBarWidget(title: title, onModeChanged: onModeChanged, getModeName: getModeName),
  );
}

class CustomBarWidget extends StatefulWidget {
  const CustomBarWidget({super.key, required this.title, required this.onModeChanged, required this.getModeName});

  final String title;
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
                children: <Widget>[
                  LimitedBox(maxWidth: MediaQuery.sizeOf(context).width - 170, child:  Text(widget.title, softWrap: true,maxLines: 3,)),
                  const Spacer(),
                  Text("${widget.getModeName(switchValue)}\nmode", style: const TextStyle(fontSize: 12),),
                  Switch(value: switchValue, onChanged: (bool value) => {setState(() => switchValue = value), widget.onModeChanged(value)}),
                ],
              ),
            ),
          ],
        ));
  }
}
