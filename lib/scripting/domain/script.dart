import 'package:flutter/foundation.dart';
import 'package:visualizeit/scripting/domain/parser.dart';
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

sealed class Script {
  final RawScript raw;
  final RawScript? preProcessed;
  final ScriptMetadata metadata;

  Script(this.raw, this.metadata, [this.preProcessed]);

  Script clone();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Script && runtimeType == other.runtimeType && raw.ref == other.raw.ref && metadata == other.metadata;

  @override
  int get hashCode => raw.ref.hashCode ^ metadata.hashCode;

  @override
  String toString() {
    return 'Script{name: ${metadata.name}, isValid: ${this is ValidScript}, ref:${raw.ref}';
  }
}

@immutable
class ValidScript extends Script {
  final List<Scene> scenes;

  ValidScript(super.raw, super.metadata, this.scenes, [super.preProcessed]);

  ValidScript clone() {
    return ValidScript(raw.clone(), metadata.clone(), scenes.map((it) => it.clone()).toList(), preProcessed?.clone());
  }
}

@immutable
class InvalidScript extends Script {
  final ParserException parserError;

  InvalidScript(super.raw, super.metadata, this.parserError, [super.preProcessed]);

  InvalidScript clone() {
    return InvalidScript(raw.clone(), metadata.clone(), parserError, preProcessed?.clone());
  }
}
