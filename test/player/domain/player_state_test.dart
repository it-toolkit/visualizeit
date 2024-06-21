

import 'package:flutter_test/flutter_test.dart';
import 'package:visualizeit/player/domain/player.dart';
import 'package:visualizeit/scripting/domain/script.dart';
import 'package:visualizeit/scripting/domain/script_def.dart';
import 'package:visualizeit/scripting/domain/script_repository.dart';
import 'package:visualizeit_extensions/common.dart';
import 'package:visualizeit_extensions/scripting.dart';

class FakeModel extends Model {
  FakeModel(this.invocations): super("fake_extension", "fake_model");

  Map<String, int> invocations;

  @override
  Model clone() {
    return FakeModel(Map.from(invocations));
  }
}

class FakeModelCommand extends ModelBuilderCommand {
  static final commandDefinition = CommandDefinition("fake_extension", "fake", []);

  FakeModelCommand.build(FakeModel model);

  @override
  Model call(CommandContext context) {
    return FakeModel({});
  }

}

class FakeCommand extends ModelCommand {
  static final commandDefinition = CommandDefinition("fake_extension", "fake", []);
  String id;
  int duration;

  FakeCommand.build(this.id, {this.duration = 1}): super ("fake_model");

  @override
  Result call(Model model, CommandContext context) {
    var fakeModel = model.clone() as FakeModel;
    Map<String, int> invocations = fakeModel.invocations;
    invocations[id] = (invocations[id] ?? 0) + 1;

    return Result(model: fakeModel, finished: invocations[id]! >= duration );
  }
}

void main() {
  test('Init player state with single scene without commands', () {
    var script = Script(
      RawScript("ref", "yaml"),
      ScriptMetadata("script_name", "script_description", {}),
      [
        Scene(SceneMetadata("scene_name", "scene_description", {}, "raw_yaml", 10), [], [])
      ]
    );
    var playerState = PlayerState(script);

    expect(playerState.currentScene.metadata.name, equals("scene_name"));
    expect(playerState.currentCommand, isNull);
  });

  test('Init player state with single scene with initial and transition commands', () {
    var fakeModel = FakeModel({});
    var initFakeCommand1 = FakeCommand.build("i1", duration: 1);
    var initFakeCommand2 = FakeCommand.build("i2", duration: 5);
    var transitionFakeCommand1 = FakeCommand.build("t1");
    var transitionFakeCommand2 = FakeCommand.build("t2");

    var script = Script(
        RawScript("ref", "yaml"),
        ScriptMetadata("script_name", "script_description", {}),
        [
          Scene(SceneMetadata("scene_name", "scene_description", {}, "raw_yaml", 10),
              [
                FakeModelCommand.build(fakeModel),
                initFakeCommand1,
                initFakeCommand2
              ],
              [
                transitionFakeCommand1,
                transitionFakeCommand2
              ]
          )
        ]
    );
    var playerState = PlayerState(script);

    expect(playerState.currentScene.metadata.name, equals("scene_name"));
    expect(playerState.currentCommand, isA<FakeCommand>());
    expect(fakeModel.invocations, isEmpty);

    var lastFakeModel = playerState.currentSceneModels["fake_model"] as FakeModel;
    expect(lastFakeModel.invocations[initFakeCommand1.id]!, equals(1));
    expect(lastFakeModel.invocations[initFakeCommand2.id]!, equals(5));

    expect(lastFakeModel.invocations[transitionFakeCommand1.id], isNull);
    expect(lastFakeModel.invocations[transitionFakeCommand2.id], isNull);
  });


  test('Init player state with single scene and run all transitions commands', () {
    var fakeModel = FakeModel({});
    var transitionFakeCommand1 = FakeCommand.build("t1", duration: 1);
    var transitionFakeCommand2 = FakeCommand.build("t2", duration: 3);
    var transitionFakeCommand3 = FakeCommand.build("t3", duration: 2);

    var script = Script(
        RawScript("ref", "yaml"),
        ScriptMetadata("script_name", "script_description", {}),
        [
          Scene(SceneMetadata("scene_name", "scene_description", {}, "raw_yaml", 10),
              [
                FakeModelCommand.build(fakeModel),
              ],
              [
                transitionFakeCommand1,
                transitionFakeCommand2,
                transitionFakeCommand3
              ]
          )
        ]
    );
    var playerState = PlayerState(script);
    var lastFakeModel = playerState.currentSceneModels["fake_model"] as FakeModel;
    expect(lastFakeModel.invocations, isEmpty);

    PlayerState newState = playerState;
    int framesRun = 0;
    do {
      newState = newState.runNextCommand();
      if (newState.progress < 1.0) framesRun++;
    } while ( newState.progress < 1.0);

    lastFakeModel = newState.currentSceneModels["fake_model"] as FakeModel;
    expect(lastFakeModel.invocations[transitionFakeCommand1.id], equals(1));
    expect(lastFakeModel.invocations[transitionFakeCommand2.id], equals(3));
    expect(lastFakeModel.invocations[transitionFakeCommand3.id], equals(2));
    expect(framesRun, equals(5));
  });
}