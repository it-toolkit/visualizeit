

import 'package:flutter/foundation.dart';
import 'package:yaml/yaml.dart';

@immutable
class ScriptMetadata {
  final String name;
  final String description;
  final Set<String> tags;
  final String? group;

  ScriptMetadata(this.name, this.description, this.tags, {this.group});

  @override
  String toString() {
    return 'ScriptMetadata{name: $name, description: $description, tags: $tags, group: $group}';
  }

  ScriptMetadata clone() {
    return ScriptMetadata(name, description, Set.from(tags), group: group);
  }
}

@immutable
class SceneMetadata {
  final String name;
  final String description;
  final Set<String> extensionIds;
  final String rawYaml;
  final int scriptLineIndex;

  SceneMetadata(this.name, this.description, this.extensionIds, this.rawYaml, this.scriptLineIndex);

  SceneMetadata clone() {
    return SceneMetadata(name, description, extensionIds, rawYaml, scriptLineIndex);
  }
}

class SceneDef {
  SceneMetadata metadata;
  YamlList initialStateBuilderCommands;
  YamlList transitionCommands;

  SceneDef(this.metadata, this.initialStateBuilderCommands, this.transitionCommands);
}

class ScriptDef {
  ScriptMetadata metadata;
  List<SceneDef> scenes;

  ScriptDef(this.metadata, this.scenes);
}

