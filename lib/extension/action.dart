

import 'package:visualizeit/extension/domain/extension_repository.dart';
import 'package:visualizeit_extensions/extension.dart';

class GetExtensionById {

  final ExtensionRepository _repository;

  GetExtensionById(ExtensionRepository repository): this._repository = repository;

  Extension call (String id) => _repository.getById(id);
}
