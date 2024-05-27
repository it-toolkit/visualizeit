import 'package:flutter/material.dart';
import 'package:visualizeit/common/utils/extensions.dart';

class ModeSwitch {
  bool initialState = false;
  String enabledModeName;
  String disabledModeName;
  ValueChanged<bool> onModeChanged;

  ModeSwitch({required this.initialState, required this.enabledModeName, required this.disabledModeName, required this.onModeChanged});

  String getModeName(bool isEnabled) {
    return isEnabled ? enabledModeName : disabledModeName;
  }
}

class TitleAction {
  IconData icon = Icons.edit;
  VoidCallback? onPressed;

  TitleAction(this.icon, this.onPressed);
}

PreferredSizeWidget? customBarWithModeSwitch(String title, { ModeSwitch? modeSwitch = null, TitleAction? titleAction = null }) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(70.0),
    child: CustomBarWidget(title: title, modeSwitch: modeSwitch, titleAction: titleAction),
  );
}

class CustomBarWidget extends StatefulWidget {

  const CustomBarWidget({super.key,required this.title, this.titleAction, this.modeSwitch});

  final String title;
  final TitleAction? titleAction;
  final ModeSwitch? modeSwitch;

  @override
  State<StatefulWidget> createState() {
    return _CustomBarContent();
  }
}

class _CustomBarContent extends State<CustomBarWidget> {
  late bool switchValue;

  @override
  void initState() {
    switchValue = widget.modeSwitch?.initialState ?? false;
    super.initState();
  }

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
                    maxWidth: MediaQuery.sizeOf(context).width - (widget.titleAction == null ? 120 : 160),
                    child: Text(widget.title, softWrap: true, maxLines: 3),
                  ),
                  widget.titleAction?.let((action) => IconButton(
                      onPressed: action.onPressed,
                      icon: Icon(action.icon,size: 16
                      ))),
                  const Spacer(),
                  widget.modeSwitch?.let((modeSwitch) => Text(
                    "${modeSwitch.getModeName(switchValue)}\nmode",
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.left)),
                  SizedBox(height: 40, width: 5),
                  widget.modeSwitch?.let((modeSwitch) =>
                    SizedBox(
                      width: 40,
                      child: Transform.scale(
                        scale: 0.7, // Adjust the scale factor as needed
                        child: Switch(
                          value: switchValue,
                          onChanged: (bool value) => {setState(() => switchValue = value), modeSwitch.onModeChanged(value)},
                      )))),
                ].nonNulls.toList(),
              ),
            ),
          ],
        ));
  }
}
