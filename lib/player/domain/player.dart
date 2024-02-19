
import 'dart:collection';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visualizeit_extensions/common.dart';

import '../../extension/domain/default/default_extension.dart';
import '../../scripting/domain/script.dart';

abstract class PlayerEvent {}

class NextTransitionEvent extends PlayerEvent {}
class PreviousTransitionEvent extends PlayerEvent {}
class StartPlaybackEvent extends PlayerEvent {}
class StopPlaybackEvent extends PlayerEvent {}
class RestartPlaybackEvent extends PlayerEvent {}

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  Queue<PlayerState> history = Queue();

  PlayerBloc(super.playerState) {
    on<NextTransitionEvent>((event, emit) {
      history.add(state.isPlaying ? state.stopPlayback() : state);
      var newState = state.runNextCommand();
      print("Going to next state: ${newState.currentSceneIndex} - ${newState.currentCommandIndex}");
      emit(newState);
    });
    on<PreviousTransitionEvent>((event, emit) {
      if(history.isNotEmpty) {
        var previousState = history.removeLast();
        print("Going to previous state: ${previousState.currentSceneIndex} - ${previousState.currentCommandIndex}");
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


class PlayerState {

  final Script script;
  late final int currentSceneIndex;
  late final int currentCommandIndex;
  late final Map<String, Model> currentSceneModels;
  late final bool isPlaying;

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

  PlayerState._internal(this.script, this.currentSceneIndex, this.currentCommandIndex, this.currentSceneModels, this.isPlaying);

  PlayerState copy({required int sceneIndex, required int commandIndex, required Map<String, Model> models, required bool isPlaying}) {
    return PlayerState._internal(script, sceneIndex, commandIndex, models, isPlaying);
  }

  PlayerState runNextCommand() {
    var nextCommandIndex = currentCommandIndex + 1;
    print("Running command $nextCommandIndex");

    var scene = script.scenes[currentSceneIndex];
    if (nextCommandIndex >= scene.transitionCommands.length) return this; //TODO advance scene?

    var updatedModels = _runCommand(scene.transitionCommands[nextCommandIndex], currentSceneModels);
    print("updated models: $updatedModels");
    return copy(sceneIndex: currentSceneIndex, commandIndex: nextCommandIndex, models: updatedModels, isPlaying: isPlaying);
  }

  PlayerState startPlayback() {
    return copy(sceneIndex: currentSceneIndex, commandIndex: currentCommandIndex, models: currentSceneModels, isPlaying: true);
  }

  PlayerState stopPlayback() {
    return copy(sceneIndex: currentSceneIndex, commandIndex: currentCommandIndex, models: currentSceneModels, isPlaying: false);
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
    var sceneModels = commands.fold(<String, Model>{ globalModelName: GlobalModel()}, (models, command) {
      return _runCommand(command, models);
    });

    return sceneModels;
  }

  Map<String, Model> _runCommand(Command command, Map<String, Model> baseModels) {
    var updatedModels = Map.of(baseModels);
    if (command is ModelBuilderCommand) {
      Model model = command();
      updatedModels[model.name] = model;
    } else if (command is ModelCommand) {
      var model = updatedModels[command.modelName];
      if (model == null) throw Exception("Unknown model: ${command.modelName}"); //TODO define custom exception for linter

      command(model);
    } else {
      throw Exception("Unknown command: $command"); //TODO define custom exception for linter
    }

    return updatedModels;
  }
}

