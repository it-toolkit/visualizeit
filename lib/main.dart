import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:visualizeit/pages/base_page.dart';
import 'package:visualizeit/pages/extension_page.dart';
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
          onPlayPressed: (scriptId) => { context.go("/scripts/$scriptId/play") },
          onViewPressed: (scriptId) => { context.go("/scripts/$scriptId/edit") },
          onHelpPressed: () => { context.go("/help") },
          onSignInPressed: () => { context.go("/sign-in") },
          onExtensionsPressed: () => { context.go("/extensions") }
        );
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'scripts/:sid/edit',
          builder: (BuildContext context, GoRouterState state) {
            final scriptId = state.pathParameters['sid']!;
            return ScriptEditorPage(
                scriptId: scriptId,
                onHelpPressed: () => { context.go("/help") },
                onSignInPressed: () => { context.go("/sign-in") },
                onExtensionsPressed: () => { context.go("/extensions") }
            );
          },
        ),
        GoRoute(
          path: 'extensions',
          builder: (BuildContext context, GoRouterState state) {
            return ExtensionPage(
              onHelpPressed: () => { context.go("/help") }
            );
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
            final scriptId = state.pathParameters['sid'];
            return FakePage(title: "Player for: $scriptId", goToRoutes: []);
          },
        ),
        GoRoute(
          path: 'help',
          builder: (BuildContext context, GoRouterState state) {
            return const FakePage(title: "Help", goToRoutes: []);
          },
        ),
        GoRoute(
          path: 'extensions',
          builder: (BuildContext context, GoRouterState state) {
            return const FakePage(title: "Extensions", goToRoutes: []);
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
        ),
    );
  }
}

/// Temporal fake page
class FakePage extends BasePage {
  /// Constructs a [FakePage]
  const FakePage({super.key, required this.title, required this.goToRoutes});

  final String title;
  final List<String> goToRoutes;

  @override
  Widget buildBody(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("TO DO $title"),
            Row(children: goToRoutes
              .map((goToRoute) => ElevatedButton(
            onPressed: () => context.go(goToRoute),
            child: Text('Go to $goToRoute'),
          ))
              .toList())
          ],
        ));
  }
}
