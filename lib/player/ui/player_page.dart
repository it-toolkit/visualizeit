import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visualizeit/common/ui/adaptive_container_widget.dart';
import 'package:visualizeit/common/ui/buttons.dart';
import 'package:visualizeit/common/ui/custom_bar_widget.dart';
import 'package:visualizeit/common/utils/extensions.dart';
import 'package:visualizeit/player/ui/player_button_bar.dart';
import 'package:visualizeit/common/ui/base_page.dart';
import 'package:visualizeit/scripting/domain/parser.dart';
import 'package:visualizeit/visualizer/ui/canvas_widget.dart';

import '../../extension/domain/extension_repository.dart';
import '../../scripting/action.dart';
import '../../scripting/domain/script.dart';
import '../../scripting/domain/script_repository.dart';
import '../../scripting/ui/script_editor_widget.dart';
import '../domain/player.dart';
import '../domain/player_timer.dart';


class PlayerPage extends StatefulBasePage {
  static const RouteName = "player";

  final GetRawScriptById _getRawScriptById;
  final ScriptParser _scriptParser;
  final ScriptRef scriptId;
  final ExtensionRepository _extensionRepository;
  final bool readOnly;

  const PlayerPage(GetRawScriptById getRawScriptById, ScriptParser scriptParser, ExtensionRepository extensionRepository,
      {super.key, required this.scriptId, this.readOnly = false })
      : this._getRawScriptById = getRawScriptById,
        this._scriptParser = scriptParser,
        this._extensionRepository = extensionRepository,
        super(RouteName);

  @override
  State<StatefulWidget> createState() {
    return PlayerPageState();
  }
}

class PlayerPageState extends BasePageState<PlayerPage> {

  RawScript? rawScript = null;
  Script? script = null;
  String? currentEditorText = null;
  bool scriptHasChanges = false;

  bool graphicalMode = true;
  final PlayerTimer _timer = PlayerTimer();

  @override
  void dispose() {
    _timer.stop();
    super.dispose();
  }

  @override
  PreferredSizeWidget? buildAppBarBottom(BuildContext context) {
    return customBarWithModeSwitch(
      "${script?.metadata.name ?? "Unknown script name"}${ widget.readOnly ? " <read only>": ""}",
      modeSwitch: ModeSwitch(
        initialState: graphicalMode,
        enabledModeName: "View",
        disabledModeName: "Exploration",
        onModeChanged: (bool enabled) => setState(() => graphicalMode = enabled),
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final canvas = CanvasWidget();
    final playerButtonBar = buildPlayerButtonBar(context);

    if(script == null) return Container(child: Text("Not ready"));

    final scriptEditor = buildScriptWidget(context, buildButtonBar(context), script!, rawScript!);//TODO script!.scenes[0].metadata.rawYaml);

    return graphicalMode
        ? buildPresentationModeContent(context, playerButtonBar, canvas)
        : buildExplorationModeContent(context, playerButtonBar, canvas, scriptEditor);
  }

  Future<RawScript> resolveRawScript() async {
    if(rawScript == null){
      rawScript = (await widget._getRawScriptById(widget.scriptId)).clone();
    }

    if (currentEditorText == null) {
      currentEditorText = rawScript!.contentAsYaml;
    }
    script = widget._scriptParser.parse(rawScript!.contentAsYaml);

    return Future.value(rawScript);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: resolveRawScript(),
        builder: (context, snapshot) {
          if(snapshot.hasError) { //TODO
            return Text("Error loading script: ${snapshot.error}");
          }else if (snapshot.hasData) {
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
        Buttons.icon(Icons.cancel_outlined, "Discard changes", action: scriptHasChanges ? () {
            setState(() {
              currentEditorText = rawScript!.contentAsYaml;
              scriptHasChanges = false;
            });
        } : null),
        Buttons.highlightedIcon(
          Icons.check_circle_outline,
          "Apply",
          action: scriptHasChanges ? () {
            setState(() {
              rawScript!.contentAsYaml = currentEditorText!;
              script = widget._scriptParser.parse(currentEditorText!);
              BlocProvider.of<PlayerBloc>(context).add(OverrideEvent(PlayerState(script!)));
              scriptHasChanges = false;
            });
          } : null,
        ),
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
          playerBloc.add(NextTransitionEvent(timeFrame: _timer.frameDuration));
        },
        onPlayPausePressed: () {
          if (!_timer.isInitialized) {
            _timer.init(() {
              playerBloc.add(NextTransitionEvent(timeFrame: _timer.frameDuration));
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
        onSpeedChanged: (speedFactor) {
          _timer.changeSpeed(speedFactor);
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

  Widget buildScriptWidget(BuildContext context, ButtonBar buttonBar, Script script, RawScript rawScript) {
      return Expanded(
          flex: 58,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BlocBuilder<PlayerBloc, PlayerState>(builder: (context, playerState) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Scene #${playerState.currentSceneIndex + 1}"),
                    Text("Playing line: ${playerState.currentCommand?.metadata?.scriptLineIndex.let((it) => it+1) ?? "?"}")
                  ],
                );
              }),
              Expanded(
                child: ScriptEditorWidget(
                  script: rawScript.contentAsYaml,
                  readOnly: false,
                  availableExtensions: widget._extensionRepository.getAll(),
                  listenPlayerEvents: true,
                  onCodeChange: (String text ) {
                    currentEditorText = text;
                    if (!scriptHasChanges) setState(() {
                      scriptHasChanges = true;
                    });
                  },
                ),
              ),
              buttonBar
            ],
          ));
    // });
  }
}
