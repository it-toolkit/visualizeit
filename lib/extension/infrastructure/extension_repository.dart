

import 'package:visualizeit/extension/build/available_extensions.g.dart';
import 'package:visualizeit/extension/domain/extension_repository.dart';
import 'package:visualizeit_extensions/extension.dart';


class DefaultExtensionRepository implements ExtensionRepository {
  final Map<String, Extension> _extensionsById;
  final List<Extension> _extensions;

  DefaultExtensionRepository({List<Extension> extensions = const []}):
        this._extensionsById = { for (var e in extensions) e.id: e },
        this._extensions = List.unmodifiable(extensions);

  static Future<DefaultExtensionRepository> withAvailableExtensions({List<Extension> extensions = const []}) async {
    final availableExtensions = List.of(extensions);
    availableExtensions.addAll(await Future.wait(buildAllAvailableExtensions()));
    return DefaultExtensionRepository(extensions: availableExtensions);
  }

  @override
  Extension getById(String id) {
    var extension = _extensionsById[id];
    if (extension == null) throw ExtensionNotFoundException(id);

    return extension;
  }

  @override
  List<Extension> getAll() => _extensions;
}
