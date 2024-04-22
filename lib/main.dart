import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:visualizeit/extension/ui/extension_page.dart';
import 'package:visualizeit/misc/ui/help_page.dart';
import 'package:visualizeit/player/ui/player_page.dart';
import 'package:visualizeit/scripting/domain/parser.dart';
import 'package:visualizeit/scripting/domain/script_repository.dart';
import 'package:visualizeit/scripting/infrastructure/script_repository.dart';
import 'package:visualizeit/user/ui/signin_page.dart';
import 'package:visualizeit/scripting/ui/script_editor_page.dart';
import 'package:visualizeit/scripting/ui/script_selector_page.dart';

import 'extension/domain/action.dart';
import 'fake_data.dart';

void main() => runApp(const VisualizeItApp());

/// The route configuration.
final GoRouter _router = GoRouter(
  onException: (BuildContext context, GoRouterState state, GoRouter router) {
    //TODO handle errors properly
    print("Unexpected route!!!");
    router.go("/");
  },
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        final rawScriptRepository = context.read<RawScriptRepository>();
        return ScriptSelectorPage(
            rawScriptRepository,
            onPlayPressed: (scriptId) => {context.go("/scripts/$scriptId/play")},
            onViewPressed: (scriptId) => {context.go("/scripts/$scriptId/edit")},
            onHelpPressed: () => {context.go("/help")},
            onSignInPressed: () => {context.go("/sign-in")},
            onExtensionsPressed: () => {context.go("/extensions")},
        );
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'scripts/:sid/edit',
          builder: (BuildContext context, GoRouterState state) {
            final scriptId = state.pathParameters['sid']!;
            return ScriptEditorPage(
              scriptId: scriptId,
              onHelpPressed: () => {context.go("/help")},
              onSignInPressed: () => {context.go("/sign-in")},
              onExtensionsPressed: () => {context.go("/extensions")},
              onPlayPressed: (scriptId) => {context.go("/scripts/$scriptId/play")},
            );
          },
        ),
        GoRoute(
          path: 'extensions',
          builder: (BuildContext context, GoRouterState state) {
            return ExtensionPage(onHelpPressed: () => {context.go("/help")});
          },
        ),
        GoRoute(
          path: 'sign-in',
          builder: (BuildContext context, GoRouterState state) {
            return const SignInPage();
          },
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

                return PlayerPage(
                    script: script,
                    onHelpPressed: () => {context.go("/help")},
                    onSignInPressed: () => {context.go("/sign-in")},
                    onExtensionsPressed: () => {context.go("/extensions")});
              }
            });
          },
        ),
        GoRoute(
          path: 'help',
          builder: (BuildContext context, GoRouterState state) {
            return const HelpPage();
          },
        )
      ],
    ),
  ],
);

/// The main app.
class VisualizeItApp extends StatelessWidget {

  /// Constructs a [VisualizeItApp]
  const VisualizeItApp();

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
        providers: [
          RepositoryProvider<RawScriptRepository> (create: (context) => InMemoryRawScriptRepository(rawScripts: [RawScript("1", validRawScriptYaml)])),
          RepositoryProvider<GetExtensionById> (create: (context) => GetExtensionById()),
        ],
        child: MaterialApp.router(
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              colorScheme: const ColorScheme.light(),
              useMaterial3: true,
              scrollbarTheme: ScrollbarThemeData(
                thumbVisibility: MaterialStateProperty.all(true), //Always show scrollbar
              )),
        ));
  }
}
