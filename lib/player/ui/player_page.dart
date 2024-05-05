import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visualizeit/common/ui/adaptive_container_widget.dart';
import 'package:visualizeit/common/ui/custom_bar_widget.dart';
import 'package:visualizeit/player/ui/player_button_bar.dart';
import 'package:visualizeit/common/ui/base_page.dart';
import 'package:visualizeit/scripting/domain/parser.dart';
import 'package:visualizeit/visualizer/ui/canvas_widget.dart';

import '../../scripting/action.dart';
import '../../scripting/domain/script.dart';
import '../../scripting/domain/script_repository.dart';
import '../domain/player.dart';
import '../domain/player_timer.dart';


class PlayerPage extends StatefulBasePage {
  static const RouteName = "player";

  final GetRawScriptById _getRawScriptById;
  final ScriptParser _scriptParser;
  final ScriptRef scriptId;

  const PlayerPage(GetRawScriptById getRawScriptById, ScriptParser scriptParser, {super.key, required this.scriptId})
      : this._getRawScriptById = getRawScriptById, this._scriptParser = scriptParser, super(RouteName);

  @override
  State<StatefulWidget> createState() {
    return PlayerPageState();
  }
}

class PlayerPageState extends BasePageState<PlayerPage> {

  RawScript? rawScript = null;
  Script? script = null;

  bool graphicalMode = true;
  final PlayerTimer _timer = PlayerTimer();

  @override
  PreferredSizeWidget? buildAppBarBottom(BuildContext context) {

    return customBarWithModeSwitch(
      "> ${script?.metadata.name ?? "unknown"}",
      (bool it) {
        debugPrint("Mode updated: $it");
        setState(() {
          graphicalMode = it;
        });
      },
      (bool it) => it ? "View" : "Exploration",
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final canvas = CanvasWidget();
    final playerButtonBar = buildPlayerButtonBar(context);

    if(script == null) return Container(child: Text("Not ready"));

    final scriptEditor = buildScriptWidget(context, buildButtonBar(context), script!.scenes[0].metadata.rawYaml);

    return graphicalMode
        ? buildPresentationModeContent(context, playerButtonBar, canvas)
        : buildExplorationModeContent(context, playerButtonBar, canvas, scriptEditor);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: widget._getRawScriptById(widget.scriptId),
        builder: (context, snapshot) {
          if(snapshot.hasError) { //TODO
            return Text("Error loading script: ${snapshot.error}");
          }else if (snapshot.hasData) {
            rawScript = snapshot.data!;
            script = widget._scriptParser.parse(rawScript!.contentAsYaml);
            var initialPlayerState = PlayerState(script!);
            return MultiBlocProvider(providers: [
              BlocProvider<PlayerBloc>(create: (context) => PlayerBloc(initialPlayerState)),
            ], child: Builder(builder: (context) => super.build(context)));
          } else
            return CircularProgressIndicator();
        });
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
    var playerBloc = BlocProvider.of<PlayerBloc>(context);

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
          playerBloc.add(RestartPlaybackEvent());
        },
        onPreviousPressed: () {
          playerBloc.add(PreviousTransitionEvent());
        },
        onNextPressed: () {
          playerBloc.add(NextTransitionEvent());
        },
        onPlayPausePressed: () {
          if (!_timer.isInitialized) {
            _timer.init(() {
              playerBloc.add(NextTransitionEvent());
            });
            _timer.start();
            playerBloc.add(StartPlaybackEvent());
          } else {
            if (_timer.toggle()) {
              playerBloc.add(StartPlaybackEvent());
            } else {
              playerBloc.add(StopPlaybackEvent());
            }
          }
        },
      );
    });
  }

  Widget buildPresentationModeContent(BuildContext context, Widget playerButtonBar, Widget canvas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: canvas),
        playerButtonBar
      ],
    );
  }

  Widget buildExplorationModeContent(BuildContext context, Widget playerButtonBar, Widget canvas, Widget scriptEditor) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      AdaptiveContainerWidget(
        children: [
          Expanded(
              flex: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: canvas),
                  playerButtonBar
                ],
              )),
          const Spacer(flex: 2),
          scriptEditor
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
