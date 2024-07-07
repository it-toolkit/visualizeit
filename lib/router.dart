import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:visualizeit/extension/ui/extension_page.dart';
import 'package:visualizeit/misc/ui/help_page.dart';
import 'package:visualizeit/player/ui/player_page.dart';
import 'package:visualizeit/scripting/ui/script_editor_page.dart';
import 'package:visualizeit/scripting/ui/script_selector_page.dart';
import 'package:visualizeit_extensions/logging.dart';

final _logger = Logger("base.ui");

/// The route configuration.
final GoRouter router = GoRouter(
  onException: (BuildContext context, GoRouterState state, GoRouter router) {
    _logger.warn(() => "Routing error: ${state.error}");
    router.go("/");
  },
  routes: <RouteBase>[
    GoRoute(
      name: ScriptSelectorPage.RouteName,
      path: '/',
      builder: (context, state) => GetIt.I.get<ScriptSelectorPage>(param1: context, param2: state),
      routes: <RouteBase>[
        GoRoute(
          name: ScriptEditorPage.RouteName,
          path: 'scripts/:sid/edit',
          builder: (context, state) => GetIt.I.get<ScriptEditorPage>(param1: context, param2: state),
        ),
        GoRoute(
          name: ExtensionPage.RouteName,
          path: 'extensions',
          builder: (BuildContext context, GoRouterState state) => GetIt.I.get<ExtensionPage>(param1: context, param2: state),
        ),
        GoRoute(
          path: 'scripts/:sid/play',
          builder: (context, state) => GetIt.I.get<PlayerPage>(param1: context, param2: state),
        ),
        GoRoute(
          name: HelpPage.RouteName,
          path: 'help',
          builder: (BuildContext context, GoRouterState state) => const HelpPage(),
        )
      ],
    ),
  ],
);
