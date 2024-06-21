import 'package:visualizeit/scripting/domain/script.dart';

import 'domain/script_repository.dart';

class GetScriptById {
  final ScriptRepository _repository;

  GetScriptById(ScriptRepository repository) : this._repository = repository;

  Future<Script> call(String id) async => await _repository.get(id);
}
