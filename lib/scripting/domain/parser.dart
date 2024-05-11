import 'dart:convert';

import 'package:json2yaml/json2yaml.dart';
import 'package:visualizeit/extension/action.dart';
import 'package:visualizeit/scripting/domain/script.dart';
import 'package:visualizeit/scripting/domain/script_def.dart';
import 'package:visualizeit/scripting/domain/yaml_utils.dart';
import 'package:visualizeit_extensions/common.dart';
import 'package:visualizeit_extensions/extension.dart';
import 'package:visualizeit_extensions/scripting.dart';
import 'package:yaml/yaml.dart';

import '../../extension/domain/default/default_extension.dart';

class ScriptDefParser {
  ScriptDef parse(String rawScript) {
    final yamlDocument = loadYamlDocument(rawScript);

    if (yamlDocument.contents is! YamlMap) throw Exception("Invalid yaml script");
    YamlMap root = yamlDocument.contents as YamlMap;

    final name = root['name'];
    final description = root['description'];
    final tags = (root['tags'] as YamlList).value.map((e) => e.toString()).toSet();

    final scenes = (root['scenes'] as YamlList?)?.map((sceneNode) {
      sceneNode as YamlMap;
      final name = sceneNode['name'];
      final description = sceneNode['description'];
      final extensionIds = (sceneNode['extensions'] as YamlList).value.map((e) => e.toString()).toSet();

      final rawSceneYaml = json2yaml(json.decode(json.encode(sceneNode)));
      final metadata = SceneMetadata(name, description, extensionIds, rawSceneYaml);

      final initialStateCommands = (sceneNode['initial-state'] as YamlList?)?.map((commandNode) => commandNode.toString()).toList() ?? List.empty();
      final transitionCommands = (sceneNode['transitions'] as YamlList?)?.map((commandNode) => commandNode.toString()).toList() ?? List.empty();

      return SceneDef(metadata, initialStateCommands, transitionCommands);
    }).toList() ?? List.empty();

    return ScriptDef(
      ScriptMetadata(name, description, tags),
      scenes,
    );
  }

}

class ScriptParser {
  final GetExtensionById _getExtensionsById;

  ScriptParser(this._getExtensionsById);

  final _scripDefParser = ScriptDefParser();

  Script parse(String rawScript) {
    ScriptDef scriptDef = _scripDefParser.parse(rawScript);

    List<Scene> scenes = scriptDef.scenes.map((sceneDef) {

      Map<String, Extension> extensions = {
        for (var extensionId in sceneDef.metadata.extensionIds) extensionId : _getExtensionsById(extensionId)
      };

      extensions[DefaultExtensionConsts.Id] = _getExtensionsById(DefaultExtensionConsts.Id);

      return Scene(
          sceneDef.metadata,
          _parseRawCommands(sceneDef.initialStateBuilderCommands, extensions),
          _parseRawCommands(sceneDef.transitionCommands, extensions),
        );
    }).toList(growable: false);

    return Script(scriptDef.metadata, scenes);
  }


  ///Throws error if command cannot be parsed
  Command _parseCommand(String rawCommand, Map<String, Extension> extensions) {
    try {
      return extensions.values
          .map((extension) {
            RawCommand rawCmd = _parseCommandNode(rawCommand);
            return extension.scripting.buildCommand(rawCmd);
          })
          .nonNulls
          .single; //TODO handle too many or none
    } catch (e) {
      print("Error parsing command: ${[rawCommand, extensions]}, error: $e");
      rethrow;
    }
  }

  List<Command> _parseRawCommands(List<String> rawCommands, Map<String, Extension> extensions) {
    return rawCommands.map((rawCommand) => _parseCommand(rawCommand, extensions)).toList();
  }

  RawCommand _parseCommandNode(rawCommand) {
    YamlNode commandNode = loadYamlNode(rawCommand);

    if (commandNode is YamlScalar || commandNode is String) { //TODO improve
      return RawCommand.literal(commandNode.toString());
    } else if (commandNode is YamlMap) {
      if(commandNode.length > 1) throw Exception("Single key map required");

      var commandName = commandNode.keys.single.toString(); //Catch error if not single
      var valueYamlNode = commandNode.values.single;

      if (valueYamlNode is YamlScalar) {
        return RawCommand.withPositionalArgs(commandName, [valueYamlNode.value]);
      } else if (valueYamlNode is YamlList) {
        return RawCommand.withPositionalArgs(commandName, YamlUtils.unwrapScalarsInList(valueYamlNode));
      } else if (valueYamlNode is YamlMap) {
        return RawCommand.withNamedArgs(commandName, YamlUtils.unwrapScalarsInMap(valueYamlNode));
      }else if (valueYamlNode is String || valueYamlNode is num || valueYamlNode is bool) {
          return RawCommand.withPositionalArgs(commandName, [valueYamlNode]);
      } else {
        throw Exception("Unknown command value type"); //TODO improve error handling
      }
    } else {
      throw Exception("Unknown command"); //TODO improve error handling
    }
  }
}
