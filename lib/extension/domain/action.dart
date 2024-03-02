

import 'package:visualizeit/extension/domain/default/default_extension.dart';
import 'package:visualizeit_extensions/extension.dart';

class GetExtensionById {
  final Map<String, Extension> _extensions = {
    DefaultExtensionConsts.Id : buildDefaultExtension()
  };

  GetExtensionById({Map<String, Extension> extensions = const {} }) {
    _extensions.addAll(extensions);
  }

  Extension call (String id) {
    var extension = _extensions[id];
    if (extension is !Extension) throw Exception("Extension not found for id [$id]");

    return extension;
  }
}
