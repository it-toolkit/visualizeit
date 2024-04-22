import 'package:flutter_test/flutter_test.dart';
import 'package:visualizeit/scripting/domain/script_def.dart';
import 'package:visualizeit/scripting/domain/script_repository.dart';
import 'package:visualizeit/scripting/infrastructure/script_repository.dart';

void main() {
  setUpAll(() {});

  tearDown(() {});

  test('throw script not found exception when unmatched script id', () async {
    final repo = InMemoryRawScriptRepository();

    try {
      await repo.get("unknown-id");
      fail("You should not be here");
    } catch (e) {
      expect(e, isA<ScriptNotFoundException>());
    }
  });

  test('save some raw scripts and get them by id', () async {
    final repo = InMemoryRawScriptRepository();

    repo.save(RawScript("id_1", "contentAsYaml: 1"));
    repo.save(RawScript("id_2", "contentAsYaml: 2"));

    final rawScript1 = await repo.get("id_1");
    expect(rawScript1.contentAsYaml, "contentAsYaml: 1");

    final rawScript2 = await repo.get("id_2");
    expect(rawScript2.contentAsYaml, "contentAsYaml: 2");
  });

  test('save some raw scripts and get all of them', () async {
    final repo = InMemoryRawScriptRepository();

    repo.save(RawScript("id_1", "contentAsYaml: 1"));
    repo.save(RawScript("id_2", "contentAsYaml: 2"));

    final rawScripts = await repo.getAll();
    expect(
        rawScripts,
        containsAll([
          RawScript("id_1", "contentAsYaml: 1"),
          RawScript("id_2", "contentAsYaml: 2"),
        ]));
  });

  test('get all available scripts metadata', () async {
    final repo = InMemoryRawScriptRepository();

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
}
