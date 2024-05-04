

import 'package:visualizeit_extensions/extension.dart';

import '../build/available_extensions.g.dart';

class GetExtensionById {
  final Map<String, Extension> _extensions;

  GetExtensionById({Map<String, Extension> extensions = const {}}): this._extensions = extensions;

  static Future<GetExtensionById> withAvailableExtensions({Map<String, Extension> extensions = const {}}) async {
    final Map<String, Extension> availableExtensions = Map.fromIterable(
      await Future.wait(buildAllAvailableExtensions()),
      key: (e) => e.extensionId,
      value: (e) => e,
    );

    return GetExtensionById(extensions: Map.of(extensions)..addAll(availableExtensions));
  }

  Extension call (String id) {
    var extension = _extensions[id];
    if (extension is !Extension) throw Exception("Extension not found for id [$id]");

    return extension;
  }
}
