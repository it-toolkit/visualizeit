
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:visualizeit/common/utils/extensions.dart';
import 'package:visualizeit/extension/domain/action.dart';

import 'package:visualizeit/scripting/domain/parser.dart';
import 'package:visualizeit_extensions/common.dart';
import 'package:visualizeit_extensions/extension.dart';
import 'package:visualizeit_extensions/scripting.dart';

class GetExtensionsByIdMock extends Mock implements GetExtensionById {}
class ExtensionMock extends Mock implements Extension {}
class ScriptingExtensionMock extends Mock implements ScriptingExtension {}
class CommandMock extends Mock implements GlobalCommand {}

void main() {
  var getExtensionsById = GetExtensionsByIdMock();
  var extensionMock = ExtensionMock();
  var scriptingExtensionMock = ScriptingExtensionMock();
  var commandMock = CommandMock();

  tearDown(() {
    reset(getExtensionsById);
    reset(extensionMock);
    reset(scriptingExtensionMock);
    reset(commandMock);
  });
  final validRawScriptYaml = """
      name: "Flow diagram example"
      description: |
        ## Example of flow diagram usage
        This script builds a simple flow diagram and adds some components 
      tags: [data-structure, example]
      scenes:
        - name: Scene name
          extensions: [flow-diagram]
          description: Initial scene description
          initial-state:
            - no-arg-command
            - single-arg-command: "my-arg"
            - multi-arg-command: [arg1, arg2]
          transitions:
            - no-arg-command
            - single-arg-command: "my-arg"
            - multi-arg-command: [arg1, arg2]
    """.trimIndent();

  test('Parsing empty yaml script throws exception', () {

    final rawYaml = "".trimIndent();
    expect(() => ScriptParser(getExtensionsById).parse(rawYaml), throwsA(isA<Exception>()));
  });

  test('Parsing invalid yaml script throws exception', () {
    final rawYaml = """
    1
    """.trimIndent();
    expect(() => ScriptParser(getExtensionsById).parse(rawYaml), throwsA(isA<Exception>()));
  });

  test('parse valid script metadata', () {
    when(() => scriptingExtensionMock.buildCommand(any())).thenReturn(commandMock);
    when(() => extensionMock.scripting).thenReturn(scriptingExtensionMock);
    when(() => getExtensionsById.call(any())).thenReturn(extensionMock);

    final script = ScriptParser(getExtensionsById).parse(validRawScriptYaml);

    expect(script.metadata.name, equals("Flow diagram example"));
    expect(script.metadata.description, equals("""
        ## Example of flow diagram usage
        This script builds a simple flow diagram and adds some components 
    """.trimIndent()));
    expect(script.metadata.tags, containsAll(["data-structure", "example"]));
  });

  test('parse valid script scene metadata', () {
    when(() => scriptingExtensionMock.buildCommand(any())).thenReturn(commandMock);
    when(() => extensionMock.scripting).thenReturn(scriptingExtensionMock);
    when(() => getExtensionsById.call(any())).thenReturn(extensionMock);

    final script = ScriptParser(getExtensionsById).parse(validRawScriptYaml);

    expect(script.scenes.length, equals(1));
    expect(script.scenes.single.metadata.name, equals("Scene name"));
    expect(script.scenes.single.metadata.description, equals("Initial scene description"));
    expect(script.scenes.single.metadata.extensionIds, containsAll(["flow-diagram"]));
  });

  test('parse valid script scene commands', () {
    when(() => scriptingExtensionMock.buildCommand(any())).thenReturn(commandMock);
    when(() => extensionMock.scripting).thenReturn(scriptingExtensionMock);
    when(() => getExtensionsById.call(any())).thenReturn(extensionMock);

    final script = ScriptParser(getExtensionsById).parse(validRawScriptYaml);

    expect(script.scenes.length, equals(1));
    expect(script.scenes.single.initialStateBuilderCommands.length, equals(3));
    expect(script.scenes.single.transitionCommands.length, equals(3));

    verify(() => scriptingExtensionMock.buildCommand(any(that: equals('no-arg-command')))).called(2);
    verify(() => scriptingExtensionMock.buildCommand(any(that: equals('{single-arg-command: my-arg}')))).called(2);
    verify(() => scriptingExtensionMock.buildCommand(any(that: equals('{multi-arg-command: [arg1, arg2]}')))).called(2);

    verifyNever(() => commandMock.call());
  });

}
