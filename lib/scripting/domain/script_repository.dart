
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

  RawScript clone() => RawScript(ref, contentAsYaml);
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

class CompositeRawScriptRepository implements RawScriptRepository {
  final List<RawScriptRepository> delegates;

  CompositeRawScriptRepository(this.delegates);

  @override
  Future<Map<ScriptRef, ScriptMetadata>> fetchAvailableScriptsMetadata() {
    return Future.wait(delegates.map((r) => r.fetchAvailableScriptsMetadata()))
        .then((availableScriptsMetadataMaps) {
      return availableScriptsMetadataMaps.fold<Map<String, ScriptMetadata>>({}, (previousValue, other) => previousValue..addAll(other));
    });
  }

  @override
  Future<RawScript> get(ScriptRef scriptRef) {
    return Future.wait(delegates.map((r) {
      return r.get(scriptRef).then((value) => value as RawScript?).catchError((e) => null);
    })).then((values) {
      return Future.value(values.firstWhere((script) => script != null, orElse: () => throw ScriptNotFoundException(scriptRef)));
    });
  }

  @override
  Future<List<RawScript>> getAll() {
    return Future.wait(delegates.map((r) => r.getAll())).then((values) {
      return Future.value(values.expand((e) => e).toList());
    });
  }

  @override
  Future<void> save(RawScript rawScript) {
    throw UnimplementedError(); //TODO
  }
}