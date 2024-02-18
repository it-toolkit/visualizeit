
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visualizeit_extensions/common.dart';

import '../../extension/domain/default/default_extension.dart';
import '../../scripting/domain/script.dart';

abstract class PlayerEvent {
}

class AdvanceEvent extends PlayerEvent {
}

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  PlayerBloc(super.playerState) {
    on<AdvanceEvent>((event, emit) => emit(state.runNextCommand()));
  }
}


class PlayerState {

  final Script script;
  late final int currentSceneIndex;
  late final int currentCommandIndex;
  late final Map<String, Model> currentSceneModels;

  PlayerState(this.script) {
    _setupScene(0);
  }


  PlayerState._internal(this.script, this.currentSceneIndex, this.currentCommandIndex, this.currentSceneModels);

  PlayerState copy({required int sceneIndex, required int commandIndex, required Map<String, Model> models}) {
    return PlayerState._internal(script, sceneIndex, commandIndex, models);
  }

  PlayerState runNextCommand() {
    var nextCommandIndex = currentCommandIndex + 1;
    print("Running command $nextCommandIndex");

    var scene = script.scenes[currentSceneIndex];
    if (nextCommandIndex >= scene.transitionCommands.length) return this; //TODO advance scene?

    var updatedModels = _runCommand(scene.transitionCommands[nextCommandIndex], currentSceneModels);
    print("updated models: $updatedModels");
    return copy(sceneIndex: currentSceneIndex, commandIndex: nextCommandIndex, models: updatedModels);
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

