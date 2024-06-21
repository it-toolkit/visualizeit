import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:visualizeit/scripting/domain/parser.dart';
import 'package:visualizeit/scripting/domain/script.dart';
import 'package:visualizeit/scripting/domain/script_def.dart';
import 'package:visualizeit/scripting/domain/script_repository.dart';
import 'package:visualizeit/scripting/infrastructure/script_repository.dart';

class ScriptParserMock extends Mock implements ScriptParser {}

void main() {

  var scriptParser = ScriptParserMock();
  late InMemoryScriptRepository repo;

  setUpAll(() {
    registerFallbackValue(Script(RawScript("", ""), ScriptMetadata("name", "description", {}), []));
    registerFallbackValue(RawScript("", ""));
  });

  setUp(() {
    when(() => scriptParser.parse(any())).thenAnswer((i) {
      final rawScript = i.positionalArguments[0] as RawScript;
      return Script(rawScript, ScriptMetadata("Script 1", "An empty script", {'tag_1', 'tag_2'}), []);
    });
    repo = InMemoryScriptRepository(scriptParser);
  });

  tearDown(() {
    reset(scriptParser);
  });

  test('throw script not found exception when get with an unknown script id', () async {
    try {
      await repo.get("unknown-id");
      fail("You should not be here");
    } catch (e) {
      expect(e, isA<ScriptNotFoundException>());
    }
  });

  test('throw script not found exception when delete with an unknown script id', () async {
    try {
      await repo.delete("unknown-id");
      fail("You should not be here");
    } catch (e) {
      expect(e, isA<ScriptNotFoundException>());
    }
  });

  test('save some raw scripts and get them by id', () async {
    repo.save(RawScript("id_1", "contentAsYaml: 1"));
    repo.save(RawScript("id_2", "contentAsYaml: 2"));

    final script1 = await repo.get("id_1");
    expect(script1.raw.contentAsYaml, "contentAsYaml: 1");

    final script2 = await repo.get("id_2");
    expect(script2.raw.contentAsYaml, "contentAsYaml: 2");
  });

  test('save some raw scripts and get all of them', () async {
    repo.save(RawScript("id_1", "contentAsYaml: 1"));
    repo.save(RawScript("id_2", "contentAsYaml: 2"));

    final rawScripts = (await repo.getAll()).map((e) => e.raw);
    expect(
        rawScripts,
        containsAll([
          RawScript("id_1", "contentAsYaml: 1"),
          RawScript("id_2", "contentAsYaml: 2"),
        ]));
  });

  test('get all available scripts metadata', () async {
    repo.save(RawScript("id_1", """
      name: "Script 1"
      description: "An empty script" 
      tags: [tag_1, tag_2]
    """));

    final availableScriptsMetadata = await repo.fetchAvailableScriptsMetadata();

    expect(availableScriptsMetadata.keys, equals(["id_1"]));
    expect(availableScriptsMetadata["id_1"]!.name, equals("Script 1"));
    expect(availableScriptsMetadata["id_1"]!.description, equals("An empty script"));
    expect(availableScriptsMetadata["id_1"]!.tags, containsAll(["tag_1", "tag_2"]));
  });

  test('save a raw script and then delete it', () async {
    repo.save(RawScript("id_1", "contentAsYaml: 1"));

    final deleted = await repo.delete("id_1");
    expect(deleted.raw.contentAsYaml, "contentAsYaml: 1");

    expect(await repo.getAll(), isEmpty);
  });
}
