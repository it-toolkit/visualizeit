import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:visualizeit/extension/ui/extension_page.dart';
import 'package:visualizeit/misc/ui/help_page.dart';
import 'package:visualizeit/player/ui/player_page.dart';
import 'package:visualizeit/scripting/ui/script_editor_page.dart';
import 'package:visualizeit/scripting/ui/script_selector_page_v2.dart';
import 'package:visualizeit/user/ui/signin_page.dart';
import 'package:visualizeit_extensions/logging.dart';

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
          name: SignInPage.RouteName,
          path: 'sign-in',
          builder: (BuildContext context, GoRouterState state) => const SignInPage(),
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
