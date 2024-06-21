// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:visualizeit/main.dart';

void main() {
  setUp(() async {
    try {
      TestWidgetsFlutterBinding.ensureInitialized();
      setupLogging();
      setupGetIt();
      await GetIt.I.allReady();
    } catch (e) {
      print('Failed to initialize dependencies: $e');
    }
  });

  tearDown(() async => await GetIt.I.reset());

  testWidgets('App title is shown', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const VisualizeItApp());
    await tester.pumpAndSettle();

    expect(find.text('Visualize IT'), findsOneWidget);
  });
}
