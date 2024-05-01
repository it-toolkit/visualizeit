

import 'package:visualizeit_extensions/extension.dart';

import '../build/available_extensions.g.dart';

class GetExtensionById {
  final Map<String, Extension> _extensions = Map.fromIterable(
    buildAllAvailableExtensions(),
    key : (e) => e.extensionId,
    value: (e) => e,
  );

  GetExtensionById({Map<String, Extension> extensions = const {} }) {
    _extensions.addAll(extensions);
  }

  Extension call (String id) {
    var extension = _extensions[id];
    if (extension is !Extension) throw Exception("Extension not found for id [$id]");

    return extension;
  }
}
