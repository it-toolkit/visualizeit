import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visualizeit/common/ui/adaptive_container_widget.dart';
import 'package:visualizeit/common/ui/custom_bar_widget.dart';
import 'package:visualizeit/player/ui/player_button_bar.dart';
import 'package:visualizeit/common/ui/base_page.dart';
import 'package:visualizeit/visualizer/ui/canvas_widget.dart';

import '../../extension/domain/action.dart';
import '../../fake_data.dart';
import '../../scripting/domain/parser.dart';
import '../domain/player.dart';

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
      "> ${fakeScriptNames[int.tryParse(widget.scriptId) ?? 0]}",
      (bool it) => {
        debugPrint("Mode updated: $it"),
        setState(() {
          graphicalMode = it;
        })
      },
      (bool it) => it ? "View" : "Exploration",
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return graphicalMode ? buildPresentationModeContent(context) : buildExplorationModeContent(context);
  }

  @override
  Widget build(BuildContext context) {
    //TODO parse real script
    const validRawScriptYaml = """
      name: "Flow diagram example"
      description: |
        ## Example of flow diagram usage
        This script builds a simple flow diagram and adds some components 
      tags: [data-structure, example]
      scenes:
        - name: Scene name
          extensions: []
          description: Initial scene description
          initial-state:
            - nop
            - nop
          transitions:
            - nop
            - nop
            - show-message: "Showing a nice message"
            - show-message: "Goodbye!"
    """;
    var initialPlayerState = PlayerState(ScriptParser(GetExtensionById()).parse(validRawScriptYaml));

    return BlocProvider(
        create: (context) => PlayerBloc(initialPlayerState),
        child: Builder(builder: (context) => super.build(context))
    );
  }

  ButtonBar buildButtonBar(BuildContext context) {
    return ButtonBar(
      children: [
        TextButton(onPressed: () => {}, child: const Text("Discard")),
        ElevatedButton(onPressed: () => {}, child: const Text("Apply")),
      ],
    );
  }

  PlayerButtonBar buildPlayerButtonBar(BuildContext context) {
    return PlayerButtonBar(
      progress: 0.6,
      onFullscreenPressed: () {
        setState(() {
          super.showAppBar = !super.showAppBar;
        });
      },
      onNextPressed: () {
        BlocProvider.of<PlayerBloc>(context).add(AdvanceEvent());
      }
    );
  }

  Widget buildPresentationModeContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Expanded(child: CanvasWidget()),
        buildPlayerButtonBar(context),
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
                  buildPlayerButtonBar(context),
                ],
              )),
          const Spacer(flex: 2),
          buildScriptWidget(context, buildButtonBar(context), fakeSceneScriptExample),
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
                decoration: BoxDecoration(color: Colors.blue.shade50),
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
}
