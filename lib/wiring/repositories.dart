import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:visualizeit/extension/domain/extension_repository.dart';
import 'package:visualizeit/extension/infrastructure/extension_repository.dart';
import 'package:visualizeit/scripting/domain/script_repository.dart';

import '../scripting/infrastructure/script_repository.dart';

extension GetItRepositories on GetIt {
  void registerRepositories() {
    registerLazySingleton<ScriptRepository>(() => kReleaseMode
        ? InMemoryScriptRepository(get()) //TODO use remote repository
        : InMemoryScriptRepository(
            get(),
            initialRawScriptsLoader: _loadExampleScriptsFromAssets()),
            instanceName: "publicScriptsRepository"
        );

    registerLazySingleton<ScriptRepository>(() =>
        InMemoryScriptRepository(get()), //TODO use remote repository
        instanceName: "myScriptsRepository"
    );

    registerLazySingleton<ScriptRepository>( ()=>
        CompositeScriptRepository(get(instanceName: "publicScriptsRepository"), get(instanceName: "myScriptsRepository"))
    );

    registerSingletonAsync<ExtensionRepository>(
        () async => await DefaultExtensionRepository.withAvailableExtensions());
  }

  Future<List<RawScript>> _loadExampleScriptsFromAssets() async {
    final assetKeys = [
      "assets/script_examples/visualizeit_intro.yaml",
      "assets/script_examples/bsharptree_example_with_explanation.yaml",
      "assets/script_examples/extension_externalsort_example.yaml",
      "assets/script_examples/global_commands_example.yaml",
      "assets/script_examples/extension_slides_example.yaml",
      "assets/script_examples/extension_bsharptree_example.yaml",
      "assets/script_examples/extension_bsharptree_incremental_example.yaml",
      "assets/script_examples/extension_template_example.yaml",
      "assets/script_examples/extension_extendiblehashing_example.yaml",
      "assets/script_examples/extension_extendiblehashing_remove_sample.yaml",
      "assets/script_examples/extension_extendiblehashing_second_insertion_algorithm_example.yaml",
      "assets/script_examples/extension_extendiblehashing_second_remove_example.yaml",
    ];
    return Future.wait(assetKeys.map((key) async =>
        RawScript(key.hashCode.toString(), await rootBundle.loadString(key))));
  }
}
