

import 'package:visualizeit/scripting/domain/parser.dart';
import 'package:visualizeit/scripting/domain/script.dart';
import 'package:visualizeit/scripting/domain/script_def.dart';
import 'package:visualizeit/scripting/domain/script_repository.dart';

class InMemoryScriptRepository implements ScriptRepository {
  final ScriptParser _scriptParser;
  Map<ScriptRef, RawScript>? _storedRawScripts = null;
  Future<List<RawScript>>? initialRawScriptsLoader;

  InMemoryScriptRepository(this._scriptParser, {Future<List<RawScript>>? this.initialRawScriptsLoader = null})
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
      return MapEntry(key, _scriptParser.parse(value).metadata);
    });
  }

  @override
  Future<Script> get(ScriptRef id) async {
    final _rawScripts = (await getStoredRawScripts());
    if (!_rawScripts.containsKey(id)) throw ScriptNotFoundException(id);

    return _scriptParser.parse(_rawScripts[id]!);
  }

  @override
  Future<List<Script>> getAll() async {
    final _rawScripts = (await getStoredRawScripts());
    return _rawScripts.values.map(_scriptParser.parse).toList();
  }

  @override
  Future<Script> save(RawScript rawScript) async {
    final parsedScript = _scriptParser.parse(rawScript); //Fails if script is invalid
    final _rawScripts = (await getStoredRawScripts());
    _rawScripts[rawScript.ref] = rawScript;

    return parsedScript;
  }

  @override
  Future<Script> delete(ScriptRef id) async {
    final _rawScripts = (await getStoredRawScripts());
    final deleted = _rawScripts.remove(id);
    if (deleted == null) throw ScriptNotFoundException(id);

    return _scriptParser.parse(deleted);
  }
}