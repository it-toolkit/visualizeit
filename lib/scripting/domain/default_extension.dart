

import 'package:flutter/widgets.dart';
import 'package:visualizeit_extensions/common.dart';
import 'package:visualizeit_extensions/extension.dart';
import 'package:visualizeit_extensions/scripting.dart';
import 'package:visualizeit_extensions/visualizer.dart';
import 'package:yaml/yaml.dart';

class ShowMessage extends GlobalCommand {

  final String _message;

  ShowMessage.build(List<String> args) : _message = args.single;

  @override
  void call() {
    print("Showing message: $_message");// TODO: implement call
  }
}

class _DefaultExtensionComponents implements ScriptingExtension, VisualizerExtension {
  static const String _extensionId = "default";

  @override
  Command? buildCommand(String rawCommand) {
    MapEntry<String, List<String>> commandParts = _parseCommandNode(rawCommand);
    CommandDefinition def = getAllCommandDefinitions()
        .firstWhere((it) => commandParts.key == it.name && commandParts.value.length == it.args.length);

    switch (def.name) {
      case "show-message": return ShowMessage.build(commandParts.value);
      default: return null;
    }
  }

  @override
  Widget? buildWidgetFor(Model model) {
    // TODO: implement buildWidgetFor
    throw UnimplementedError();
  }

  @override
  List<CommandDefinition> getAllCommandDefinitions() {
    return [
      CommandDefinition(_extensionId, "show-message", [CommandArgDef("message", ArgType.string)])
    ];
  }

  MapEntry<String, List<String>> _parseCommandNode(rawCommand) {
    YamlNode commandNode = loadYamlNode(rawCommand);

    if (commandNode is YamlScalar || commandNode is String) { //TODO improve
      return MapEntry(commandNode.toString(), []);
    } else if (commandNode is YamlMap) {
      var key = commandNode.keys.single;
      var value = commandNode.values.single;
      if (value is YamlScalar || value is String) {  //TODO improve to other scalars
        return MapEntry(key.toString(), [value.toString()]);
      } else if (value is YamlList) {
        return MapEntry(key.toString(), value.map((it) => it.toString()).toList());
      } else {
        throw Exception("Unknown command value type"); //TODO improve error handling
      }
    } else {
      throw Exception("Unknown command"); //TODO improve error handling
    }
  }
}

Extension buildDefaultExtension() {
  final component = _DefaultExtensionComponents();
  return Extension(component, component);
}
