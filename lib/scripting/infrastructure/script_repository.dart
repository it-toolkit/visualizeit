

import 'package:visualizeit/scripting/domain/parser.dart';
import 'package:visualizeit/scripting/domain/script_def.dart';
import 'package:visualizeit/scripting/domain/script_repository.dart';

class InMemoryRawScriptRepository implements RawScriptRepository {
  final _scriptDefParser = ScriptDefParser();
  final Map<ScriptRef, RawScript> _rawScripts;

  InMemoryRawScriptRepository({List<RawScript> rawScripts = const []})
      : _rawScripts  = <ScriptRef, RawScript>{for (var v in rawScripts) v.ref: v};

  @override
  Future<Map<ScriptRef, ScriptMetadata>> fetchAvailableScriptsMetadata() async {
    return _rawScripts.map((key, value) {
      return MapEntry(key, _scriptDefParser.parse(value.contentAsYaml).metadata);
    });
  }

  @override
  Future<RawScript> get(ScriptRef id) async {
    if (!_rawScripts.containsKey(id)) throw ScriptNotFoundException(id);

    return _rawScripts[id]!;
  }

  @override
  Future<List<RawScript>> getAll() async {
    return _rawScripts.values.toList();
  }

  @override
  Future<void> save(RawScript rawScript) async {
    _rawScripts[rawScript.ref] = rawScript;
  }
}