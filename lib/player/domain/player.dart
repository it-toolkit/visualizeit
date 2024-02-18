
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visualizeit/common/utils/extensions.dart';
import 'package:visualizeit/extension/domain/action.dart';
import 'package:visualizeit/scripting/domain/parser.dart';
import 'package:visualizeit_extensions/common.dart';

import '../../extension/domain/default/default_extension.dart';
import '../../scripting/domain/script.dart';

void main() => runApp(CounterApp());

class CounterApp extends StatelessWidget {
  final validRawScriptYaml = """
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
    """.trimIndent();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Center(
        child: BlocProvider(
          create: (context) => PlayerBloc(PlayerState(ScriptParser(GetExtensionById()).parse(validRawScriptYaml))),
          child: BlocConsumer<PlayerBloc, PlayerState>(
            listener: (context, playerState) {
              print("listen $playerState");

              var stateUpdate = (playerState._currentSceneModels[globalModelName] as GlobalModel).takeNextGlobalStateUpdate();
              if (stateUpdate == null) return;
              switch(stateUpdate){
                case MessageDialog _: showAlertDialog(context, message: stateUpdate.message);
              }
            },
            builder: (context, playerState) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Next command: ${playerState._currentCommandIndex + 1}'),
                  ElevatedButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.redAccent)),
                    onPressed: () {
                      BlocProvider.of<PlayerBloc>(context).add(AdvanceEvent());
                    },
                    child: const Text("+"),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context, {String? title, required String message}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // title: let((it) => Text(it)),
          content: Text(message),
          actions: [
            TextButton(child: const Text("Close"), onPressed: () => Navigator.of(context, rootNavigator: true).pop()),
          ],
        );
      },
    );
  }
}

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
  late final int _currentSceneIndex;
  late final int _currentCommandIndex;
  late final Map<String, Model> _currentSceneModels;

  PlayerState(this.script) {
    _setupScene(0);
  }


  PlayerState._internal(this.script, this._currentSceneIndex, this._currentCommandIndex, this._currentSceneModels);

  PlayerState copy({required int sceneIndex, required int commandIndex, required Map<String, Model> models}) {
    return PlayerState._internal(script, sceneIndex, commandIndex, models);
  }

  // @override
  // bool operator ==(Object other) =>
  //     identical(this, other) ||
  //         other is PlayerState &&
  //             runtimeType == other.runtimeType &&
  //             script == other.script &&
  //             _currentScene == other._currentScene &&
  //             _nextCommandIndex == other._nextCommandIndex;
  //
  // @override
  // int get hashCode {
  //   int result = 17;
  //   result = 37 * result + script.hashCode;
  //   result = 37 * result + _currentScene.hashCode;
  //   result = 37 * result + _nextCommandIndex.hashCode;
  //   return result;
  // }

  PlayerState runNextCommand() {
    var nextCommandIndex = _currentCommandIndex + 1;
    print("Running command $nextCommandIndex");

    var scene = script.scenes[_currentSceneIndex];
    if (nextCommandIndex >= scene.transitionCommands.length) return this; //TODO advance scene?

    var updatedModels = _runCommand(scene.transitionCommands[nextCommandIndex], _currentSceneModels);
    print("updated models: $updatedModels");
    return copy(sceneIndex: _currentSceneIndex, commandIndex: nextCommandIndex, models: updatedModels);
  }

  void _setupScene(int sceneIndex) {
    _currentSceneIndex = sceneIndex;
    _currentCommandIndex = -1;
    _currentSceneModels = _buildInitialState(script.scenes[sceneIndex].initialStateBuilderCommands);
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

