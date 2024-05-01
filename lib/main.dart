import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visualizeit/router.dart';
import 'package:visualizeit/scripting/domain/script_repository.dart';
import 'package:visualizeit/scripting/infrastructure/script_repository.dart';

import 'extension/domain/action.dart';
import 'fake_data.dart';

void main() => runApp(const VisualizeItApp());

/// The main app.
class VisualizeItApp extends StatelessWidget {
  /// Constructs a [VisualizeItApp]
  const VisualizeItApp();

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
        providers: [
          RepositoryProvider<RawScriptRepository>(create: (context) => buildRawScriptRepository()),
          RepositoryProvider<GetExtensionById>(create: (context) => GetExtensionById()),
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
  }
}


RawScriptRepository buildRawScriptRepository() {
  if(kReleaseMode) {
    //TODO use remote repository
    return InMemoryRawScriptRepository();
  } else {
    return InMemoryRawScriptRepository(initialRawScriptsLoader: _loadExampleScriptsFromAssets());
  }
}

Future<List<RawScript>> _loadExampleScriptsFromAssets() async {
  final assetKeys = [
    "assets/script_examples/extension_template_example.yaml",
    "assets/script_examples/global_commands_example.yaml"
  ];
  return Future.wait(assetKeys.map((key) async => RawScript(key.hashCode.toString(), await rootBundle.loadString(key))));
}