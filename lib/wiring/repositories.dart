import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:visualizeit/extension/domain/extension_repository.dart';
import 'package:visualizeit/extension/infrastructure/extension_repository.dart';
import 'package:visualizeit/scripting/domain/script_repository.dart';

import '../scripting/infrastructure/script_repository.dart';

extension GetItRepositories on GetIt {
  void registerRepositories() {
    registerLazySingleton<ScriptRepository>(() =>
        InMemoryScriptRepository(get(), initialRawScriptsLoader: _loadScriptsFromAssets(_publicScriptKeys)),
        instanceName: "publicScriptsRepository"
    );

    registerLazySingleton<ScriptRepository>(() =>
        InMemoryScriptRepository(get()),
        instanceName: "myScriptsRepository"
    );

    registerLazySingleton<ScriptRepository>( ()=>
        CompositeScriptRepository(get(instanceName: "publicScriptsRepository"), get(instanceName: "myScriptsRepository"))
    );

    registerSingletonAsync<ExtensionRepository>(
        () async => await DefaultExtensionRepository.withAvailableExtensions());
  }

  Future<List<RawScript>> _loadScriptsFromAssets(List<String> assetKeys) async {
    return Future.wait(assetKeys.map((key) async =>
        RawScript(key.hashCode.toString(), await rootBundle.loadString(key))));
  }

  static final _publicScriptKeys = [
    "assets/script_examples/visualizeit_intro.yaml",
    "assets/script_examples/bsharptree_example_with_explanation.yaml",
    "assets/script_examples/extension_externalsort_example.yaml",
    "assets/script_examples/global_commands_example.yaml",
    "assets/script_examples/multi_scene_example.yaml",
    "assets/script_examples/extension_slides_example.yaml",
    "assets/script_examples/extension_bsharptree_example.yaml",
    "assets/script_examples/extension_bsharptree_incremental_example.yaml",
    "assets/script_examples/extension_template_example.yaml",
    "assets/script_examples/extension_extendiblehashing_bucket_overflow_example.yaml",
    "assets/script_examples/extension_extendiblehashing_hashtable_update_example.yaml",
    "assets/script_examples/extension_extendiblehashing_bucket_freed_example.yaml",
    "assets/script_examples/extension_extendiblehashing_bucket_empty_example.yaml",
  ];
}
