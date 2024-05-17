import 'dart:io';

import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:yaml/yaml.dart';

Builder generateAvailableExtensionsRegistration(BuilderOptions options) {
  return AvailableExtensionsRegistrationBuilder();
}

Map<Uri, String> _detectedExtensionBuilders = {};

class AvailableExtensionsRegistrationBuilder implements Builder {
  static const DependenciesToIgnore = ['flutter', 'build', 'source_gen','cupertino_icons', 'go_router', 'flutter_markdown', 'flutter_bloc'];
  late Set<String> _dependenciesToScan;

  AvailableExtensionsRegistrationBuilder() {
    final yaml = loadYamlDocument(File("pubspec.yaml").readAsStringSync());
    this._dependenciesToScan = ((yaml.contents as YamlMap)['dependencies'] as YamlMap).keys.map((e) => e.toString()).toSet();
    this._dependenciesToScan.removeAll(DependenciesToIgnore);
    this._dependenciesToScan.add((yaml.contents as YamlMap)['name'].toString());
  }

  @override
  final buildExtensions = const {
    '.dart': ['.extension_list']
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final resolver = buildStep.resolver;

    if (!await resolver.isLibrary(buildStep.inputId)) return;

    if(!_dependenciesToScan.contains(buildStep.inputId.package)) return;

    final lib = LibraryReader(await buildStep.inputLibrary);

    List<String> extensionClasses = [];

    for (var cls in lib.classes) {
      if (_implementsInterface(cls, 'ExtensionBuilder')) {
        extensionClasses.add(cls.name);
      }
    }

    if (extensionClasses.isNotEmpty) {
      var extensionDefUri = buildStep.inputId.changeExtension('.dart').uri;
      print("Extensions [$extensionClasses] found at $extensionDefUri");
      _detectedExtensionBuilders[extensionDefUri] = extensionClasses.join(',');
    }
  }

  bool _implementsInterface(ClassElement classElement, String interfaceName) {
    //TODO también contemplar casos de herencia
    return classElement.interfaces.any((interfaceType) => interfaceType.element.name == interfaceName);
  }
}


Builder generateAvailableExtensionsRegistrationList(BuilderOptions options) {
  return AvailableExtensionsRegistrationListBuilder();
}

class AvailableExtensionsRegistrationListBuilder implements Builder {
  static const targetFile = 'extension/build/available_extensions.g.dart';

  @override
  final buildExtensions = const {
    r'$lib$': [targetFile]
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final content = [];
    //Write all package imports
    content.addAll([for (var uri in _detectedExtensionBuilders.keys) 'import \'${uri}\';']);
    content.add('import \'package:visualizeit_extensions/extension.dart\';');

    //Write buildAllAvailableExtensions function definition
    content.addAll([
      '\n\nList<Future<Extension>> buildAllAvailableExtensions() {',
      '\treturn ['
    ]);
    //Write extension registration calls
    final extensionBuilderNames = _detectedExtensionBuilders.values.expand((e) => e.split(","));
    content.addAll([for (var builderClassname in extensionBuilderNames) '\t\t${builderClassname}().build(),']);
    content.addAll([
      '\t];',
      '}'
    ]);

    await buildStep.writeAsString(AssetId(buildStep.inputId.package, "lib/$targetFile"), content.join('\n'));
  }
}