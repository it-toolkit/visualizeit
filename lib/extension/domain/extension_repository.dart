
import 'package:visualizeit_extensions/extension.dart';

abstract class ExtensionRepository {
  Extension getById (String id);

  List<Extension> getAll();
}

class ExtensionNotFoundException implements Exception {
  final String extensionId;
  final String message;

  const ExtensionNotFoundException(this.extensionId): message = "Extension not found for id [$extensionId]";

  String toString() => message;
}
