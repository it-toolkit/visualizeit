import 'package:flutter/foundation.dart';
import 'package:visualizeit/scripting/domain/script_def.dart';
import 'package:visualizeit/scripting/domain/script_repository.dart';
import 'package:visualizeit_extensions/common.dart';

class Scene {
  SceneMetadata metadata;
  List<Command> initialStateBuilderCommands;
  List<Command> transitionCommands;

  Scene(this.metadata, this.initialStateBuilderCommands, this.transitionCommands);

  Scene clone() {
    return Scene(metadata, initialStateBuilderCommands, transitionCommands);
  }
}

@immutable
class Script {
  final RawScript raw;
  final ScriptMetadata metadata;
  final List<Scene> scenes;

  Script(this.raw, this.metadata, this.scenes);

  Script clone() {
    return Script(raw.clone(), metadata.clone(), scenes.map((it) => it.clone()).toList());
  }
}

