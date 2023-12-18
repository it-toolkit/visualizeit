import 'package:flutter/material.dart';
import 'package:visualizeit/common/ui/adaptive_container_widget.dart';
import 'package:visualizeit/common/ui/custom_bar_widget.dart';
import 'package:visualizeit/player/ui/player_button_bar.dart';
import 'package:visualizeit/common/ui/base_page.dart';
import 'package:visualizeit/visualizer/ui/canvas_widget.dart';

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
    return PlayerButtonBar(
      progress: 0.6,
      onFullscreenPressed: () {
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
        const Expanded(child: CanvasWidget()),
        buildPlayerButtonBar(),
      ],
    );
  }

  Widget buildExplorationModeContent(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      AdaptiveContainerWidget(
        children: [
          Expanded(
              flex: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Expanded(child: CanvasWidget()),
                  buildPlayerButtonBar(),
                ],
              )),
          const Spacer(flex: 2),
          buildScriptWidget(context, buildButtonBar(context), scriptExample),
        ],
      )
    ]);
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
