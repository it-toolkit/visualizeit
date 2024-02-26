
import 'dart:collection';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visualizeit_extensions/common.dart';
import 'package:visualizeit_extensions/logging.dart';

import '../../extension/domain/default/default_extension.dart';
import '../../scripting/domain/script.dart';

final _logger = Logger("player");

abstract class PlayerEvent {}

class NextTransitionEvent extends PlayerEvent {}
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

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  Queue<PlayerState> history = Queue();

  PlayerBloc(super.playerState) {
    on<NextTransitionEvent>((event, emit) {
      history.add(state.isPlaying ? state.stopPlayback() : state);
      var newState = state.runNextCommand();
      _logger.debug(() => "Going to next state: ${newState.currentSceneIndex} - ${newState.currentCommandIndex}");
      emit(newState);
    });
    on<PreviousTransitionEvent>((event, emit) {
      if(history.isNotEmpty) {
        var previousState = history.removeLast();
        _logger.debug(() => "Going to previous state: ${previousState.currentSceneIndex} - ${previousState.currentCommandIndex}");
        emit(previousState);
      }
    });

    on<StartPlaybackEvent>((event, emit) {
        emit(state.startPlayback());
    });

    on<StopPlaybackEvent>((event, emit) {
      emit(state.stopPlayback());
    });

    on<RestartPlaybackEvent>((event, emit) {
      emit(state.restartPlayback());
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

class PlayerState {

  final Script script;
  late final int currentSceneIndex;
  late final int currentCommandIndex;
  late final Map<String, Model> currentSceneModels;
  late final bool isPlaying;
  late final bool waitingAction;
  late final copyCounter = 0;


  @override
  String toString() {
    return 'PlayerState{script: ${script.metadata.name}, command: $currentSceneIndex/$currentCommandIndex, isPlaying: $isPlaying, models: $currentSceneModels}';
  }

  PlayerState(this.script) {
    _setupScene(0);
    isPlaying = false;
  }

  double get progress {
    var commandsRun = currentCommandIndex+1;
    for(int i=0; i< currentSceneIndex-1; i++){
      commandsRun += script.scenes[i].transitionCommands.length;
    }
    final totalCommands = script.scenes.fold(0, (acc, scene) => acc + scene.transitionCommands.length);

    return commandsRun / totalCommands;
  }

  PlayerState._internal(this.script, this.currentSceneIndex, this.currentCommandIndex, this.currentSceneModels, this.isPlaying, this.waitingAction);

  PlayerState copy({required int sceneIndex, required int commandIndex, required Map<String, Model> models, required bool isPlaying, bool waitingAction = false}) {
    return PlayerState._internal(script, sceneIndex, commandIndex, models, isPlaying, waitingAction);
  }

  PlayerState runNextCommand() {
    var nextCommandIndex = currentCommandIndex + 1;
    var scene = script.scenes[currentSceneIndex];

    if (nextCommandIndex >= scene.transitionCommands.length) return stopPlayback(); //TODO advance scene?

    _logger.debug(() => "Running command $nextCommandIndex: ${scene.transitionCommands[nextCommandIndex]}");

    var result = _runCommand(scene.transitionCommands[nextCommandIndex], currentSceneModels);
    _logger.debug(() => "Command result: updated models: ${result.models}, finished: ${result.finished}");
    return copy(
      sceneIndex: currentSceneIndex,
      commandIndex: result.finished ? nextCommandIndex : currentCommandIndex,
      models: result.models,
      isPlaying: isPlaying,
    );
  }

  PlayerState startPlayback({bool waitingAction = false}) {
    _logger.debug(() => "Start playback (waitingAction=$waitingAction)");
    return copy(sceneIndex: currentSceneIndex, commandIndex: currentCommandIndex, models: currentSceneModels, isPlaying: !waitingAction || this.waitingAction);
  }

  PlayerState stopPlayback({bool waitingAction = false}) {
    _logger.debug(() => "Stop playback (waitingAction=$waitingAction)");
    return copy(sceneIndex: currentSceneIndex, commandIndex: currentCommandIndex, models: currentSceneModels, isPlaying: false, waitingAction: isPlaying && waitingAction);
  }

  PlayerState restartPlayback() {
    return PlayerState(script);
  }

  void _setupScene(int sceneIndex) {
    currentSceneIndex = sceneIndex;
    currentCommandIndex = -1;
    currentSceneModels = _buildInitialState(script.scenes[sceneIndex].initialStateBuilderCommands);
  }

  Map<String, Model> _buildInitialState(List<Command> commands) {
    var sceneModels = commands.fold(<String, Model>{globalModelName: GlobalModel()}, (models, command) {
      _RunCommandResult result;
      do {
        _logger.debug(() => "Running command: $command");
        result = _runCommand(command, models);
      } while (!result.finished);
      return result.models;
    });

    return sceneModels;
  }

  _RunCommandResult _runCommand(Command command, Map<String, Model> baseModels) {
    final result = _RunCommandResult(Map.of(baseModels), true);
    if (command is ModelBuilderCommand) {
      Model model = command();
      result.models[model.name] = model;

    } else if (command is ModelCommand) {
      var model = result.models[command.modelName];
      if (model == null) throw Exception("Unknown model: ${command.modelName}"); //TODO define custom exception for linter

      var cmdResult = command(model);
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

