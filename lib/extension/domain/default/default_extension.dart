

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:visualizeit_extensions/common.dart';
import 'package:visualizeit_extensions/extension.dart';
import 'package:visualizeit_extensions/scripting.dart';
import 'package:visualizeit_extensions/visualizer.dart';
import 'package:yaml/yaml.dart';

import 'nop.dart';
import 'show_banner.dart';
import 'show_popup.dart';

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
      case "show-popup": return ShowPopup.build(commandParts.value);
      case "show-banner": return ShowBanner.build(commandParts.value);
      default: return null;
    }
  }

  @override
  List<CommandDefinition> getAllCommandDefinitions() {
    return [
      CommandDefinition(_extensionId, "show-popup", [CommandArgDef("message", ArgType.string)]),
      CommandDefinition(_extensionId, "show-banner", [CommandArgDef("message", ArgType.string), CommandArgDef("position", ArgType.string), CommandArgDef("duration", ArgType.int)]),
      CommandDefinition(_extensionId, "nop", [])
    ];
  }

  @override
  Widget? render(Model model, BuildContext context) {
    switch (model.name) {
      case "show-popup":
        // showAlertDialog(context, message: );
        return null;
      default:
        if (model.name.indexOf(showBannerModelName) == 0) {
          model as ShowBannerModel;
          return Positioned.fill(
              child: Align(
                  alignment: parseAlignment(model.alignment),
                  child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.deepPurpleAccent.shade100, borderRadius: BorderRadius.circular(10)),
                      child: Text(model.message))));
        }
        return null;
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

  Alignment parseAlignment(String alignment) {
    switch(alignment) {
      case "topLeft": return Alignment.topLeft;
      case "topCenter": return Alignment.topCenter;
      case "topRight": return Alignment.topRight;
      case "centerLeft": return Alignment.centerLeft;
      case "center": return Alignment.center;
      case "centerRight": return Alignment.centerRight;
      case "bottomLeft": return Alignment.bottomLeft;
      case "bottomCenter": return Alignment.bottomCenter;
      case "bottomRight": return Alignment.bottomRight;
      default: throw Exception("Unknown alignment value"); //TODO handle error properly
    }
  }
}


abstract class GlobalCommand extends ModelCommand {
  GlobalCommand() : super ("global");
}

abstract class GlobalStateUpdate{}

class PopupMessage extends GlobalStateUpdate {
  String? title;
  String message;

  PopupMessage({this.title, required this.message});
}

const globalModelName = "global";

class GlobalModel extends Model {

  GlobalModel() : super(globalModelName);

  Queue<GlobalStateUpdate> globalStateUpdates = Queue();
  
  @override
  void apply(Command command) {
    if (command is ShowPopup) {
      globalStateUpdates.add(PopupMessage(message: command.message));
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
