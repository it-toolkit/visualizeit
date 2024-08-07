import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import 'package:visualizeit/common/utils/extensions.dart';
import 'package:visualizeit/extension/action.dart';
import 'package:visualizeit/extension/domain/extension_repository.dart';
import 'package:visualizeit/scripting/domain/script.dart';
import 'package:visualizeit/scripting/domain/script_def.dart';
import 'package:visualizeit/scripting/domain/script_preprocessor.dart';
import 'package:visualizeit/scripting/domain/script_repository.dart';
import 'package:visualizeit/scripting/domain/yaml_utils.dart';
import 'package:visualizeit_extensions/common.dart';
import 'package:visualizeit_extensions/extension.dart';
import 'package:visualizeit_extensions/logging.dart';
import 'package:visualizeit_extensions/scripting.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml/src/error_listener.dart';

import '../../extension/domain/default/default_extension.dart';
import 'package:source_span/source_span.dart';

final _logger = Logger("scripting.parser");

class ErrorCollector extends ErrorListener {
  final List<YamlException> errors = [];

  bool isEmpty() => errors.isEmpty;

  void onError(YamlException error) => errors.add(error);
}

class _SourceSpanFormatExceptionEquality implements Equality<SourceSpanFormatException> {
  const _SourceSpanFormatExceptionEquality();

  @override
  bool equals(SourceSpanFormatException e1, SourceSpanFormatException e2) {
    return _customMessage(e1) == _customMessage(e2);
  }

  @override
  int hash(SourceSpanFormatException e) {
    return _customMessage(e).hashCode;
  }

  String _customMessage(SourceSpanFormatException e) {
    var span = e.span;
    if (span == null) return e.message;

    final errorLocation = 'line ${span.start.line + 1}, column ${span.start.column + 1}';
    var customMessage = "${e.message} ($errorLocation)";
    return customMessage;
  }

  @override
  bool isValidKey(Object? o) {
    return o == null || o is SourceSpanFormatException;
  }
}

@immutable
class ParserException implements Exception {

  static const _listEquality = ListEquality<SourceSpanFormatException>(_SourceSpanFormatExceptionEquality());

  final List<SourceSpanFormatException> causes;

  ParserException(this.causes) {
    causes.sort((a, b) {
      var result = (a.span?.start.line ?? 0).compareTo((b.span?.start.line ?? 0));
      if (result != 0) return result;
      else return (a.span?.start.column ?? 0).compareTo((b.span?.start.column ?? 0));
    });
  }

  List<String> get errorMessages => causes.map((e) => _customMessage(e)).toList();

  String _customMessage(SourceSpanFormatException e) {
    var span = e.span;
    if (span == null) return e.message;

    final errorLocation = 'line ${span.start.line + 1}, column ${span.start.column + 1}';
    var customMessage = "${e.message} ($errorLocation)";
    return customMessage;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (
        other is ParserException
            && runtimeType == other.runtimeType
            && (causes == other.causes || _listEquality.equals(causes, other.causes)));
  }

  @override
  int get hashCode => _listEquality.hash(causes);
}

class ScriptDefParser {

  static const _expectedTokens = {
    "name": null,
    "description": null,
    "group": null,
    "scenes": {
      "name": null,
      "description": null,
      "extensions": null,
      "title-duration": null,
      "base-frame-duration-ms": null,
      "initial-state": null,
      "transitions": null
    }
  };

  ScriptDef parse(String rawScriptYaml) {
    final errorCollector = ErrorCollector();
    YamlDocument yamlDocument = readYamlDocument(rawScriptYaml, errorCollector);

    if (yamlDocument.contents is! YamlMap) {
      errorCollector.onError(YamlException("Invalid yaml script, a map is expected", yamlDocument.contents.span));
      throw ParserException(errorCollector.errors);
    } else {
      YamlMap root = yamlDocument.contents as YamlMap;

      lookupUnexpectedTokens(root, errorCollector);

      final name = getRequiredString(root, 'name', errorCollector);
      final description = getRequiredString(root, 'description', errorCollector);
      final group = getOptionalString(root, 'group', errorCollector);
      final scenesDef = buildScenesDef(root, errorCollector);

      if (!errorCollector.isEmpty()) throw ParserException(errorCollector.errors);

      return ScriptDef(ScriptMetadata(name, description, group: group), scenesDef);
    }
  }

  YamlDocument readYamlDocument(String rawScriptYaml, ErrorCollector errorCollector) {
    try {
      return loadYamlDocument(rawScriptYaml, recover: true, errorListener: errorCollector);
    } on YamlException catch (error) {
      errorCollector.onError(error);
      throw ParserException(errorCollector.errors);
    }
  }

  List<SceneDef> buildScenesDef(YamlMap root, ErrorCollector errorCollector) {
    List<SceneDef> scenesDef = List.empty();
    var scenes = getRequiredArrayOf<YamlMap>(root, 'scenes', errorCollector, 'scene');
    if (scenes is YamlList) {
      scenesDef = [for (int i = 0; i < scenes.length; i++) buildSceneDef(scenes, i, errorCollector)].nonNulls.toList();
    }
    return scenesDef;
  }

  dynamic getValue(
      YamlMap node,
      String key,
      bool Function(dynamic value) validator,
      dynamic Function(YamlNode node, String key, dynamic value) onInvalidValue,
      [dynamic Function(dynamic value)? onValidValue]) {

    final value = node[key];
    if (!validator.call(value)) {
      return onInvalidValue.call(node.nodes[key] ?? node, key, value);
    } else {
      return onValidValue != null ? onValidValue(value) : value;
    }
  }

  dynamic getRequiredString(YamlMap node, String key, ErrorCollector errorCollector) {
    return getValue(node, key, (value) => value is String && value.trim().isNotEmpty, (node, key, value) {
      if (value == null || value is String)
        errorCollector.onError(YamlException("Missing non blank '$key' attribute", node.span));
      else
        errorCollector.onError(YamlException("'$key' must be a String", node.span));
    });
  }

  dynamic getOptionalString(YamlMap node, String key, ErrorCollector errorCollector) {
    return getValue(node, key, (value) => value == null || value is String,
        (node, key, value) => errorCollector.onError(YamlException("'$key' must be a String", node.span)));
  }

  dynamic getOptionalPositiveOrZeroInt(YamlMap node, String key, ErrorCollector errorCollector) {
    return getValue(node, key, (value) => value == null || (value is int && value >= 0),
            (node, key, value) => errorCollector.onError(YamlException("'$key' must an integer greater or equal than zero", node.span)));
  }

  dynamic getOptionalStringSet(YamlMap node, String key, ErrorCollector errorCollector) {
    return getValue(node, key, (value) => value == null || (value is YamlList && value.every((it) => it is String)),
      (node, key, value) {
        if (value is YamlList) errorCollector.onError(YamlException("'$key' array must contain only String values", node.span));
        else errorCollector.onError(YamlException("'$key' must be a String array", node.span));

        return null;
      },
      (value) => (value as YamlList?)?.value.map((element) => element as String).toSet());
  }

  dynamic getRequiredArrayOf<ElementType>(YamlMap node, String key, ErrorCollector errorCollector, String elementTypeName) {
    final array = node[key];

    if (!node.containsKey(key))
      errorCollector.onError(YamlException("Missing non empty '$key' array", node.span));
    else if (array == null || (array is! YamlList))
      errorCollector.onError(YamlException("'$key' must be a ${elementTypeName}s array", node.span));
    else if (array.isEmpty)
      errorCollector.onError(YamlException("'$key' array must not be empty", node.span));
    else {
      for (int i = 0; i < array.length; i++) {
        if (array[i] is! ElementType)
          errorCollector.onError(YamlException("Element $i of '$key' array is not a valid ${elementTypeName}", node.span));
      }
    }

    return array is YamlList ? array : YamlList.wrap(List.empty());
  }

  dynamic getOptionalArrayOf<ElementType>(YamlMap node, String key, ErrorCollector errorCollector, String elementTypeName) {
    final array = node[key];

    if (array != null) {
      if (array is! YamlList)
        errorCollector.onError(YamlException("'$key' must be a ${elementTypeName}s array", node.span));
      else {
        for (int i = 0; i < array.length; i++) {
          if (array[i] is! ElementType)
            errorCollector.onError(YamlException("Element $i of '$key' array is not a valid ${elementTypeName}", node.span));
        }
      }
    }

    return array == null || array is YamlList ? array : YamlList.wrap(List.empty());
  }

  SceneDef? buildSceneDef(YamlList scenes, int i, ErrorCollector errorCollector) {
    final sceneNode = scenes[i];
    if (sceneNode is YamlMap) {
      final name = getRequiredString(sceneNode, 'name', errorCollector) ?? "placeholder";
      final description = getOptionalString(sceneNode, 'description', errorCollector);
      final extensionIds = getOptionalStringSet(sceneNode, 'extensions', errorCollector) ?? Set<String>();
      final titleDuration = getOptionalPositiveOrZeroInt(sceneNode, 'title-duration', errorCollector);
      final baseFrameDurationInMillis = getOptionalPositiveOrZeroInt(sceneNode, 'base-frame-duration-ms', errorCollector);

      final metadata = SceneMetadata(name, description, extensionIds, sceneNode.span, titleDuration, baseFrameDurationInMillis);

      final initialStateCommands = getOptionalArrayOf(sceneNode, 'initial-state', errorCollector, 'command') ?? YamlList.wrap(List.empty());
      final transitionCommands = getOptionalArrayOf(sceneNode, 'transitions', errorCollector, 'command') ?? YamlList.wrap(List.empty());

      return SceneDef(metadata, initialStateCommands, transitionCommands);
    }
    return null;
  }

  void lookupUnexpectedTokens(dynamic node, ErrorCollector errorCollector, {String? parentNodeKey}) {
    final expectedKeys = (parentNodeKey == null ? _expectedTokens.keys: _expectedTokens[parentNodeKey]?.keys ?? List.empty()).toSet();
    if (node is YamlMap) {
      node.keys.forEach((nodeKey) {
        var valueNode = node[nodeKey];
        if(!expectedKeys.contains(nodeKey.toString())){
          YamlNode nearestNode = valueNode is YamlNode ? valueNode : node;
          errorCollector.onError(YamlException("Unexpected attribute '$nodeKey'", nearestNode.span));
        } else if (_expectedTokens[nodeKey] != null){
          if (valueNode is YamlList) {
            valueNode.forEach((itemNode) {
              lookupUnexpectedTokens(itemNode, errorCollector, parentNodeKey: nodeKey);
            });
          } else lookupUnexpectedTokens(valueNode, errorCollector, parentNodeKey: nodeKey);
        }
      });
    }
  }
}

class ScriptParser {
  final GetExtensionById _getExtensionsById;
  final RawScriptPreprocessor _rawScriptPreprocessor;

  ScriptParser(this._getExtensionsById, this._rawScriptPreprocessor);

  final _scripDefParser = ScriptDefParser();

  Script parse(RawScript rawScript) {
    RawScript? preProcessed = _rawScriptPreprocessor.preProcess(rawScript);

    ScriptDef scriptDef;
    try {
      scriptDef = _scripDefParser.parse((preProcessed ?? rawScript).contentAsYaml);
    } on ParserException catch (e){
      return InvalidScript(rawScript, ScriptMetadata("<Invalid script>", "Invalid script"), e, preProcessed);
    }
    final errorCollector = ErrorCollector();
    dynamic scenes = scriptDef.scenes.map((sceneDef) {
      try {
        Map<String, Extension> extensions = {
          for (var extensionId in sceneDef.metadata.extensionIds) extensionId: _getExtensionsById(extensionId)
        };

        extensions[DefaultExtensionConsts.Id] = _getExtensionsById(DefaultExtensionConsts.Id);

        return Scene(
          sceneDef.metadata,
          _parseRawCommands(sceneDef.initialStateBuilderCommands, extensions, errorCollector),
          _parseRawCommands(sceneDef.transitionCommands, extensions, errorCollector),
        );
      } on ExtensionNotFoundException catch (e) {
        errorCollector.onError(YamlException("Unknown extension '${e.extensionId}' (scene at line ${sceneDef.metadata.scriptLineIndex + 1})", null));
      }
    }).nonNulls.toList(growable: false);

    if (!errorCollector.isEmpty()) return InvalidScript(rawScript, ScriptMetadata("<Invalid script>", "Invalid script"), ParserException(errorCollector.errors), preProcessed);

    return ValidScript(rawScript, scriptDef.metadata, scenes, preProcessed);
  }

  ///Throws error if command cannot be parsed
  Command _parseCommand(YamlNode rawCommand, Map<String, Extension> extensions) {
    final commands = extensions.values.map((extension) {
      RawCommand rawCmd = _parseCommandNode(rawCommand);
      return extension.scripting.buildCommand(rawCmd);
    }).nonNulls.toList();

    if (commands.isEmpty) throw YamlException("Unknown command: '${rawCommand.toString().cap(15)}'", rawCommand.span);

    return commands.first;
  }

  List<Command> _parseRawCommands(YamlList rawCommands, Map<String, Extension> extensions, ErrorCollector errorCollector) {
    return rawCommands.nodes.map((rawCommand) {
      try {
        return _parseCommand(rawCommand, extensions);
      } on YamlException catch (e) {
        errorCollector.onError(e);
      } catch (e) {
        _logger.debug(() => "Error parsing command: ${[rawCommand, extensions]}, error: $e");
        errorCollector.onError(YamlException(e.toString(), rawCommand.span));
      }
    }).nonNulls.toList();
  }

  RawCommand _parseCommandNode(YamlNode rawCommand) {
    YamlNode commandNode = rawCommand;
    final commandMetadata = CommandMetadata(commandNode.span.start.line);

    if (commandNode is YamlScalar || commandNode is String) {
      return RawCommand.literal(commandNode.toString(), metadata: commandMetadata);
    } else if (commandNode is YamlMap) {
      if (commandNode.length > 1) throw YamlException("Invalid command syntax, single key map is required: '${commandNode.toString().cap(15)}'", rawCommand.span);

      var commandName = commandNode.keys.single.toString(); //Catch error if not single
      var valueYamlNode = commandNode.values.single;

      if (valueYamlNode is YamlScalar) {
        return RawCommand.withPositionalArgs(commandName, [valueYamlNode.value], metadata: commandMetadata);
      } else if (valueYamlNode is YamlList) {
        return RawCommand.withPositionalArgs(commandName, YamlUtils.unwrapScalarsInList(valueYamlNode), metadata: commandMetadata);
      } else if (valueYamlNode is YamlMap) {
        return RawCommand.withNamedArgs(commandName, YamlUtils.unwrapScalarsInMap(valueYamlNode), metadata: commandMetadata);
      } else if (valueYamlNode is String || valueYamlNode is num || valueYamlNode is bool) {
        return RawCommand.withPositionalArgs(commandName, [valueYamlNode], metadata: commandMetadata);
      } else {
        throw YamlException("Invalid command syntax: '${commandNode.toString().cap(15)}'", rawCommand.span);
      }
    } else {
      throw YamlException("Invalid command syntax, string or single key map is required: '${commandNode.toString().cap(15)}'", rawCommand.span);
    }
  }
}
