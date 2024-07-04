
import 'dart:collection';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visualizeit/common/utils/extensions.dart';
import 'package:visualizeit/main.dart';
import 'package:visualizeit/player/domain/player_timer.dart';
import 'package:visualizeit_extensions/common.dart';
import 'package:visualizeit_extensions/logging.dart';

import '../../extension/domain/default/default_extension.dart';
import '../../scripting/domain/script.dart';

final _logger = Logger("player");

class PlayerException implements Exception {
  final String message;

  PlayerException(this.message);

  @override
  String toString() => message;
}

abstract class PlayerEvent {}

class NextTransitionEvent extends PlayerEvent {
  final Duration timeFrame;
  NextTransitionEvent({required this.timeFrame});
}
class PreviousTransitionEvent extends PlayerEvent {}
class StartPlaybackEvent extends PlayerEvent {
  bool waitingAction;
  StartPlaybackEvent({this.waitingAction = false});
}
class StopPlaybackEvent extends PlayerEvent {
  bool waitingAction;
  StopPlaybackEvent({this.waitingAction = false});
}
class RestartPlaybackEvent extends PlayerEvent {}

class OverrideEvent extends PlayerEvent {
  PlayerState state;
  OverrideEvent(this.state);
}

class SetCanvasScaleEvent extends PlayerEvent {
  double scale;
  SetCanvasScaleEvent(this.scale);
}

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  Queue<PlayerState> history = Queue();

  PlayerBloc(super.playerState) {
    on<OverrideEvent>((event, emit) {
      emit(event.state);
    });

    on<NextTransitionEvent>((event, emit) {
      history.add(state.isPlaying ? state.stopPlayback() : state);
      try {
        var newState = state.runNextCommand(timeFrame: event.timeFrame);
        _logger.debug(() => "Going to next state: ${newState.currentSceneIndex} - ${newState.currentCommandIndex}");
        emit(newState);
      } on PlayerException catch (e, stacktrace) {
        _logger.error(() => e.message, stackTrace: stacktrace);
        VisualizeItApp.showErrorInSnackBar(e.message);
        emit(state.restartPlayback());
      } on Exception catch (e, stacktrace) {
        _logger.error(() => "Unexpected error running command", error: e, stackTrace: stacktrace);
        VisualizeItApp.showErrorInSnackBar("Unexpected error running command: $e");
        emit(state.restartPlayback());
      }
    });

    on<PreviousTransitionEvent>((event, emit) {
      if(history.isNotEmpty) {
        var previousState = history.removeLast();
        _logger.debug(() => "Going to previous state: ${previousState.currentSceneIndex} - ${previousState.currentCommandIndex}");
        emit(previousState);
      }
    });

    on<StartPlaybackEvent>((event, emit) {
        emit(state.startPlayback(waitingAction: event.waitingAction));
    });

    on<StopPlaybackEvent>((event, emit) {
      emit(state.stopPlayback(waitingAction: event.waitingAction));
    });

    on<RestartPlaybackEvent>((event, emit) {
      emit(state.restartPlayback());
    });

    on<SetCanvasScaleEvent>((event, emit) {
      emit(state.updateCanvasScale(event.scale));
    });
  }
}


class _RunCommandResult{
  Map<String, Model> models;
  bool finished;

  _RunCommandResult(this.models, this.finished);

  @override
  String toString() {
    return '_RunCommandResult{models: $models, finished: $finished}';
  }
}

const _defaultSceneTitleDuration = 1;

class LazyValue<T> {
  final T Function() _builder;
  late T value = _builder();

  LazyValue(this._builder);
}

class PlayerState {

  final ValidScript script;
  late final int currentSceneIndex;
  late final int currentCommandIndex;
  late final LazyValue<Map<String, Model>> currentSceneModels;
  late final bool isPlaying;
  late final bool waitingAction;
  late final double canvasScale;
  late final int baseFrameDurationInMillis;

  Scene get currentScene => script.scenes[currentSceneIndex];

  int get countdownToStart => max(-1-currentCommandIndex, 0);

  Command? get currentCommand => currentScene.transitionCommands.isNotEmpty && currentCommandIndex >= -1
      ? currentScene.transitionCommands[min(currentCommandIndex + 1, currentScene.transitionCommands.length - 1)]
      : null;

  PlayerState updateCanvasScale(double scale) {
    return PlayerState._internal(this.script, this.currentSceneIndex, this.currentCommandIndex, this.currentSceneModels, this.isPlaying, this.waitingAction, scale, baseFrameDurationInMillis);
  }

  @override
  String toString() {
    return 'PlayerState{script: ${script.metadata.name}, command: $currentSceneIndex/$currentCommandIndex, isPlaying: $isPlaying, models: $currentSceneModels}';
  }

  PlayerState(this.script, {this.canvasScale = 1}) {
    _setupScene(0);
    isPlaying = false;
    waitingAction = false;
  }

  double get progress {
    final totalCommands = script.scenes.fold(0, (acc, scene) => acc + scene.transitionCommands.length);

    if (totalCommands == 0) return 1.0;

    var commandsRun = currentCommandIndex+1;
    for(int i=0; i< currentSceneIndex-1; i++){
      commandsRun += script.scenes[i].transitionCommands.length;
    }

    return commandsRun / totalCommands;
  }

  PlayerState._internal(this.script, this.currentSceneIndex, this.currentCommandIndex, this.currentSceneModels, this.isPlaying, this.waitingAction, this.canvasScale, this.baseFrameDurationInMillis);

  PlayerState copy({required int sceneIndex, required int commandIndex, required Map<String, Model> models, required bool isPlaying, bool waitingAction = false}) {
    return PlayerState._internal(script, sceneIndex, commandIndex, LazyValue(() => models), isPlaying, waitingAction, canvasScale, baseFrameDurationInMillis);
  }

  int _getSceneTitleDuration(int sceneIndex) => script.scenes[sceneIndex].metadata.titleDuration ?? _defaultSceneTitleDuration;

  PlayerState runNextCommand({Duration timeFrame = Duration.zero}) {
    var nextCommandIndex = currentCommandIndex + 1;
    if (nextCommandIndex < 0) return PlayerState._internal(script, currentSceneIndex, nextCommandIndex, currentSceneModels, isPlaying, waitingAction, canvasScale, baseFrameDurationInMillis);

    var scene = script.scenes[currentSceneIndex];

    final isLastScene = (currentSceneIndex == script.scenes.length - 1);

    if (nextCommandIndex >= scene.transitionCommands.length) {
      if (isLastScene) return stopPlayback();
      else return nextScene();
    }

    var command = scene.transitionCommands[nextCommandIndex];
    var commandContext = CommandContext(timeFrame: timeFrame);
    _logger.debug(() => "Running command [#$nextCommandIndex] $command on $commandContext");

    try {
      var result = _runCommand(command, currentSceneModels.value, commandContext);
      _logger.debug(() => "Command result: updated models: ${result.models}, finished: ${result.finished}");
      return copy(
        sceneIndex: currentSceneIndex,
        commandIndex: result.finished ? nextCommandIndex : currentCommandIndex,
        models: result.models,
        isPlaying: isPlaying,
      );
    } catch (e) {
      throw PlayerException("Unexpected error executing command ${command.metadata?.scriptLineIndex.let((it) => "(line ${it + 1}")}): $e");
    }
  }

  PlayerState nextScene() {
    var sceneIndex = currentSceneIndex +1;
    var nextScene = script.scenes[sceneIndex];
    final frameDurationInMillis = nextScene.metadata.baseFrameDurationInMillis ?? PlayerTimer.DefaultFrameDurationInMillis;
    return PlayerState._internal(script, sceneIndex, -1 - _getSceneTitleDuration(sceneIndex), LazyValue(() => _buildInitialState(nextScene.initialStateBuilderCommands)), isPlaying, waitingAction, canvasScale, frameDurationInMillis);
  }

  PlayerState startPlayback({bool waitingAction = false}) {
    _logger.debug(() => "Start playback (waitingAction=$waitingAction)");
    return copy(sceneIndex: currentSceneIndex, commandIndex: currentCommandIndex, models: currentSceneModels.value, isPlaying: !waitingAction || this.waitingAction);
  }

  PlayerState stopPlayback({bool waitingAction = false}) {
    _logger.debug(() => "Stop playback (waitingAction=$waitingAction)");
    return copy(sceneIndex: currentSceneIndex, commandIndex: currentCommandIndex, models: currentSceneModels.value, isPlaying: false, waitingAction: isPlaying && waitingAction);
  }

  PlayerState restartPlayback() {
    return PlayerState(script, canvasScale: canvasScale);
  }

  void _setupScene(int sceneIndex) {
    currentSceneIndex = sceneIndex;
    currentCommandIndex = -1 - _getSceneTitleDuration(sceneIndex);
    var scene = script.scenes[sceneIndex];
    currentSceneModels = LazyValue(() => _buildInitialState(scene.initialStateBuilderCommands));
    baseFrameDurationInMillis = scene.metadata.baseFrameDurationInMillis ?? PlayerTimer.DefaultFrameDurationInMillis;
  }

  Map<String, Model> _buildInitialState(List<Command> commands) {
    var commandContext = CommandContext();
    var sceneModels = commands.fold(<String, Model>{globalModelName: GlobalModel()}, (models, command) {
      _RunCommandResult result = _RunCommandResult(models, false);
      try {
        do {
          _logger.debug(() => "Running command: $command");
          result = _runCommand(command, result.models, commandContext);
        } while (!result.finished);

        return result.models;
      } on PlayerException {
        rethrow;
      } catch (e) {
        throw PlayerException("Unexpected error building initial state ${command.metadata?.scriptLineIndex.let((it) => "(line ${it + 1}")}): $e");
      }
    });

    return sceneModels;
  }

  _RunCommandResult _runCommand(Command command, Map<String, Model> baseModels, CommandContext context) {
    final result = _RunCommandResult(Map.of(baseModels), true);
    if (command is ModelBuilderCommand) {
      Model model = command(context);
      result.models[model.name] = model;

    } else if (command is ModelCommand) {
      var model = result.models[command.modelName];
      if (model == null) throw Exception("Unknown model: ${command.modelName}"); //TODO define custom exception for linter

      var cmdResult = command(model, context);
      final updatedModel = cmdResult.model;
      if (updatedModel == null){
        result.models.remove(command.modelName);
      } else {
        result.models[command.modelName] = updatedModel;
        result.finished = cmdResult.finished;
      }

    } else {
      throw Exception("Unknown command: $command"); //TODO define custom exception for linter
    }

    _logger.debug(() => "Command result: $result");
    return result;
  }
}

