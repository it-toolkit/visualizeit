import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:visualizeit/pages/extension_page.dart';
import 'package:visualizeit/pages/help_page.dart';
import 'package:visualizeit/pages/player_page.dart';
import 'package:visualizeit/pages/signin_page.dart';
import 'package:visualizeit/pages/script_editor.dart';
import 'package:visualizeit/pages/script_selector.dart';

void main() => runApp(const VisualizeItApp());

/// The route configuration.
final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return ScriptSelectorPage(
            onPlayPressed: (scriptId) => {context.go("/scripts/$scriptId/play")},
            onViewPressed: (scriptId) => {context.go("/scripts/$scriptId/edit")},
            onHelpPressed: () => {context.go("/help")},
            onSignInPressed: () => {context.go("/sign-in")},
            onExtensionsPressed: () => {context.go("/extensions")});
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
            return PlayerPage(
                scriptId: scriptId,
                onHelpPressed: () => {context.go("/help")},
                onSignInPressed: () => {context.go("/sign-in")},
                onExtensionsPressed: () => {context.go("/extensions")});
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
  const VisualizeItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: const ColorScheme.light(),
          useMaterial3: true,
          scrollbarTheme: ScrollbarThemeData(
            thumbVisibility: MaterialStateProperty.all(true), //Always show scrollbar
          )),
    );
  }
}
