import 'package:visualizeit/scripting/domain/script_def.dart';
import 'package:visualizeit_extensions/common.dart';

class Scene {
  SceneMetadata metadata;
  Model model;
  List<Command> transitionCommands;

  Scene(this.metadata, this.model, this.transitionCommands);
}

class Script {
  ScriptMetadata metadata;
  List<Scene> scenes;

  Script(this.metadata, this.scenes);
}

