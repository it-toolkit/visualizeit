import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:visualizeit/common/ui/error.dart';
import 'package:visualizeit/router.dart';
import 'package:visualizeit/wiring/actions.dart';
import 'package:visualizeit/wiring/repositories.dart';
import 'package:visualizeit/wiring/services.dart';
import 'package:visualizeit/wiring/ui.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
  ]);

  setupLogging();
  setupGetIt();
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrintStack(
      stackTrace: details.stack,
      label: details.exception.toString(),
      maxFrames: 5,
    );
  };
  ErrorWidget.builder = (FlutterErrorDetails errorDetails) => VisualizeItErrorWidget(errorDetails);
  runApp(const VisualizeItApp());
}

/// The main app.
class VisualizeItApp extends StatelessWidget {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  const VisualizeItApp();

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showSnackBar(SnackBar snackBar) {
    return scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }

  static void showErrorInSnackBar(String message) {
    VisualizeItApp.showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.deepOrange.shade300,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.all(40),
      showCloseIcon: true,
      duration: Duration(seconds: 5),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: GetIt.I.allReady(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Builder(
              builder: (context) {
                return MaterialApp.router(
                  scaffoldMessengerKey: scaffoldMessengerKey,
                  routerConfig: router,
                  debugShowCheckedModeBanner: false,
                  theme: ThemeData(
                      colorScheme: const ColorScheme.light(),
                      useMaterial3: true,
                      scrollbarTheme: ScrollbarThemeData(
                        thumbVisibility: MaterialStateProperty.all(true), //Always show scrollbar
                      )),
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
    );
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
