import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:re_editor/re_editor.dart';
import 'package:visualizeit/common/ui/adaptive_container_widget.dart';
import 'package:visualizeit/common/ui/buttons.dart';
import 'package:visualizeit/common/ui/custom_bar_widget.dart';
import 'package:visualizeit/common/ui/future_builder.dart';
import 'package:visualizeit/common/utils/extensions.dart';
import 'package:visualizeit/extension/domain/default/default_extension.dart';
import 'package:visualizeit/player/ui/player_button_bar.dart';
import 'package:visualizeit/common/ui/base_page.dart';
import 'package:visualizeit/scripting/domain/parser.dart';
import 'package:visualizeit/scripting/ui/script_errors_widget.dart';
import 'package:visualizeit/visualizer/ui/canvas_widget.dart';
import 'package:visualizeit_extensions/logging.dart';

import '../../extension/domain/extension_repository.dart';
import '../../scripting/domain/script.dart';
import '../../scripting/domain/script_repository.dart';
import '../../scripting/ui/script_editor_widget.dart';
import '../domain/player.dart';
import '../domain/player_timer.dart';


final _logger = Logger("player.ui.player_page");

class PlayerPage extends StatefulBasePage {
  static const RouteName = "player";

  final ScriptRepository _scriptRepository;
  final ScriptParser _scriptParser;
  final ScriptRef scriptId;
  final ExtensionRepository _extensionRepository;
  final bool readOnly;

  const PlayerPage(ScriptRepository scriptRepository, ScriptParser scriptParser, ExtensionRepository extensionRepository,
      {super.key, required this.scriptId, this.readOnly = false })
      : this._scriptRepository = scriptRepository,
        this._scriptParser = scriptParser,
        this._extensionRepository = extensionRepository,
        super(RouteName);

  @override
  State<StatefulWidget> createState() {
    return PlayerPageState();
  }
}

class PlayerPageState extends BasePageState<PlayerPage> {

  ValidScript? script = null;
  bool scriptHasChanges = false;
  ParserException? scriptErrors = null;
  Set<String> referencedExtensionIds = { DefaultExtensionConsts.Id };
  bool graphicalMode = true;
  final PlayerTimer _timer = PlayerTimer();

  final CodeScrollController codeScrollController = CodeScrollController();
  final CodeLineEditingController codeController = CodeLineEditingController();

  @override
  void dispose() {
    _timer.stop();
    super.dispose();
  }

  @override
  PreferredSizeWidget? buildAppBarBottom(BuildContext context) {
    return customBarWithModeSwitch(
      "${script?.metadata.name ?? "Unknown script name"}",
      titleAction:  widget.readOnly ? TitleAction(Icons.edit_off_outlined, null, tooltip: "Read only script"): null,
      modeSwitch: ModeSwitch(
        initialState: graphicalMode,
        enabledModeName: "Presentation\nmode",
        disabledModeName: "Exploration\nmode",
        onModeChanged: (bool enabled) => setState(() => graphicalMode = enabled),
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final canvas = Container(child: CanvasWidget(widget._extensionRepository), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),);
    final playerButtonBar = buildPlayerButtonBar(context);

    if(script == null) return Container(child: Text("Not ready"));

    final scriptEditor = _buildExplorationPanel(context, buildButtonBar(context));

    return graphicalMode
        ? buildPresentationModeContent(context, playerButtonBar, canvas)
        : buildExplorationModeContent(context, playerButtonBar, canvas, scriptEditor);
  }

  String _resolveScriptYamlContent(Script script) => script.preProcessed?.contentAsYaml ?? script.raw.contentAsYaml;

  Future<Script> resolveScript() async {
    if(script == null){
      script = (await widget._scriptRepository.get(widget.scriptId)).clone() as ValidScript;
      codeController.text = _resolveScriptYamlContent(script!);
    }

    return Future.value(script);
  }

  @override
  Widget build(BuildContext context) {
    return WidgetFutureUtils.awaitAndBuild<Script>(
        future: resolveScript(),
        builder: (context, script) {
            var initialPlayerState = PlayerState(script as ValidScript);
            return MultiBlocProvider(
                providers: [BlocProvider<PlayerBloc>(create: (context) => PlayerBloc(initialPlayerState))],
                child: BlocListener<PlayerBloc, PlayerState>(
                   listener: (context, state) {
                     _timer.baseFrameDurationInMillis = state.baseFrameDurationInMillis;
                   },
                   child: Builder(builder: (context) => super.build(context)),
                ),
            );
        });
  }

  ButtonBar buildButtonBar(BuildContext context) {
    return ButtonBar(
      children: [
        Buttons.icon(Icons.cancel_outlined, "Discard changes", action: scriptHasChanges ? () {
            setState(() {
              codeController.text = _resolveScriptYamlContent(script!);
              scriptHasChanges = false;
            });
        } : null),
        Buttons.highlightedIcon(
          Icons.check_circle_outline,
          "Apply",
          action: scriptHasChanges ? () {
            try {
              final parsedScript = widget._scriptParser.parse(script!.raw.copyWith(contentAsYaml: codeController.text));
              if (parsedScript is InvalidScript) throw parsedScript.parserError;

              setState(() {
                var validScript = parsedScript as ValidScript;
                script = validScript;
                if (script!.preProcessed != null) codeController.text = _resolveScriptYamlContent(script!);
                BlocProvider.of<PlayerBloc>(context).add(OverrideEvent(PlayerState(validScript)));
                scriptHasChanges = false;
              });
            } on ParserException catch (e) {
              _logger.warn(() {
                final buffer = StringBuffer("Apply aborted due ${e.causes.length} errors: \n");
                e.errorMessages.forEach((errorMessage) => buffer.writeln("\t$errorMessage"));
                return buffer.toString();
              });
            }
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
        onScaleChanged: (scale) {
          playerBloc.add(SetCanvasScaleEvent(scale));
        },
        baseFrameDurationMillis: playerState.baseFrameDurationInMillis,
        speedFactor: _timer.speedFactor,
        scale: playerState.canvasScale,
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

  Widget _buildExplorationPanel(BuildContext context, ButtonBar buttonBar) {
      return Expanded(
          flex: 58,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildExplorationPanelHeader(),
              Expanded(child: _buildScriptEditorWidget()),
              if (scriptErrors != null) ScriptErrorWidget(scriptErrors),
              buttonBar
            ],
          ));
    // });
  }

  BlocBuilder<PlayerBloc, PlayerState> _buildExplorationPanelHeader() {
    return BlocBuilder<PlayerBloc, PlayerState>(builder: (context, playerState) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Scene #${playerState.currentSceneIndex + 1}"),
                  Text("Playing line: ${playerState.currentCommand?.metadata?.scriptLineIndex.let((it) => it+1) ?? "?"}")
                ],
              );
            });
  }

  ScriptEditorWidget _buildScriptEditorWidget() {
    return ScriptEditorWidget(
      controller: codeController,
      scrollController: codeScrollController,
      readOnly: false,
      availableExtensions: widget._extensionRepository.getAll(),
      referencedExtensionIds: referencedExtensionIds,
      listenPlayerEvents: true,
      onCodeChange: _monitorScriptChangesAndErrors,
    );
  }

  Set<String> _resolveReferencedExtensionIds(ValidScript script) {
    Set<String> referencedExtensionIds = { DefaultExtensionConsts.Id };
    referencedExtensionIds.addAll(script.scenes.expand((element) => element.metadata.extensionIds));
    return referencedExtensionIds;
  }

  void _monitorScriptChangesAndErrors(String text) {
    ParserException? newScriptErrors;
    Set<String>? referencedExtensionIds;
    try {
      final parsedScript = widget._scriptParser.parse(RawScript("ref", text)); //TODO avoid throwing exception
      if (parsedScript is InvalidScript) throw parsedScript.parserError;

      _logger.trace(() => "Script syntax is correct");
      referencedExtensionIds = _resolveReferencedExtensionIds(parsedScript as ValidScript);
      newScriptErrors = null;
    } on ParserException catch (e) {
      newScriptErrors = e;
    }
    final bool newErrors = newScriptErrors != scriptErrors;
    final bool newExtensions = !setEquals(referencedExtensionIds, this.referencedExtensionIds);
    if (!scriptHasChanges) {
      setState(() {
        scriptHasChanges = true;
        scriptErrors = newScriptErrors;
      });
    } else if (newErrors || newExtensions) setState(() {
      scriptErrors = newScriptErrors;
      this.referencedExtensionIds = referencedExtensionIds ?? this.referencedExtensionIds;
    });

    if (newErrors && newScriptErrors != null) _logErrorsFound(newScriptErrors);
  }

  void _logErrorsFound(ParserException? newScriptErrors) {
    _logger.trace(() {
      final buffer = StringBuffer("There are ${newScriptErrors!.causes.length} errors: \n");
      newScriptErrors.errorMessages.forEach((errorMessage) => buffer.writeln("\t$errorMessage"));
      return buffer.toString();
    });
  }
}
