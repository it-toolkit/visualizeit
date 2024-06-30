
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:visualizeit/common/utils/extensions.dart';
import 'package:visualizeit/extension/action.dart';

import 'package:visualizeit/scripting/domain/parser.dart';
import 'package:visualizeit/scripting/domain/script_repository.dart';
import 'package:visualizeit_extensions/common.dart';
import 'package:visualizeit_extensions/extension.dart';
import 'package:visualizeit_extensions/scripting.dart';

class GetExtensionsByIdMock extends Mock implements GetExtensionById {}
class ExtensionMock extends Mock implements Extension {}
class ScriptingExtensionMock extends Mock implements Scripting {}
class CommandMock extends Mock implements ModelCommand {}
class ModelMock extends Mock implements Model {}

void main() {
  var getExtensionsById = GetExtensionsByIdMock();
  var extensionMock = ExtensionMock();
  var extension2Mock = ExtensionMock();
  var scriptingExtensionMock = ScriptingExtensionMock();
  var scriptingExtension2Mock = ScriptingExtensionMock();
  var commandMock = CommandMock();
  var modelMock = ModelMock();

  setUpAll(() {
    registerFallbackValue(modelMock);
    registerFallbackValue(RawCommand.withPositionalArgs("single-arg-command", ["my-arg"]));
  });

  tearDown(() {
    reset(getExtensionsById);
    reset(extensionMock);
    reset(extension2Mock);
    reset(scriptingExtensionMock);
    reset(scriptingExtension2Mock);
    reset(modelMock);
    reset(commandMock);
  });
  final validRawScriptYaml = """
      name: "Flow diagram example"
      description: |
        ## Example of flow diagram usage
        This script builds a simple flow diagram and adds some components 
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

  test('Parsing invalid yaml script fails with errors', () {
    final scriptYaml = """
      name: A script name
      description: |
        ## Example of flow diagram usage
        This script builds a simple flow diagram and adds some components 
      scenes:
        - name 
          extensions: 
          description: Initial scene description
          initial-state
            - no-arg-command
            - single-arg-command: "my-arg"
            - multi-arg-command: [arg1, arg2]
          transitions:
            - no-arg-command
            - single-arg-command: "my-arg"
            - multi-arg-command: [arg1, arg2]
    """.trimIndent();
    expect(() => ScriptParser(getExtensionsById).parse(RawScript("ref", scriptYaml)), throwsA(isA<Exception>()));
  });

  test('Detect unexpected tokens', () {
    final scriptYaml = """
      name: "Flow diagram example"
      unexpected_attribute: "should not be here"
      description: |
        ## Example of flow diagram usage
        This script builds a simple flow diagram and adds some components 
      other_unexpected: 5
      scenes:
        - name: Scene name
          alternative_name: Unexpected attribute
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
    expect(() => ScriptParser(getExtensionsById).parse(RawScript("ref", scriptYaml)), throwsA(isA<ParserException>()
        .having((e) => e.causes[0].message, 'message', equals("Unexpected attribute 'unexpected_attribute'"))
        .having((e) => e.causes[1].message, 'message', equals("Unexpected attribute 'other_unexpected'"))
        .having((e) => e.causes[2].message, 'message', equals("Unexpected attribute 'alternative_name'"))
    ));
  });

  group("Errors at script name", () {
    test('Missing script name', () {
      final scriptYaml = """
        description: |
          ## Example of flow diagram usage
          This script builds a simple flow diagram and adds some components 
        scenes:
          - name: Scene name
            extensions: [ some_ext ]
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

      expect(() => ScriptParser(getExtensionsById).parse(RawScript("ref", scriptYaml)),
          throwsA(isA<ParserException>().having((e) => e.causes.first.message, 'message', equals("Missing non blank 'name' attribute"))));
    });

  test('Blank script name', () {
    final scriptYaml = """
        name: ""
        description: |
          ## Example of flow diagram usage
          This script builds a simple flow diagram and adds some components 
        scenes:
          - name: Scene name
            extensions: [ some_ext ]
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

    expect(() => ScriptParser(getExtensionsById).parse(RawScript("ref", scriptYaml)),
        throwsA(isA<ParserException>().having((e) => e.causes.first.message, 'message', equals("Missing non blank 'name' attribute"))));
  });

  test('Invalid type for script name', () {
    final scriptYaml = """
        name: [ "a name in an array" ]
        description: |
          ## Example of flow diagram usage
          This script builds a simple flow diagram and adds some components 
        scenes:
          - name: Scene name
            extensions: [ some_ext ]
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

    expect(() => ScriptParser(getExtensionsById).parse(RawScript("ref", scriptYaml)),
        throwsA(isA<ParserException>().having((e) => e.causes.first.message, 'message', equals("'name' must be a String"))));
  });

  });

  group("Errors at script description", () {
    test('Missing script description', () {
      final scriptYaml = """
        name: Valid name
        scenes:
          - name: Scene name
            extensions: [ some_ext ]
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

      expect(() => ScriptParser(getExtensionsById).parse(RawScript("ref", scriptYaml)),
          throwsA(isA<ParserException>().having((e) => e.causes.first.message, 'message', equals("Missing non blank 'description' attribute"))));
    });

    test('Blank script description', () {
      final scriptYaml = """
        name: Valid name
        description: "" 
        scenes:
          - name: Scene name
            extensions: [ some_ext ]
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

      expect(() => ScriptParser(getExtensionsById).parse(RawScript("ref", scriptYaml)),
          throwsA(isA<ParserException>().having((e) => e.causes.first.message, 'message', equals("Missing non blank 'description' attribute"))));
    });

    test('Invalid type for script description', () {
      final scriptYaml = """
        name: Valid name
        description: [ "a description in an array" ]
        scenes:
          - name: Scene name
            extensions: [ some_ext ]
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

      expect(() => ScriptParser(getExtensionsById).parse(RawScript("ref", scriptYaml)),
          throwsA(isA<ParserException>().having((e) => e.causes.first.message, 'message', equals("'description' must be a String"))));
    });

  });

  group("Errors at script group", () {
    test('Missing script group is valid', () {
      final scriptYaml = """
        name: Valid name
        description: Valid description
        scenes:
          - name: Scene name
            extensions: [ some_ext ]
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

      expect(() => ScriptParser(getExtensionsById).parse(RawScript("ref", scriptYaml)),
          isNot(throwsA(isA<ParserException>())));
    });

    test('Blank or null group is valid', () {
      final scriptYaml = """
        name: Valid name
        description: Valid description
        group: 
        scenes:
          - name: Scene name
            extensions: [ some_ext ]
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

      expect(() => ScriptParser(getExtensionsById).parse(RawScript("ref", scriptYaml)),
          isNot(throwsA(isA<ParserException>())));
    });

    test('Invalid type for script group', () {
      final scriptYaml = """
        name: Valid name
        description: Valid description
        group: 123
        scenes:
          - name: Scene name
            extensions: [ some_ext ]
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

      expect(() => ScriptParser(getExtensionsById).parse(RawScript("ref", scriptYaml)),
          throwsA(isA<ParserException>().having((e) => e.causes.first.message, 'message', equals("'group' must be a String"))));
    });

  });

  group("Errors at script scenes", () {
    test('Missing script scenes', () {
      final scriptYaml = """
        name: Valid name
        description: Valid description
        """.trimIndent();

      expect(() => ScriptParser(getExtensionsById).parse(RawScript("ref", scriptYaml)),
          throwsA(isA<ParserException>().having((e) => e.causes.first.message, 'message', equals("Missing non empty 'scenes' array"))));
    });

    test('Null script scenes', () {
      final scriptYaml = """
        name: Valid name
        description: Valid description
        scenes: 
        """.trimIndent();

      expect(() => ScriptParser(getExtensionsById).parse(RawScript("ref", scriptYaml)),
          throwsA(isA<ParserException>().having((e) => e.causes.first.message, 'message', equals("'scenes' must be a scenes array"))));
    });

    test('Empty script scenes', () {
      final scriptYaml = """
        name: Valid name
        description: Valid description
        scenes: []
        """.trimIndent();

      expect(() => ScriptParser(getExtensionsById).parse(RawScript("ref", scriptYaml)),
          throwsA(isA<ParserException>().having((e) => e.causes.first.message, 'message', equals("'scenes' array must not be empty"))));
    });

    test('Invalid type for script scenes', () {
      final scriptYaml = """
        name: Valid name
        description: Valid description
        scenes: { "key": "value"}
        """.trimIndent();

      expect(() => ScriptParser(getExtensionsById).parse(RawScript("ref", scriptYaml)),
          throwsA(isA<ParserException>()
              .having((e) => e.causes[0].message, 'message', equals("'scenes' must be a scenes array"))
              .having((e) => e.causes[1].message, 'message', equals("Unexpected attribute 'key'"))
          ));
    });

    test('Malformed scene in script scenes', () {
      final scriptYaml = """
        name: Valid name
        description: Valid description
        scenes:
          - name: Scene name
            extensions: [ some_ext ]
            description: Initial scene description
            initial-state:
              - nop
            transitions:
              - nop
          - Invalid scene
          - 12345
          
        """.trimIndent();

      expect(() => ScriptParser(getExtensionsById).parse(RawScript("ref", scriptYaml)),
          throwsA(isA<ParserException>()
              .having((e) => e.causes[0].message, 'message', equals("Element 1 of 'scenes' array is not a valid scene"))
              .having((e) => e.causes[1].message, 'message', equals("Element 2 of 'scenes' array is not a valid scene"))
          ));
    });

    test('Scene without name', () {
      final scriptYaml = """
        name: Valid name
        description: Valid description
        scenes:
          - extensions: [ some_ext ]
            description: Initial scene description
            initial-state:
              - nop
            transitions:
              - nop
        """.trimIndent();

      expect(() => ScriptParser(getExtensionsById).parse(RawScript("ref", scriptYaml)),
          throwsA(isA<ParserException>()
              .having((e) => e.causes[0].message, 'message', equals("Missing non blank 'name' attribute"))
          ));
    });

    test('Scene without description is valid', () {
      final scriptYaml = """
        name: Valid name
        description: Valid description
        scenes:
          - name: Scene name
            extensions: [ some_ext ]
            initial-state:
              - nop
            transitions:
              - nop
        """.trimIndent();

      expect(() => ScriptParser(getExtensionsById).parse(RawScript("ref", scriptYaml)),
          isNot(throwsA(isA<ParserException>())));
    });


    test('Missing scene extensions is valid', () {
      final scriptYaml = """
        name: Valid name
        description: Valid description
        scenes:
          - name: Scene name
            description: Initial scene description
            initial-state:
              - nop
            transitions:
              - nop
        """.trimIndent();

      expect(() => ScriptParser(getExtensionsById).parse(RawScript("ref", scriptYaml)),
          isNot(throwsA(isA<ParserException>())));
    });

    test('Null scene extensions is valid', () {
      final scriptYaml = """
        name: Valid name
        description: Valid description
        scenes:
          - name: Scene name
            extensions: 
            description: Initial scene description
            initial-state:
              - nop
            transitions:
              - nop
        """.trimIndent();

      expect(() => ScriptParser(getExtensionsById).parse(RawScript("ref", scriptYaml)),
          isNot(throwsA(isA<ParserException>())));
    });

    test('Invalid type for scene extensions', () {
      final scriptYaml = """
        name: Valid name
        description: Valid description
        scenes:
          - name: Scene name
            extensions: "invalid-array"
            description: Initial scene description
            initial-state:
              - nop
            transitions:
              - nop
        """.trimIndent();

      expect(() => ScriptParser(getExtensionsById).parse(RawScript("ref", scriptYaml)),
          throwsA(isA<ParserException>().having((e) => e.causes.first.message, 'message', equals("'extensions' must be a String array"))));
    });

    test('Missing initial-state and transitions is valid', () {
      final scriptYaml = """
        name: Valid name
        description: Valid description
        scenes:
          - name: Scene name
            extensions: [ ]
            description: Initial scene description
        """.trimIndent();

      expect(() => ScriptParser(getExtensionsById).parse(RawScript("ref", scriptYaml)),
          isNot(throwsA(isA<ParserException>())));
    });

    test('Empty initial-state and transitions is valid', () {
      final scriptYaml = """
        name: Valid name
        description: Valid description
        scenes:
          - name: Scene name
            extensions: [ "a"]
            description: Initial scene description
            initial-state:
            transitions: []
        """.trimIndent();

      expect(() => ScriptParser(getExtensionsById).parse(RawScript("ref", scriptYaml)),
          isNot(throwsA(isA<ParserException>())));
    });

    test('initial-state and transitions require an array', () {
      final scriptYaml = """
        name: Valid name
        description: Valid description
        scenes:
          - name: Scene name
            extensions: [ "a"]
            description: Initial scene description
            initial-state: "Some String"
            transitions: 
              key: value 
        """.trimIndent();

      expect(() => ScriptParser(getExtensionsById).parse(RawScript("ref", scriptYaml)),
          throwsA(isA<ParserException>()
              .having((e) => e.causes[0].message, 'message', equals("'initial-state' must be a commands array"))
              .having((e) => e.causes[1].message, 'message', equals("'transitions' must be a commands array"))
          ));
    });

  });

  test('Parsing empty yaml script throws exception', () {

    final rawYaml = "".trimIndent();
    expect(() => ScriptParser(getExtensionsById).parse(RawScript("ref", rawYaml)), throwsA(isA<Exception>()));
  });

  test('Parsing invalid yaml script throws exception', () {
    final rawYaml = """
    1
    """.trimIndent();
    expect(() => ScriptParser(getExtensionsById).parse(RawScript("ref", rawYaml)), throwsA(isA<Exception>()));
  });

  test('parse valid script metadata', () {
    when(() => scriptingExtensionMock.buildCommand(any())).thenReturn(null);
    when(() => extensionMock.scripting).thenReturn(scriptingExtensionMock);
    when(() => getExtensionsById.call(any(that: equals("default")))).thenReturn(extensionMock);

    when(() => scriptingExtension2Mock.buildCommand(any())).thenReturn(commandMock);
    when(() => extension2Mock.scripting).thenReturn(scriptingExtension2Mock);
    when(() => getExtensionsById.call(any(that: equals("flow-diagram")))).thenReturn(extension2Mock);

    final script = ScriptParser(getExtensionsById).parse(RawScript("ref", validRawScriptYaml));

    expect(script.metadata.name, equals("Flow diagram example"));
    expect(script.metadata.description, equals("""
        ## Example of flow diagram usage
        This script builds a simple flow diagram and adds some components 
    """.trimIndent()));
  });

  test('parse valid script scene metadata', () {
    when(() => scriptingExtensionMock.buildCommand(any())).thenReturn(null);
    when(() => extensionMock.scripting).thenReturn(scriptingExtensionMock);
    when(() => getExtensionsById.call(any(that: equals("default")))).thenReturn(extensionMock);

    when(() => scriptingExtension2Mock.buildCommand(any())).thenReturn(commandMock);
    when(() => extension2Mock.scripting).thenReturn(scriptingExtension2Mock);
    when(() => getExtensionsById.call(any(that: equals("flow-diagram")))).thenReturn(extension2Mock);

    final script = ScriptParser(getExtensionsById).parse(RawScript("ref", validRawScriptYaml));

    expect(script.scenes.length, equals(1));
    expect(script.scenes.single.metadata.name, equals("Scene name"));
    expect(script.scenes.single.metadata.description, equals("Initial scene description"));
    expect(script.scenes.single.metadata.extensionIds, containsAll(["flow-diagram"]));
  });

  test('parse valid script scene commands', () {
    when(() => scriptingExtensionMock.buildCommand(any())).thenReturn(null);
    when(() => extensionMock.scripting).thenReturn(scriptingExtensionMock);
    when(() => getExtensionsById.call(any(that: equals("default")))).thenReturn(extensionMock);

    when(() => scriptingExtension2Mock.buildCommand(any())).thenReturn(commandMock);
    when(() => extension2Mock.scripting).thenReturn(scriptingExtension2Mock);
    when(() => getExtensionsById.call(any(that: equals("flow-diagram")))).thenReturn(extension2Mock);

    final script = ScriptParser(getExtensionsById).parse(RawScript("ref", validRawScriptYaml));

    expect(script.scenes.length, equals(1));
    expect(script.scenes.single.initialStateBuilderCommands.length, equals(3));
    expect(script.scenes.single.transitionCommands.length, equals(3));

    final capturedRawCommands = verify(() => scriptingExtension2Mock.buildCommand(captureAny<RawCommand>())).captured;

    expect(capturedRawCommands.where((e) => e.name == 'no-arg-command').length, equals(2));
    expect(capturedRawCommands.where((e) => e.name == 'single-arg-command').length, equals(2));
    expect(capturedRawCommands.where((e) => e.name == 'multi-arg-command').length, equals(2));

    verifyNever(() => commandMock.call(any<Model>(), CommandContext()));
  });

}
