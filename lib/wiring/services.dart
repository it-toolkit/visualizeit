

import 'package:get_it/get_it.dart';
import 'package:visualizeit/scripting/domain/parser.dart';
import 'package:visualizeit/scripting/domain/script_preprocessor.dart';

extension GetItServices on GetIt {
  void registerServices() {
    registerLazySingleton<ScriptParser>(() => ScriptParser(get(), RawScriptPreprocessor()));
  }
}