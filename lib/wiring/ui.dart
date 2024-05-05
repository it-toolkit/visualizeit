

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:visualizeit/extension/ui/extension_page.dart';

extension GetItWidgets on GetIt {
  void registerWidgets() {

    registerFactoryParam<ExtensionPage, BuildContext, GoRouterState>((context, routerState) => ExtensionPage(get()));
  }
}