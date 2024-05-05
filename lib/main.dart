import 'package:flutter/material.dart';
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
  setupGetIt();
  runApp(const VisualizeItApp());
}

/// The main app.
class VisualizeItApp extends StatelessWidget {
  /// Constructs a [VisualizeItApp]
  const VisualizeItApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: GetIt.I.allReady(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final a = GetIt.I.get<RawScriptRepository>();
            final b = GetIt.I.get<GetExtensionById>();
            return MultiRepositoryProvider(
                providers: [
                  RepositoryProvider<RawScriptRepository>(create: (context) => a), //TODO use only getit
                  RepositoryProvider<GetExtensionById>(create: (context) => b),
                ],
                child: MultiBlocProvider(
                    providers: [BlocProvider<AppBloc>(create: (context) => AppBloc())],
                    child: Builder(builder: (context) {
                      final _router = BlocProvider.of<AppBloc>(context).state.router;

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
                    })));
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}

void setupGetIt() {
  final getIt = GetIt.I;
  getIt.registerRepositories();
  getIt.registerServices();
  getIt.registerActions();
  getIt.registerWidgets();
}
