

import 'package:visualizeit/scripting/domain/parser.dart';
import 'package:visualizeit/scripting/domain/script_def.dart';
import 'package:visualizeit/scripting/domain/script_repository.dart';

class InMemoryRawScriptRepository implements RawScriptRepository {
  final _scriptDefParser = ScriptDefParser();
  Map<ScriptRef, RawScript>? _storedRawScripts = null;

  Future<List<RawScript>>? initialRawScriptsLoader;

  InMemoryRawScriptRepository({Future<List<RawScript>>? this.initialRawScriptsLoader = null})
      : _storedRawScripts = initialRawScriptsLoader == null ? {} : null;

  Future<Map<ScriptRef, RawScript>> getStoredRawScripts() async {
    if(_storedRawScripts != null) return _storedRawScripts!;

    if(initialRawScriptsLoader != null) {
      var rawScriptsList = await initialRawScriptsLoader!;
      _storedRawScripts =  <ScriptRef, RawScript>{for (var v in rawScriptsList) v.ref: v};
    } else {
      _storedRawScripts = {};
    }
    return _storedRawScripts!;
  }

  @override
  Future<Map<ScriptRef, ScriptMetadata>> fetchAvailableScriptsMetadata() async {
    final _rawScripts = await getStoredRawScripts();
    return _rawScripts.map((key, value) {
      return MapEntry(key, _scriptDefParser.parse(value.contentAsYaml).metadata);
    });
  }

  @override
  Future<RawScript> get(ScriptRef id) async {
    final _rawScripts = (await getStoredRawScripts());
    if (!_rawScripts.containsKey(id)) throw ScriptNotFoundException(id);

    return _rawScripts[id]!;
  }

  @override
  Future<List<RawScript>> getAll() async {
    final _rawScripts = (await getStoredRawScripts());
    return _rawScripts.values.toList();
  }

  @override
  Future<void> save(RawScript rawScript) async {
    final _rawScripts = (await getStoredRawScripts());
    _rawScripts[rawScript.ref] = rawScript;
  }
}