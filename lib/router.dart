

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:visualizeit/player/ui/player_page.dart';
import 'package:visualizeit/scripting/domain/parser.dart';
import 'package:visualizeit/scripting/domain/script_repository.dart';
import 'package:visualizeit/scripting/ui/script_editor_page.dart';
import 'package:visualizeit/scripting/ui/script_selector_page.dart';
import 'package:visualizeit/user/ui/signin_page.dart';
import 'package:visualizeit_extensions/logging.dart';

import 'extension/domain/action.dart';
import 'extension/ui/extension_page.dart';
import 'misc/ui/help_page.dart';


final _logger = Logger("base.ui");

abstract class AppEvent {}

class NavigationEvent extends AppEvent {
  final String destinationName;

  NavigationEvent(this.destinationName);
}

class AppState {
  final GoRouter router;

  AppState(this.router);
}

class AppBloc extends Bloc<AppEvent, AppState> {

  AppBloc() : super(AppState(_router)) {
    on<NavigationEvent>((event, emit) {
      state.router.goNamed(event.destinationName);
    });
  }
}

/// The route configuration.
final GoRouter _router = GoRouter(
  onException: (BuildContext context, GoRouterState state, GoRouter router) {
    //TODO handle errors properly
    print("Unexpected route!!!");
    router.go("/");
  },
  routes: <RouteBase>[
    GoRoute(
      name: ScriptSelectorPage.RouteName,
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        final rawScriptRepository = context.read<RawScriptRepository>();
        return ScriptSelectorPage(
          rawScriptRepository,
          onPlayPressed: (scriptId) => {context.go("/scripts/$scriptId/play")},
          onViewPressed: (scriptId) => {context.go("/scripts/$scriptId/edit")},
        );
      },
      routes: <RouteBase>[
        GoRoute(
          name: ScriptEditorPage.RouteName,
          path: 'scripts/:sid/edit',
          builder: (BuildContext context, GoRouterState state) {
            final scriptId = state.pathParameters['sid']!;
            return ScriptEditorPage(
              scriptId: scriptId,
              onPlayPressed: (scriptId) => {context.go("/scripts/$scriptId/play")},
            );
          },
        ),
        GoRoute(
          name: ExtensionPage.RouteName,
          path: 'extensions',
          builder: (BuildContext context, GoRouterState state) => ExtensionPage(),
        ),
        GoRoute(
          name: SignInPage.RouteName,
          path: 'sign-in',
          builder: (BuildContext context, GoRouterState state) => const SignInPage(),
        ),
        GoRoute(
          path: 'scripts/:sid/play',
          builder: (BuildContext context, GoRouterState state) {
            final scriptId = state.pathParameters['sid']!;
            final rawScriptRepository = context.read<RawScriptRepository>();
            final rawScriptFuture = rawScriptRepository.get(scriptId);

            return FutureBuilder<RawScript>( future: rawScriptFuture, builder: (BuildContext context, AsyncSnapshot<RawScript> rawScript) {
              if(rawScript.hasError) {
                //TODO handle error Ferman
                // context.go("/");
                return Text("Error: ${rawScript.error.toString()}");
              } else if (!rawScript.hasData) {
                return CircularProgressIndicator();
              } else {
                String contentAsYaml = rawScript.data!.contentAsYaml;
                final getExtensionById = context.read<GetExtensionById>();
                var script = ScriptParser(getExtensionById).parse(contentAsYaml);

                return PlayerPage(script: script);
              }
            });
          },
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