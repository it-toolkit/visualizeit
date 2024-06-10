import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:visualizeit/extension/ui/extension_page.dart';
import 'package:visualizeit/player/ui/player_page.dart';
import 'package:visualizeit/scripting/ui/script_selector_page_v2.dart';

import '../scripting/ui/script_editor_page.dart';

extension GetItWidgets on GetIt {
  void registerWidgets() {
    registerFactoryParam<ExtensionPage, BuildContext, GoRouterState>((context, state) => ExtensionPage(get()));

    registerFactoryParam<ScriptSelectorPage, BuildContext, GoRouterState>((context, routerState) => ScriptSelectorPage(
      get(instanceName: "publicScriptsRepository"),
      get(instanceName: "myScriptsRepository"),
      openScriptInPlayer: (scriptId, readonly) => context.push("/scripts/$scriptId/play", extra: { "readonly": readonly }),
      openScriptInEditor: (scriptId, readonly) => context.push("/scripts/$scriptId/edit", extra: { "readonly": readonly }),
    ));

    registerFactoryParam<ScriptEditorPage, BuildContext, GoRouterState>((context, state) {
      final scriptId = state.pathParameters['sid']!;
      final extras = state.extra as Map<String, dynamic>;

      return ScriptEditorPage(
        get(), get(), get(),
        scriptId: scriptId,
        readOnly: extras["readonly"] ?? true,
        openScriptInPlayer: (scriptId, readonly) => context.push("/scripts/$scriptId/play", extra: { "readonly": readonly }),
      );
    });

    registerFactoryParam<PlayerPage, BuildContext, GoRouterState>((context, state) {
      final scriptId = state.pathParameters['sid']!;
      final extras = state.extra as Map<String, dynamic>;

      return PlayerPage(
          get(), get(), get(),
          scriptId: scriptId,
          readOnly: extras["readonly"] ?? true,
      );
    });
  }
}
