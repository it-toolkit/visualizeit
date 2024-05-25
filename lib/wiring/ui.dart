import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:visualizeit/extension/ui/extension_page.dart';
import 'package:visualizeit/player/ui/player_page.dart';
import 'package:visualizeit/scripting/ui/script_selector_page.dart';

import '../scripting/ui/script_editor_page.dart';

extension GetItWidgets on GetIt {
  void registerWidgets() {
    registerFactoryParam<ExtensionPage, BuildContext, GoRouterState>((context, state) => ExtensionPage(get()));

    registerFactoryParam<ScriptSelectorPage, BuildContext, GoRouterState>((context, routerState) => ScriptSelectorPage(
      get(),
      onPlayPressed: (scriptId) => {context.go("/scripts/$scriptId/play")},
      onViewPressed: (scriptId) => {context.go("/scripts/$scriptId/edit")},
    ));

    registerFactoryParam<ScriptEditorPage, BuildContext, GoRouterState>((context, state) {
      final scriptId = state.pathParameters['sid']!;
      return ScriptEditorPage(
        get(), get(), get(),
        scriptId: scriptId,
        onPlayPressed: (scriptId) => {context.go("/scripts/$scriptId/play")}
      );
    });

    registerFactoryParam<PlayerPage, BuildContext, GoRouterState>((context, state) {
      final scriptId = state.pathParameters['sid']!;
      return PlayerPage(get(), get(), get(), scriptId: scriptId);
    });
  }
}
