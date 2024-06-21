
import 'package:flutter/foundation.dart';
import 'package:visualizeit/scripting/domain/script.dart';
import 'package:visualizeit/scripting/domain/script_def.dart';

@immutable
class RawScript {
  final ScriptRef ref;
  final String contentAsYaml;

  RawScript(this.ref, this.contentAsYaml);

  @override
  bool operator ==(Object other) {
    return identical(this, other)
        || other is RawScript && runtimeType == other.runtimeType && ref == other.ref;
  }

  @override
  int get hashCode => ref.hashCode;

  RawScript clone() => RawScript(ref, contentAsYaml);

  RawScript copyWith({required String contentAsYaml}) {
    return RawScript(ref, contentAsYaml);
  }
}

class ScriptNotFoundException implements Exception {
  final ScriptRef ref;
  final String message;

  const ScriptNotFoundException(this.ref): message = "Script not found: $ref";

  String toString() => message;
}

typedef ScriptRef = String;

abstract class ScriptRepository {
  Future<Map<ScriptRef, ScriptMetadata>> fetchAvailableScriptsMetadata();

  Future<Script> get(ScriptRef scriptRef);

  Future<List<Script>> getAll();

  Future<Script> save(RawScript rawScript);

  Future<Script> delete(ScriptRef scriptRef);
}

class CompositeScriptRepository implements ScriptRepository {
  final ScriptRepository publicRepository; //Read only
  final ScriptRepository myScriptsRepository; //Read/Write
  final List<ScriptRepository> delegates;

  CompositeScriptRepository(this.publicRepository, this.myScriptsRepository)
      : this.delegates = [publicRepository, myScriptsRepository];

  @override
  Future<Map<ScriptRef, ScriptMetadata>> fetchAvailableScriptsMetadata() {
    return Future.wait(delegates.map((r) => r.fetchAvailableScriptsMetadata()))
        .then((availableScriptsMetadataMaps) {
      return availableScriptsMetadataMaps.fold<Map<String, ScriptMetadata>>({}, (previousValue, other) => previousValue..addAll(other));
    });
  }

  @override
  Future<Script> get(ScriptRef scriptRef) {
    return Future.wait(delegates.map((r) {
      return r.get(scriptRef).then((value) => value as Script?).catchError((e) => null);
    })).then((values) {
      return Future.value(values.firstWhere((script) => script != null, orElse: () => throw ScriptNotFoundException(scriptRef)));
    });
  }

  @override
  Future<List<Script>> getAll() {
    return Future.wait(delegates.map((r) => r.getAll())).then((values) {
      return Future.value(values.expand((e) => e).toList());
    });
  }

  @override
  Future<Script> save(RawScript rawScript) {
    return myScriptsRepository.save(rawScript);
  }

  @override
  Future<Script> delete(ScriptRef scriptRef) {
    return myScriptsRepository.delete(scriptRef);
  }
}