import 'domain/script_repository.dart';

class GetRawScriptById {
  final RawScriptRepository _repository;

  GetRawScriptById(RawScriptRepository repository) : this._repository = repository;

  Future<RawScript> call(String id) async => await _repository.get(id);
}
