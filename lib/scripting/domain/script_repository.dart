
import 'package:visualizeit/scripting/domain/script_def.dart';

class RawScript {
  ScriptRef ref;
  String contentAsYaml;

  RawScript(this.ref, this.contentAsYaml);

  @override
  bool operator ==(Object other) {
    return identical(this, other)
        || other is RawScript && runtimeType == other.runtimeType && ref == other.ref;
  }

  @override
  int get hashCode => ref.hashCode;
}

class ScriptNotFoundException implements Exception {
  final ScriptRef ref;
  final String message;

  const ScriptNotFoundException(this.ref): message = "Script not found: $ref";

  String toString() => message;
}

typedef ScriptRef = String;

abstract class RawScriptRepository {
  Future<Map<ScriptRef, ScriptMetadata>> fetchAvailableScriptsMetadata();

  Future<RawScript> get(ScriptRef scriptRef);

  Future<List<RawScript>> getAll();

  Future<void> save(RawScript rawScript);
}