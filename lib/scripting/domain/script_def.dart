
import 'package:source_span/source_span.dart';
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
  final int? titleDuration;
  final int? baseFrameDurationInMillis;
  final SourceSpan span;

  SceneMetadata(this.name, this.description, this.extensionIds, this.span, [this.titleDuration, this.baseFrameDurationInMillis]);

  int get scriptLineIndex => span.start.line;

  SceneMetadata clone() {
    return SceneMetadata(name, description, extensionIds, span, titleDuration, baseFrameDurationInMillis);
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

