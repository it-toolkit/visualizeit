

import 'package:get_it/get_it.dart';

import '../extension/action.dart';
import '../scripting/action.dart';

extension GetItActions on GetIt {
  void registerActions() {

    registerLazySingleton<GetExtensionById>(() => GetExtensionById(get()));

    registerLazySingleton<GetRawScriptById>(() => GetRawScriptById(get()));
  }
}