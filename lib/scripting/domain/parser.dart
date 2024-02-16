import 'package:visualizeit/extension/domain/action.dart';
import 'package:visualizeit/scripting/domain/script.dart';
import 'package:visualizeit/scripting/domain/script_def.dart';
import 'package:visualizeit_extensions/common.dart';
import 'package:visualizeit_extensions/extension.dart';
import 'package:yaml/yaml.dart';

class NoModel extends Model {
  static final NoModel _singleton = NoModel._internal();

  factory NoModel() {
    return _singleton;
  }

  NoModel._internal() : super("NoModel");

  @override
  void apply(Command command) {}
}

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
    final yamlDocument = loadYamlDocument(rawScript);

    if (yamlDocument.contents is! YamlMap) throw Exception("Invalid yaml script");
    YamlMap root = yamlDocument.contents as YamlMap;

    final name = root['name'];
    final description = root['description'];
    final tags = (root['tags'] as YamlList).value.map((e) => e.toString()).toSet();

    final scenes = (root['scenes'] as YamlList).map((sceneNode) {
      sceneNode as YamlMap;
      final name = sceneNode['name'];
      final description = sceneNode['description'];
      final extensionIds = (sceneNode['extensions'] as YamlList).value.map((e) => e.toString()).toSet();

      final metadata = SceneMetadata(name, description, extensionIds);

      final initialStateCommands = (sceneNode['initial-state'] as YamlList).map((commandNode) => commandNode.toString()).toList();
      final transitionCommands = (sceneNode['transitions'] as YamlList).map((commandNode) => commandNode.toString()).toList();

      return SceneDef(metadata, initialStateCommands, transitionCommands);
    }).toList();

    return ScriptDef(
      ScriptMetadata(name, description, tags),
      scenes,
    );
  }

  ///Throws error if command cannot be parsed
  Command _parseCommand(String rawCommand, Map<String, Extension> extensions) {
    print([rawCommand, extensions]);

    return extensions.values.map((extension) => extension.scripting.buildCommand(rawCommand)).nonNulls.single; //TODO handle too many or none
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

    switch(models.length){
      case 0: return NoModel();
      case 1: return models.values.single;
      default: throw UnimplementedError("Multiple model support");
    }
  }

  List<Command> _parseTransitionCommands(List<String> transitionCommands, Map<String, Extension> extensions) {
    return transitionCommands.map((rawCommand) => _parseCommand(rawCommand, extensions)).toList();
  }
}
