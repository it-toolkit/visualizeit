

import 'package:get_it/get_it.dart';

import '../extension/action.dart';

extension GetItActions on GetIt {
  void registerActions() {

    registerLazySingleton<GetExtensionById>(() => GetExtensionById(get()));
  }
}