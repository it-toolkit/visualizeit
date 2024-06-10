import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:visualizeit/extension/domain/extension_repository.dart';
import 'package:visualizeit/extension/infrastructure/extension_repository.dart';
import 'package:visualizeit/scripting/domain/script_repository.dart';

import '../scripting/infrastructure/script_repository.dart';

extension GetItRepositories on GetIt {
  void registerRepositories() {
    registerSingleton<RawScriptRepository>(kReleaseMode
        ? InMemoryRawScriptRepository() //TODO use remote repository
        : InMemoryRawScriptRepository(
            initialRawScriptsLoader: _loadExampleScriptsFromAssets()),
      instanceName: "publicScriptsRepository"
    );

    registerSingleton<RawScriptRepository>(
        InMemoryRawScriptRepository(), //TODO use remote repository
        instanceName: "myScriptsRepository"
    );

    registerSingleton<RawScriptRepository>(
        CompositeRawScriptRepository([get(instanceName: "publicScriptsRepository"), get(instanceName: "myScriptsRepository")])
    );

    registerSingletonAsync<ExtensionRepository>(
        () async => await DefaultExtensionRepository.withAvailableExtensions());
  }

  Future<List<RawScript>> _loadExampleScriptsFromAssets() async {
    final assetKeys = [
      "assets/script_examples/visualizeit_intro.yaml",
      "assets/script_examples/extension_template_example.yaml",
      "assets/script_examples/global_commands_example.yaml",
      "assets/script_examples/extension_slides_example.yaml",
      "assets/script_examples/extension_bsharptree_example.yaml",
      "assets/script_examples/bsharptree_example_with_explanation.yaml",
      "assets/script_examples/extension_externalsort_example.yaml"
    ];
    return Future.wait(assetKeys.map((key) async =>
        RawScript(key.hashCode.toString(), await rootBundle.loadString(key))));
  }
}
