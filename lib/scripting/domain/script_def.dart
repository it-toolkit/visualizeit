
class ScriptMetadata {
  String name;
  String description;
  Set<String> tags;

  ScriptMetadata(this.name, this.description, this.tags);
}

class SceneMetadata {
  String name;
  String description;
  Set<String> extensionIds;

  SceneMetadata(this.name, this.description, this.extensionIds);
}

class SceneDef {
  SceneMetadata metadata;
  List<String> initialStateBuilderCommands;
  List<String> transitionCommands;

  SceneDef(this.metadata, this.initialStateBuilderCommands, this.transitionCommands);
}

class ScriptDef {
  ScriptMetadata metadata;
  List<SceneDef> scenes;

  ScriptDef(this.metadata, this.scenes);
}

