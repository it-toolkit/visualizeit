import 'package:flutter/material.dart';
import 'package:visualizeit/common/utils/extensions.dart';

const double AppBarHeight = 55;
const double AppDefaultMargin = 15;
final EdgeInsets AppBarMargin = const EdgeInsets.fromLTRB(AppDefaultMargin, 0, AppDefaultMargin, AppDefaultMargin);
final AppBarBoxDecoration = BoxDecoration(
    gradient: LinearGradient(colors: <Color>[Colors.lightBlue.shade100, Colors.lightGreenAccent.shade100]),
    borderRadius: BorderRadius.all(Radius.circular(5)),
);

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
  String? tooltip;

  TitleAction(this.icon, this.onPressed, {this.tooltip});
}

PreferredSizeWidget? customBarWithModeSwitch(String title, { ModeSwitch? modeSwitch = null, TitleAction? titleAction = null }) {
  return PreferredSize(
    preferredSize: Size.fromHeight(AppBarHeight),
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
        margin: AppBarMargin,
        decoration: AppBarBoxDecoration,
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
                  widget.titleAction?.let((action) => IconButton(onPressed: action.onPressed, icon: Icon(action.icon,size: 16), tooltip: action.tooltip)),
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
