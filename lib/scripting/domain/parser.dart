import 'package:visualizeit/extension/domain/action.dart';
import 'package:visualizeit/scripting/domain/script.dart';
import 'package:visualizeit/scripting/domain/script_def.dart';
import 'package:visualizeit_extensions/common.dart';
import 'package:visualizeit_extensions/extension.dart';

class ScriptParser {
  final GetExtensionsById _getExtensionsById;

  ScriptParser(this._getExtensionsById);

  Script parse(String rawScript) {
    ScriptDef scriptDef = _parseScriptDef(rawScript);
    List<Scene> scenes = scriptDef.scenes.map((sceneDef) {
      Map<String, Extension> extensions = {
        for (var extensionId in sceneDef.metadata.extensionIds) extensionId : _getExtensionsById(extensionId)
      };

      return Scene(
          sceneDef.metadata,
          _buildInitialState(sceneDef.initialStateBuilderCommands, extensions),
          _parseTransitionCommands(sceneDef.transitionCommands, extensions),
        );
    }).toList(growable: false);

    return Script(scriptDef.metadata, scenes);
  }

  ScriptDef _parseScriptDef(String rawScript) {
    throw UnimplementedError("Parse script definition from raw script");
  }

  ///Throws error if command cannot be parsed
  Command _parseCommand(String rawCommand, Map<String, Extension> extensions) {
    throw UnimplementedError("Parse command from raw string");
  }

  Model _buildInitialState(List<String> initialStateBuilderCommands, Map<String, Extension> extensions) {
    List<Command> commands = initialStateBuilderCommands.map((rawCommand) => _parseCommand(rawCommand, extensions)).toList();
    Map<String, Model> models = commands.fold(<String, Model>{}, (models, command) {
      if (command is ModelBuilderCommand) {
        Model model = command();
        models[model.name] = model;
      } else if (command is ModelCommand) {
        var model = models[command.modelName];
        if (model == null) throw Exception("Unknown model: ${command.modelName}"); //TODO define custom exception for linter

        command(model);
      } else if (command is GlobalCommand) {
        command();
      } else {
        throw Exception("Unknown command: $command"); //TODO define custom exception for linter
      }

      return models;
    });

    if (models.length == 1) {
      return models.values.single;
    } else {
      throw UnimplementedError("Multiple model support");
    }
  }

  List<Command> _parseTransitionCommands(List<String> transitionCommands, Map<String, Extension> extensions) {
    return transitionCommands.map((rawCommand) => _parseCommand(rawCommand, extensions)).toList();
  }
}
