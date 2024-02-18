

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:visualizeit/extension/domain/default/show_message.dart';
import 'package:visualizeit_extensions/common.dart';
import 'package:visualizeit_extensions/extension.dart';
import 'package:visualizeit_extensions/scripting.dart';
import 'package:visualizeit_extensions/visualizer.dart';
import 'package:yaml/yaml.dart';

import 'nop.dart';

class _DefaultExtensionComponents implements ScriptingExtension, VisualizerExtension {
  static const String _extensionId = "default";

  @override
  Command? buildCommand(String rawCommand) {
    MapEntry<String, List<String>> commandParts = _parseCommandNode(rawCommand);
    CommandDefinition? def = getAllCommandDefinitions()
        .where((it) => commandParts.key == it.name && commandParts.value.length == it.args.length)
        .singleOrNull;

    if(def ==null) return null;

    switch (def.name) {
      case "nop": return NoOp.build();
      case "show-message": return ShowMessage.build(commandParts.value);
      default: return null;
    }
  }

  @override
  List<CommandDefinition> getAllCommandDefinitions() {
    return [
      CommandDefinition(_extensionId, "show-message", [CommandArgDef("message", ArgType.string)]),
      CommandDefinition(_extensionId, "nop", [])
    ];
  }

  @override
  Widget? render(Model model, BuildContext context) {
    switch (model.name) {
      case "show-message":
        // showAlertDialog(context, message: );
        return null;
      default: return null;
    }
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


abstract class GlobalCommand extends ModelCommand {
  GlobalCommand() : super ("global");
}

abstract class GlobalStateUpdate{}

class MessageDialog extends GlobalStateUpdate {
  String? title;
  String message;

  MessageDialog({this.title, required this.message});
}

const globalModelName = "global";

class GlobalModel extends Model {

  GlobalModel() : super(globalModelName);

  Queue<GlobalStateUpdate> globalStateUpdates = Queue();
  
  @override
  void apply(Command command) {
    if (command is ShowMessage) {
      globalStateUpdates.add(MessageDialog(message: command.message));
    }
  }

  GlobalStateUpdate? takeNextGlobalStateUpdate() => globalStateUpdates.isNotEmpty ? globalStateUpdates.removeFirst() : null;

  void pushGlobalStateUpdate(GlobalStateUpdate globalStateUpdate) {
    print("Pushing $globalStateUpdate");
    globalStateUpdates.add(globalStateUpdate);
  }
}

Extension buildDefaultExtension() {
  final component = _DefaultExtensionComponents();
  return Extension(component, component);
}
