import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visualizeit/common/ui/adaptive_container_widget.dart';
import 'package:visualizeit/common/ui/custom_bar_widget.dart';
import 'package:visualizeit/player/ui/player_button_bar.dart';
import 'package:visualizeit/common/ui/base_page.dart';
import 'package:visualizeit/visualizer/ui/canvas_widget.dart';

import '../../scripting/domain/script.dart';
import '../domain/player.dart';
import '../domain/player_timer.dart';


class PlayerPage extends StatefulBasePage {
  const PlayerPage({super.key, required this.script, super.onSignInPressed, super.onHelpPressed, super.onExtensionsPressed});

  final Script script;

  @override
  State<StatefulWidget> createState() {
    return PlayerPageState();
  }
}

class PlayerPageState extends BasePageState<PlayerPage> {
  bool graphicalMode = true;
  final PlayerTimer _timer = PlayerTimer();

  @override
  PreferredSizeWidget? buildAppBarBottom(BuildContext context) {
    return customBarWithModeSwitch(
      "> ${widget.script.metadata.name}",
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
    var initialPlayerState = PlayerState(widget.script);

    return MultiBlocProvider(
        providers: [
          BlocProvider<PlayerBloc>(create: (context) => PlayerBloc(initialPlayerState)),
        ],
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

  Widget buildPlayerButtonBar(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(builder: (context, playerState) {
      if (playerState.isPlaying != _timer.running) _timer.toggle();

      return PlayerButtonBar(
        progress: playerState.progress,
        isPlaying: playerState.isPlaying,
        onFullscreenPressed: () {
          setState(() {
            super.showAppBar = !super.showAppBar;
          });
        },
        onRestartPressed: () {
          _timer.pause();
          BlocProvider.of<PlayerBloc>(context).add(RestartPlaybackEvent());
        },
        onPreviousPressed: () {
          BlocProvider.of<PlayerBloc>(context).add(PreviousTransitionEvent());
        },
        onNextPressed: () {
          BlocProvider.of<PlayerBloc>(context).add(NextTransitionEvent());
        },
        onPlayPausePressed: () {
          if (!_timer.isInitialized) {
            _timer.init(() {
              BlocProvider.of<PlayerBloc>(context).add(NextTransitionEvent());
            });
            _timer.start();
            BlocProvider.of<PlayerBloc>(context).add(StartPlaybackEvent());
          } else {
            if (_timer.toggle()) {
              BlocProvider.of<PlayerBloc>(context).add(StartPlaybackEvent());
            } else {
              BlocProvider.of<PlayerBloc>(context).add(StopPlaybackEvent());
            }
          }
        },
      );
    });
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
          buildScriptWidget(context, buildButtonBar(context), widget.script.scenes[0].metadata.rawYaml),//TODO choose current scene
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
