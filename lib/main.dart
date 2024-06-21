import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:visualizeit/router.dart';
import 'package:visualizeit/scripting/domain/script_repository.dart';
import 'package:visualizeit/wiring/actions.dart';
import 'package:visualizeit/wiring/repositories.dart';
import 'package:visualizeit/wiring/services.dart';
import 'package:visualizeit/wiring/ui.dart';

import 'extension/action.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
  ]);

  setupLogging();
  setupGetIt();
  runApp(const VisualizeItApp());
}

/// The main app.
class VisualizeItApp extends StatelessWidget {
  const VisualizeItApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: GetIt.I.allReady(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final a = GetIt.I.get<ScriptRepository>();
            final b = GetIt.I.get<GetExtensionById>();
            return MultiRepositoryProvider(
                providers: [
                  RepositoryProvider<ScriptRepository>(
                      create: (context) => a), //TODO use only getit
                  RepositoryProvider<GetExtensionById>(create: (context) => b),
                ],
                child: MultiBlocProvider(
                    providers: [
                      BlocProvider<AppBloc>(create: (context) => AppBloc())
                    ],
                    child: Builder(builder: (context) {
                      final _router =
                          BlocProvider.of<AppBloc>(context).state.router;

                      return MaterialApp.router(
                        routerConfig: _router,
                        debugShowCheckedModeBanner: false,
                        theme: ThemeData(
                            colorScheme: const ColorScheme.light(),
                            useMaterial3: true,
                            scrollbarTheme: ScrollbarThemeData(
                              thumbVisibility: MaterialStateProperty.all(
                                  true), //Always show scrollbar
                            )),
                      );
                    })));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }
}

void setupLogging() {
  // Logging()
  //     ..minLogLevel = LogLevel.warn
  //     ..filter = logCategoriesStartingWith([
  //       "player",
  //       "extension"
  //     ]);
}

void setupGetIt() {
  final getIt = GetIt.I;
  getIt.registerRepositories();
  getIt.registerServices();
  getIt.registerActions();
  getIt.registerWidgets();
}
