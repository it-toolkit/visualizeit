

import 'package:yaml/yaml.dart';

class ScriptMetadata {
  String name;
  String description;
  Set<String> tags;

  ScriptMetadata(this.name, this.description, this.tags);

  @override
  String toString() {
    return 'ScriptMetadata{name: $name, description: $description, tags: $tags}';
  }
}

class SceneMetadata {
  String name;
  String description;
  Set<String> extensionIds;
  String rawYaml;
  int scriptLineIndex;

  SceneMetadata(this.name, this.description, this.extensionIds, this.rawYaml, this.scriptLineIndex);
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

