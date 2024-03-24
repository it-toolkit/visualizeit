

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:visualizeit_extensions/common.dart';
import 'package:visualizeit_extensions/extension.dart';
import 'package:visualizeit_extensions/logging.dart';
import 'package:visualizeit_extensions/scripting.dart';
import 'package:visualizeit_extensions/visualizer.dart';
import 'package:yaml/yaml.dart';

import 'nop.dart';
import 'show_banner.dart';
import 'show_popup.dart';

final _logger = Logger("extension.default");

abstract class DefaultExtensionConsts {
  static const String Id = "default";
}


class _DefaultExtensionComponents implements ScriptingExtension, VisualizerExtension {
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
      CommandDefinition(DefaultExtensionConsts.Id, "show-popup", [CommandArgDef("message", ArgType.string)]),
      CommandDefinition(DefaultExtensionConsts.Id, "banner", [CommandArgDef("name", ArgType.string), CommandArgDef("message", ArgType.string)]),
      CommandDefinition(DefaultExtensionConsts.Id, "show-banner", [CommandArgDef("name", ArgType.string), CommandArgDef("position", ArgType.string), CommandArgDef("duration", ArgType.int)]),
      CommandDefinition(DefaultExtensionConsts.Id, "nop", [])
    ];
  }

  @override
  Widget? render(Model model, BuildContext context) {
    switch (model.name) {
      default:
        if (model is GlobalModel) {
          return Stack(children: model.models.values.map((innerModel) {
              switch (innerModel) {
                case BannerModel():
                 return buildBannerWidget(innerModel);
                default:
                 return null;
              }
          }).nonNulls.toList());
        }

        return null;
    }
  }

  Widget buildBannerWidget(BannerModel innerModel) {
    _logger.trace(() => "Building widget for: ${innerModel.toString()}");

    return Positioned.fill(
        child: Align(
            alignment: parseAlignment(innerModel.alignment),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.deepPurpleAccent.shade100, borderRadius: BorderRadius.circular(10)),
              child: MarkdownBody(
                  data : innerModel.message,//+ " [${innerModel.pendingFrames + 1}]"
              ),
            ),
        ),
    );
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

  @override
  String toString() {
    return 'PopupMessage{title: $title, message: $message}';
  }
}

const globalModelName = "global";

class GlobalModel extends Model {

  GlobalModel() : super(DefaultExtensionConsts.Id, globalModelName);

  GlobalModel.from(GlobalModel globalModel): super(DefaultExtensionConsts.Id, globalModelName) {
    globalStateUpdates = Queue.from(globalModel.globalStateUpdates);
    models = Map.from(globalModel.models);
  }

  Queue<GlobalStateUpdate> globalStateUpdates = Queue();
  Map<String, Model> models = {};
  
  GlobalStateUpdate? takeNextGlobalStateUpdate() => globalStateUpdates.isNotEmpty ? globalStateUpdates.removeFirst() : null;

  void pushGlobalStateUpdate(GlobalStateUpdate globalStateUpdate) {
    globalStateUpdates.add(globalStateUpdate);
  }

  @override
  String toString() {
    return 'GlobalModel{globalStateUpdates: $globalStateUpdates, models: $models}';
  }
}

Extension buildDefaultExtension() {
  final component = _DefaultExtensionComponents();
  return Extension(DefaultExtensionConsts.Id, component, component);
}
