import 'package:flutter/material.dart';
import 'package:visualizeit/pages/adaptive_container.dart';
import 'package:visualizeit/pages/custom_bar.dart';
import 'package:visualizeit/pages/player_button_bar.dart';

import 'base_page.dart';

class PlayerPage extends StatefulBasePage {
  const PlayerPage({super.key, required this.scriptId, super.onSignInPressed, super.onHelpPressed, super.onExtensionsPressed});

  final String scriptId;

  @override
  State<StatefulWidget> createState() {
    return PlayerPageState();
  }
}


class PlayerPageState extends BasePageState<PlayerPage> {

  bool graphicalMode = true;

  @override
  PreferredSizeWidget? buildAppBarBottom(BuildContext context) {
    return customBarWithModeSwitch(
      "> ${widget.scriptId}",
      (bool it) => {
        debugPrint("Mode updated: $it"),
        setState(() {
          graphicalMode = it;
        })
      },
      (bool it) => it ? "View" : "Script",
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return graphicalMode ? buildPresentationModeContent(context) : buildExplorationModeContent(context);
  }

  ButtonBar buildButtonBar(BuildContext context) {
    return ButtonBar(
      children: [
        TextButton(onPressed: () => {}, child: const Text("Discard")),
        ElevatedButton(onPressed: () => {}, child: const Text("Apply")),
      ],
    );
  }

  PlayerButtonBar buildPlayerButtonBar() {
    return PlayerButtonBar(progress: 0.6,
      onFullscreenPressed: (){
        setState(() {
          super.showAppBar = !super.showAppBar;
        });
      },
    );
  }

  Widget buildPresentationModeContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: Container(
          decoration: BoxDecoration(color: Colors.blue.shade100),
          child: const Center(child: Icon(Icons.play_circle, size: 48,)),
        )),
        buildPlayerButtonBar(),
      ],
    );
  }

  Widget buildExplorationModeContent(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [AdaptiveContainer(

      children: [
        Expanded(
            flex: 100,
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: Container(
              decoration: BoxDecoration(color: Colors.blue.shade100),
              child: const Center(child: Icon(Icons.play_circle, size: 48,)),
            )),
            buildPlayerButtonBar(),
          ],
        )),
        const Spacer(flex: 2),
        buildScriptWidget(context, buildButtonBar(context), scriptExample),
      ],
    )]);
  }

  //TODO replace with Script widget from scripting module
  Expanded buildScriptWidget(BuildContext context, ButtonBar buttonBar, String sampleText) {
    return Expanded(
        flex: 58,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Scene 1 script"),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(15.0),
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(171, 197, 212, 0.3),
                  // borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: Text(sampleText),
                  ),
                ),
              ),
            ),
            buttonBar
          ],
        ));
  }

  static const scriptExample = """
scene A
    description: B+ Tree values manipulation
    tags: data-structure, tree
    fixture
        btree TD
          # nodeId(/parentNodeId)? : level : (value(->childNodeId)?)(,value(->childNodeId)?)+
          P1 : 2 : 1 -> P1.1, 7 -> P1.2
          P1.1/P1 : 1 : 1 -> P1.1.1, 3 -> P1.1.2, 5 -> P1.1.3
          P1.2/P1 : 1 : 7 -> P1.2.1, 9 -> P1.2.2
          P1.1.1/P1.1 : 0 : 1,2
          P1.1.2/P1.1 : 0 : 3,4
          P1.1.3/P1.2 : 0 : 5,6
          P1.2.1/P1.2 : 0 : 7,8
          P1.2.2/P1.3 : 0 : 9,10,11,12
    transitions
        Add node value 13 (1s)
        Add node value 14 (1s)
        Delete node value 13
""";
}

